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
    Arrays with exceptions
    
 .Notes
    None
    
  .Example

    C:\> Get-TMGExceptions -Server tmg.contoso.local -Credentials contoso\user

#>
[CmdletBinding()]
param([parameter(Mandatory=$true)][string]$ComputerName,
      [parameter(Mandatory=$false)][string]$Credential)

    $credentials = $Credential
    if ((Test-Path Variable:\com.atpi.tmg.credentials) -and -not $Credential) {
        $credentials = ${GLOBAL:com.atpi.tmg.credentials}
    }
    ${GLOBAL:com.atpi.tmg.credentials} = Get-Credential $credentials
    $credentials = ${GLOBAL:com.atpi.tmg.credentials}

    $script = {
        $TMGRoot = New-Object -comObject FPC.root
        $TMGServer = $TMGRoot.Arrays | select-object -first 1
        $TMGIntNet = ($TMGServer.NetworkConfiguration.Networks | ?{ $_.Name -contains "Internal"}).ClientConfig
        $TMGDirect = $TMGIntNet.Browser.Autoscript.DirectAddressDestinations

        $directArray = @()
        foreach($i in $TMGDirect)
        {
            $directArray += $i      
        }
        New-Object pscustomobject -property @{ Exceptions = $directArray }
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
    if ((Test-Path Variable:\com.atpi.tmg.credentials) -and -not $Credential) {
        $credentials = ${GLOBAL:com.atpi.tmg.credentials}
    }
    ${GLOBAL:com.atpi.tmg.credentials} = Get-Credential $credentials
    $credentials = ${GLOBAL:com.atpi.tmg.credentials}

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
        $addedArray = @()
        foreach($except in $Exceptions) {
            if ( -not $directArray.Contains($except)) {
                $TMGDirect.Add($except)
                $TMGDirect.Save()
                $addedArray += $except
            }
        }
        $TMGServer.Save()
        $TMGServer.ApplyChanges()
        New-Object pscustomobject -property @{ Results = $addedArray }
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
    if ((Test-Path Variable:\com.atpi.tmg.credentials) -and -not $Credential) {
        $credentials = ${GLOBAL:com.atpi.tmg.credentials}
    }
    ${GLOBAL:com.atpi.tmg.credentials} = Get-Credential $credentials
    $credentials = ${GLOBAL:com.atpi.tmg.credentials}

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
        $addedArray = @()
        foreach($except in $Exceptions) {
            if ( $directArray.Contains($except)) {
                $TMGDirect.Remove($except)
                $TMGDirect.Save()
                $addedArray += $except
            }
        }
        $TMGServer.Save()
        $TMGServer.ApplyChanges()
        New-Object pscustomobject -property @{ Results = $addedArray }
    }
    Invoke-Command -ComputerName $ComputerName -Credential $credentials -ArgumentList (,$Exceptions) -ScriptBlock $script | Select Results
}