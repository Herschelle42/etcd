function Get-etcdHealth {
<#
.Synopsis
   Get the etcd cluster health
.DESCRIPTION
   Return the health json payload of the etcd cluster to determine the health status.
.PARAMETER Protocol
    The protocol to use to connect to vRO. Valid values are http/https. Default is https.
.PARAMETER ComputerName
   The FQDN, IP address of the etcd server
.PARAMETER Port
    The port to connect to etcd. For example 8080. Default is none.
.PARAMETER HealthPath
    The url path to the health response.

.INPUTS
   [String]
.OUTPUTS
   [string]
.EXAMPLE 
   Get-etcdHealth -Protocol http -ComputerName etcd.corp.local
.NOTES
   Author:  Clint Fritz
   etcd version: 2.x

   Although this function seems a little bit of overkill for what is essentially an easy Invoke-WebRequest.

#>
[CmdletBinding()]
Param(
    #Name, FQDN or IP address of etcd server
    [Parameter(Mandatory)]
    [Alias("Server","IPAddress","FQDN")]
    [string]$ComputerName,

    #The port on the etcd for the API
    [Parameter(Mandatory=$false)]
    [ValidatePattern("^[1-9][0-9]{0,4}$")]
    [string]$Port,

    #Health url path - Default is /health
    [Parameter(Mandatory=$false)]
    [string]$HealthPath="/health",

    #Protocol. http\https - Default is https
    [Parameter(Mandatory=$false)]
    [ValidateSet("https","http")]
    [string]$Protocol="https"
        
)

Begin {
    #todo: Create a credential out of the username and password, if supplied.

    #Build uri
    if($Port) {
        $uri = "$($protocol)://$($ComputerName):$($Port)$($HealthPath)"
    } else {
        $uri = "$($protocol)://$($ComputerName)$($HealthPath)"
    }
    Write-Verbose "[INFO] Uri: $($uri)"
}


Process {

    try {
        $response = Invoke-WebRequest -Uri $uri

        $startPos = $response.RawContent.IndexOf("{")
        $endPos = $response.RawContent.LastIndexOf("}")
        $jsonLength = $endPos - $startPos + 1
        $json = $response.RawContent.Substring($startPos,$jsonLength)
        Return $json
    } 
    catch {
        throw
    }

}

End {

}

}
