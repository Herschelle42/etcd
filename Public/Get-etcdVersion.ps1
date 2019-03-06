function Get-etcdVersion {
<#
.SYNOPSIS
  Get the etcd version information using the etcd API
.DESCRIPTION
  Returns the etcd server version and etcd cluster version using the API
  Does not require any authentication.
.INPUTS
  [string]
  [int]
.OUTPUTS
  [object]
.PARAMETER ComputerName
  The fully qualified domain name (FQDN), hostname or IP of the etc server
.PARAMETER Port
  Use this parameter if a non standard port has been configured
.EXAMPLE
  Get-etcdVersion -Server "etcd.corp.local" -Port 2379
    Server          ServerVersion ClusterVersion
    ------          ------------- --------------
    etcd.corp.local 2.2.4         2.2.0
.NOTES
  Only tested on etcd version 2.2.
#>
Param (
        #Name, FQDN or IP address of etcd server
        [Parameter(Mandatory=$true)]
        [Alias("Server","IPAddress","FQDN")]
        [string]$ComputerName = $(throw "A Computer name is required."),

        #The port on the etcd for the API
        [Parameter(Mandatory=$false)]
        [ValidatePattern("^[1-9][0-9]{0,4}$")]
        [int]$Port
)

    Begin {
        [string]$method="GET"

        $uri = $null
        if($Port) {
          $uri = "http://$($ComputerName):$($Port)"
        } else {
          $uri = "http://$($ComputerName)"
        }
        
        $paramsConnectEtcd = @{
            uri="$($uri)/version";
            method=$method;
        }

    }#end Begin block

    Process {
        $etcdResult = Invoke-RestMethod @paramsConnectEtcd

        $hash = [ordered]@{}
        $hash.Server = $ComputerName
        $hash.ServerVersion = $etcdResult.etcdserver
        $hash.ClusterVersion = $etcdResult.etcdcluster
        $object = new-object PSObject -property $hash
        $object
    }#end Process block

}#end function Get-etcdVersion
