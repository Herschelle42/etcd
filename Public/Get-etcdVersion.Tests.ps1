<#
.SYNOPSIS
  Get-etcdVersion Pester tests
.NOTES
  references: https://github.com/pester/Pester/wiki/Should

#>

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
#. $PSScriptRoot/myscript.ps1

$thisFunction =$MyInvocation.MyCommand.Name.Replace(".Tests.ps1","")
#Write-Output "Function: $($thisFunction)"

Describe "$($thisFunction) Function" {

}#end Describe

Get-etcdVersion -ComputerName "10.9.144.61" -Port 2379
Get-etcdVersion -ComputerName "kvs.cloudservices.atonet.gov.au"
