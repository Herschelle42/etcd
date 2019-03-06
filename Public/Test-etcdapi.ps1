function Test-etcdAPI {
<#
.SYNOPSIS
  Test etcd API to see if it is responding.
.DESCRIPTION
  Hit the etcd API to retrieve the version number we test that the API 
  interface is responding. No authentication is required to retrieve the 
  version from the API. Therefore it is a good test for the status of the API
  If the request is successful
.PARAMETER ComputerName
  Name, FQDN or IP of the etcd server
.PARAMETER Port
  Port of the etcd server hosting the API
.INPUTS
  [string]
  [int]
.OUTPUTS
  [Boolean]
.NOTES
  Written by: Clint Fritz
  - Add SSL Parameter for https requests?
  - Accept pipeline input
.EXAMPLE
  Test-etcdapi -ComputerName "etcd.corp.local"
  True
.EXAMPLE
  Test-etcdapi -ComputerName "etcd.corp.local" -Port "2379"
  True
.EXAMPLE
  Test-etcdapi -ComputerName "no-server.corp.local"
  False
#>
[CmdletBinding()]
    Param (
        #Name or IP of the etcd server
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [Alias("Server","IPAddress","FQDN")]
        [string]$ComputerName = $(throw "A Computer name is required."),
        #The server port
        [Parameter(Mandatory=$false)]
        [ValidatePattern("^[1-9][0-9]{0,4}$")]
        [int]$Port

    )

    Begin {
        [string]$method="GET"
        $ErrorActionPreference='SilentlyContinue'
    }#end Begin block

    Process {
        $uri = $null

        if($Port) {
          $uri = "http://$($ComputerName):$($Port)/version"
        } else {
          $uri = "http://$($ComputerName)/version"
        }

        $etcdResult = Invoke-RestMethod -Uri $uri -Method $method

        if ($etcdResult) {
          Return $true
        } else {
          Return $false
        }#end if good result

    }#end Process block

}#end function Get-etcdAPI
