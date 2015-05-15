function Get-TMGExceptions {
<#
 .Synopsis
    Get browser exceptions from TMG server

 .Description
    This function gets the exceptions from the TMG server.

 .Parameter ComputerName
    Contains Server name to connect to.

 .Parameter Credential
    Credentials to use.

 .Outputs
    NoteProperty with exceptions

 .Notes
    None

 .Example

    C:\> Get-TMGExceptions -Server tmg.contoso.local -Credentials contoso\user

#>
[CmdletBinding()]
param([parameter(Mandatory=$true)][string]$ComputerName,
      [parameter(Mandatory=$false)][string]$Credential)

    $credentials = $Credential
    if ((Test-Path Variable:\$ComputerName) -and -not $Credential) {
        $credentials = Get-Variable $ComputerName -ValueOnly
    }
    Set-Variable $ComputerName (Get-Credential $credentials) -Scope "Global"
    $credentials = Get-Variable $ComputerName -ValueOnly

    $script = {
        $TMGRoot = New-Object -comObject FPC.root
        $TMGServer = $TMGRoot.Arrays | select-object -first 1
        $TMGIntNet = ($TMGServer.NetworkConfiguration.Networks | ?{ $_.Name -contains "Internal"}).ClientConfig
        $TMGDirect = $TMGIntNet.Browser.Autoscript.DirectAddressDestinations

        foreach($i in $TMGDirect)
        {
            $hash = @{ Exceptions = $i }
            New-Object -TypeName PSObject -Prop $hash
        }
    }
    Invoke-Command -ComputerName $ComputerName -Credential $credentials -ScriptBlock $script | Select Exceptions
}

function Add-TMGExceptions {
<#
 .Synopsis
    Add browser exceptions to TMG server

 .Description
    This function adds exceptions to the TMG server.

 .Parameter ComputerName
    Contains Server name to connect to.

 .Parameter Credential
    Credentials to use.

 .Parameter Exceptions
    Array with exceptions to add.

 .Outputs
    Results

 .Notes
    None

  .Example

    C:\> Add-TMGExceptions -Server tmg.contoso.local -Credentials contoso\user -Exceptions "www.contoso.com","mail.contoso.com"

#>
[CmdletBinding()]
param([parameter(Mandatory=$true)][string]$ComputerName,
      [parameter(Mandatory=$false)][string]$Credential,
      [parameter(Mandatory=$true)][array]$Exceptions)

    $credentials = $Credential
    if ((Test-Path Variable:\$ComputerName) -and -not $Credential) {
        $credentials = Get-Variable $ComputerName -ValueOnly
    }
    Set-Variable $ComputerName (Get-Credential $credentials) -Scope "Global"
    $credentials = Get-Variable $ComputerName -ValueOnly

    $script = {
        param([array]$Exceptions)
        $Result = $null
        $TMGRoot = New-Object -comObject FPC.root
        $TMGServer = $TMGRoot.Arrays | select-object -first 1
        $TMGIntNet = ($TMGServer.NetworkConfiguration.Networks | ?{ $_.Name -contains "Internal"}).ClientConfig
        $TMGDirect = $TMGIntNet.Browser.Autoscript.DirectAddressDestinations

        $directArray = $null
        foreach($i in $TMGDirect)
        {
            $directArray += $i
        }
        foreach($except in $Exceptions) {
            if ( -not $directArray.Contains($except)) {
                $TMGDirect.Add($except)
                $TMGDirect.Save()
                $hash = @{ Results = $except }
                New-Object -TypeName PSObject -Prop $hash
            }
        }
        $TMGServer.Save()
        $TMGServer.ApplyChanges()
    }
    Invoke-Command -ComputerName $ComputerName -Credential $credentials -ArgumentList (,$Exceptions) -ScriptBlock $script | Select Results
}

function Remove-TMGExceptions {
<#
 .Synopsis
    Removes browser exceptions from TMG server

 .Description
    This function removes exceptions from the TMG server.

 .Parameter ComputerName
    Contains Server name to connect to.

 .Parameter Credential
    Credentials to use.

 .Parameter Exceptions
    Array with exceptions to remove.

 .Outputs
    Results

 .Notes
    None

  .Example

    C:\> Remove-TMGExceptions -Server tmg.contoso.local -Credentials contoso\user -Exceptions "www.contoso.com","mail.contoso.com"

#>
[CmdletBinding()]
param([parameter(Mandatory=$true)][string]$ComputerName,
      [parameter(Mandatory=$false)][string]$Credential,
      [parameter(Mandatory=$true)][array]$Exceptions)

    $credentials = $Credential
    if ((Test-Path Variable:\$ComputerName) -and -not $Credential) {
        $credentials = Get-Variable $ComputerName -ValueOnly
    }
    Set-Variable $ComputerName (Get-Credential $credentials) -Scope "Global"
    $credentials = Get-Variable $ComputerName -ValueOnly

    $script = {
        param([array]$Exceptions)
        $Result = $null
        $TMGRoot = New-Object -comObject FPC.root
        $TMGServer = $TMGRoot.Arrays | select-object -first 1
        $TMGIntNet = ($TMGServer.NetworkConfiguration.Networks | ?{ $_.Name -contains "Internal"}).ClientConfig
        $TMGDirect = $TMGIntNet.Browser.Autoscript.DirectAddressDestinations

        $directArray = $null
        foreach($i in $TMGDirect)
        {
            $directArray += $i
        }
        foreach($except in $Exceptions) {
            if ( $directArray.Contains($except)) {
                $TMGDirect.Remove($except)
                $TMGDirect.Save()
                $hash = @{ Results = $except }
                New-Object -TypeName PSObject -Prop $hash
            }
        }
        $TMGServer.Save()
        $TMGServer.ApplyChanges()
    }
    Invoke-Command -ComputerName $ComputerName -Credential $credentials -ArgumentList (,$Exceptions) -ScriptBlock $script | Select Results
}
