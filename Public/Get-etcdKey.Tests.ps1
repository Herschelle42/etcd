<#
.SYNOPSIS
  Pester tests for Get-etcdKey
.NOTES
  etcd.corp.local is configured in the local hosts file to resolve to a valid
  etcd server. 
#>

$etcdServer = "etcd.corp.local"
$portValid = 2379

#create a of correct type
$password = "password" | ConvertTo-SecureString -AsPlainText -Force

$etcdUsername="abcm_write"
$etcdPassword="blueprinting"
[SecureString]$etcdSecurePassword = ConvertTo-SecureString $etcdPassword -AsPlainText -Force


#--- Main test area ------------------------------------------------------------------------
#Load Pester Module
$moduleName = "Pester"
$ParentDirectory = "C:\Tools"
if (!(get-command -module $moduleName)) {
    Write-Output "[INFO] Loading module $($moduleName)"
    Import-Module -Name "$($ParentDirectory)\$($moduleName)" -ErrorAction Stop
} else {
    Write-Output "[INFO] Module $($moduleName) already loaded."
}

#Load the function to test by removing the .Tests string from the file path
. $MyInvocation.MyCommand.Path.replace(".Tests","")

Describe "Get-etcdKey" {
    #Test that an error is thrown, if no parameters have been passed.
    It 'Given no parameters, fails' {
        { Get-etcdKey } | Should -Throw
    }#end It

    #Test that an error is thrown, if no parameters have been passed.
    It 'Given no parameters, fails with Parameter not set' {
        { Get-etcdKey } | Should -Throw "Parameter set cannot be resolved"
    }#end It
    
    It 'Given a clear text password, fails' {
        { Get-etcdKey -Password "password" } | Should -Throw 'Cannot convert the "password" value of type "System.String" to type "System.Security.SecureString"'
    }#end It

    It 'Credential is empty' {
        { Get-etcdKey -ComputerName "does.not.exist.corp.local" -Credential } | Should -Throw "Missing an argument for parameter 'Credential'. Specify a parameter of type 'System.Management.Automation.PSCredential' and try again."
    }

    #Test where a server name does not resolve via DNS
    It 'etcd Server does not respond if DNS entry cannot be resolved' {
        { Get-etcdKey -ComputerName "does.not.exist.corp.local" -Username "user" -Password $password -Key $key } | Should -Throw "The remote name could not be resolved:"
    }

    $portRandom = 12345
    It 'Fails when attempting access SSH port' {
        { Get-etcdKey -ComputerName $etcdServer -port $portRandom -Username "user" -Password $password -Key $key } | Should -Throw "Unable to connect to the remote server"
    }

    $portSSH = 22
    It 'Fails when attempting access SSH port' {
        { Get-etcdKey -ComputerName $etcdServer -port $portSSH -Username "user" -Password $password -Key $key } | Should -Throw "The server committed a protocol violation. Section=ResponseStatusLine"
    }

    #When connecting to a valid server and port with an unauthorised user get an error
    It 'Unauthorised user' {
        { Get-etcdKey -ComputerName $etcdServer -port $portValid -Username "user" -Password $password -Key $key } | Should -Throw "The remote server returned an error: (401) Unauthorized."
    }

    #Invalid Key
    $key ="/v2/keys/abcm/v0/nothere/"
    It 'Invalid key returns a 404' {
        { Get-etcdKey -ComputerName $etcdServer -port $portValid -Username $etcdUsername -Password $etcdSecurePassword -Key $key } | Should -Throw "The remote server returned an error: (404) Not Found."
    }


}#end Describe

#--- working out and other stuff ----------------------------------------------------------------------
Continue

$ComputerName = "10.9.144.61"
$port = 2379
$key = "/v2/keys/abcm/v0/ATB"
$etcdUsername="abcm_write"
$etcdPassword="blueprinting"
[SecureString]$etcdSecurePassword = ConvertTo-SecureString $etcdPassword -AsPlainText -Force
if (-not $credential)
{
    $credential = Get-Credential -UserName $etcdUsername -Message "Enter etcd credentials"
}


#Username and Password. Default recursion
$etcdParams = @{
    ComputerName=$ComputerName;
    Port=$port
    Username=$etcdUsername;
    Password=$etcdSecurePassword;
    Key=$Key;
    Verbose=$true;
}
Get-etcdKey @etcdParams


#Use Credential. Default recursion
$etcdParams = @{
    ComputerName=$ComputerName;
    Port=$port
    Credential=$credential;
    Key=$Key;
    Verbose=$true;
}
Get-etcdKey @etcdParams

#Username and Password with Recursion
$etcdParams = @{
    ComputerName=$ComputerName;
    Port=$port
    Username=$etcdUsername;
    Password=$etcdSecurePassword;
    Key=$Key;
    Recursive=$true;
    Verbose=$true;
}
Get-etcdKey @etcdParams

