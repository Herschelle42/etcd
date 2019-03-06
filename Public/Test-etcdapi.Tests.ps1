<#
.SYNOPSIS
  Test-etcdAPI Pester tests
.NOTES
  references: https://github.com/pester/Pester/wiki/Should

#>

$module = "Pester"
$ParentDirectory = "C:\Tools"
if (!(get-command -module $module)) {
    Import-Module -Name "$($ParentDirectory)\$($module)" -ErrorAction Stop
}

#Load the function to test by removing the .Tests string from the file path
. $MyInvocation.MyCommand.Path.replace(".Tests","")
#. $PSScriptRoot/myscript.ps1

$thisFunction =$MyInvocation.MyCommand.Name.Replace(".Tests.ps1","")


Describe 'Test-etcdAPI' {

    It 'Correct connection' {
        Test-etcdAPI -ComputerName "10.9.144.61" -Port 2379 | Should -Be "True"
    }#end It
    
    $result = Test-etcdAPI -ComputerName "10.9.144.61" -Port 80
    It 'Computer exists but use the wrong port' {
        #Test-etcdAPI -ComputerName "10.9.144.61" -Port 80 | Should -Throw "Unable to connect to the remote server"
        $result | Should -Throw "Unable to connect to the remote server"
         #$result | Should -Be "False"
    }#end It
    



}#end Describe
