# PSTMG
This powershell module get/add/remove browser exceptions from a TMG server.

## Installation
Clone this repository into the Powershell module directory. This directory can be obtained by typing $env:PSModulePath on the Powershell prompt.

## <a name="functions">Functions</a>
On the prompt you can use 'help <Function-Name>' to display the help.

Function-Name | Description
----|----
Get-TMGExceptions -Server tmg.contoso.local -Credentials contoso\user | Returns an array with the current browser exceptions
Add-TMGExceptions -Server tmg.contoso.local -Credentials contoso\user -Exceptions "www.contoso.com","mail.contoso.com" | Adds the exceptions to the list
Remove-TMGExceptions -Server tmg.contoso.local -Credentials contoso\user -Exceptions "www.contoso.com","mail.contoso.com" | Removes the exceptions from the list 
