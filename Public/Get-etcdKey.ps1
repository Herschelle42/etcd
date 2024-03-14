function Get-etcdKey {
<#
.SYNOPSIS
  Get a Key from etcd v2 server
.DESCRIPTION
  Get a Key and optionally subkeys as well from etcd v2 server. Returns
  json data.
.INPUTS
  [string]
  [int]
  [SecureString]
  [Management.Automation.PSCredential]
.OUTPUTS
  [object]
.EXAMPLE
  $etcdCredential = get-credential -Message "etcd username and password"
  Get-etcdKey -ComputerName "etcd.corp.local" -Port 2379 -Credential $etcdCredential -Key "/v2/keys/abcm"

    key           : /abcm
    dir           : True
    nodes         : {@{key=/abcm/v0; dir=True; modifiedIndex=1393935; createdIndex=1393935}, @{key=/abcm/v1; 
                    dir=True; modifiedIndex=1236101; createdIndex=1236101}, @{key=/abcm/v; dir=True; 
                    modifiedIndex=1440583; createdIndex=1440583}}
    modifiedIndex : 1216086
    createdIndex  : 1216086

.EXAMPLE
  $SecurePassword = ConvertTo-SecureString "P@ssword" -AsPlainText -Force
  Get-etcdKey -ComputerName "etcd.corp.local" -Port 2379 -Username MyUsername -Password $SecurePassword -Key "/v2/keys/abcm"

    key           : /abcm
    dir           : True
    nodes         : {@{key=/abcm/v0; dir=True; modifiedIndex=1393935; createdIndex=1393935}, @{key=/abcm/v1; 
                    dir=True; modifiedIndex=1236101; createdIndex=1236101}, @{key=/abcm/v; dir=True; 
                    modifiedIndex=1440583; createdIndex=1440583}}
    modifiedIndex : 1216086
    createdIndex  : 1216086

.EXAMPLE
  $backupFile = "etcd-Backup.json"
  $etcdCredential = get-credential -Message "etcd username and password"
  $data = Get-etcdKey -ComputerName "etcd.corp.local" -Port 2379 -Credential $etcdCredential -Key "/v2/keys/abcm" -Recursive -Sort -Verbose
  $data | ConvertTo-Json -Depth 20 | Out-File -FilePath $backupFile

  Note: If you wish to compare backups you MUST use the -Sort parameter otherwise the resulting json data will be random
  which makes it basically impossible to do an accurate windiff\winmerge\compare-object.

.NOTES
  If you receive and error message similar to : Invoke-RestMethod : {"errorCode":100,"message":"Key not found","cause":"/Iaas","index":1491542}
  and you know the path is correct, check the capitalisation. etcd is case sensitive.
  In the above example /Iaas should have been /IaaS

#>

[CmdletBinding()]
    Param(
        #The protocol to use. Valid values are http/https. Default is https.
        [Parameter(Mandatory=$false)]
        [ValidateSet("https","http")]
        [string]$Protocol="https",

        #Name, FQDN or IP address of etcd server
        [Parameter(Mandatory=$true)]
        [Alias("Server","IPAddress","FQDN")]
        [string]$ComputerName,

        #The port on the etcd for the API
        [Parameter(Mandatory=$false)]
        [ValidatePattern("^[1-9][0-9]{0,4}$")]
        [int]$Port,

        #Username to access requested key
        [Parameter(Mandatory=$true,ParameterSetName="Username")]
        [string]$Username,

        #Password of user to access requested Key
        [Parameter(Mandatory=$true,ParameterSetName="Username")]
        [SecureString]$Password,

        [Parameter(Mandatory=$true,ParameterSetName="Credential")]
        [ValidateNotNullOrEmpty()]
        [Management.Automation.PSCredential]$Credential,

        #The path of the Key to test
        [Parameter(Mandatory=$true)]
        [string]$Key,

        #Recursively get all sub keys and values
        [Parameter(Mandatory=$false)]
        [Switch]$Recursive=$false,

        #Sort the output
        [Parameter(Mandatory=$false)]
        [Switch]$Sort=$false
        
    )

    Begin {
        [string]$method="GET"

        Write-Verbose "[INFO] ComputerName: $($ComputerName)"
        Write-Verbose "[INFO] Port: $($Port)"

        #--- extract username and password from credential
        if ($PSBoundParameters.ContainsKey("Credential")){
            Write-Verbose "[INFO] Credential: $($Credential | Out-String)"
            $Username = $Credential.UserName
            $UnsecurePassword = $Credential.GetNetworkCredential().Password
        }
        
        if ($PSBoundParameters.ContainsKey("Password")){
            Write-Verbose "[INFO] Username: $($Username)"
            #Write-Verbose "[INFO] Password: $($Password)"
            $UnsecurePassword = (New-Object System.Management.Automation.PSCredential("username", $Password)).GetNetworkCredential().Password
        }
        
        Write-Verbose "[INFO] Key: $($Key)"
        Write-Verbose "[INFO] Recursive: $($Recursive)"
        Write-Verbose "[INFO] Sort: $($Sort)"

        #--- Create authorization headers
        #Write-Verbose "insecure: $($UnsecurePassword)"
        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $Username,$UnsecurePassword)))
        $headers = @{"Authorization"=("Basic {0}" -f $base64AuthInfo)}
        Write-Verbose "[INFO] Headers: $($headers)"

    }

    Process {

        if ($Key.Substring(0,1) -notmatch "/") {
          $Key="/$($Key)"
        }
        Write-Verbose "[INFO] Key: $($Key)"


        #Build a parameter string
        $parameterList = $null

        if ($PSBoundParameters.ContainsKey("Recursive")) {
            if ($parameterList -and $parameterList.Contains("?")) {
                $parameterList = "$($parameterList)&recursive=true"
            } else {
                $parameterList = "?recursive=true"
            }
            #$Key = "$($Key)?recursive=true"
            Write-Verbose "[INFO] ParameterList Key: $($parameterList)"
        }

        if ($PSBoundParameters.ContainsKey("Sort")) {
            if ($parameterList -and $parameterList.Contains("?")) {
                $parameterList = "$($parameterList)&sorted=true"
            } else {
                $parameterList = "?sorted=true"
            }
            #$Key = "$($Key)?recursive=true"
            Write-Verbose "[INFO] ParameterList Key: $($parameterList)"
        }


        #If a port is defined, updated the server uri.
        $serverUri = $null
        if($Port) {
          $serverUri = "$($Protocol)://$($ComputerName):$($Port)"
        } else {
          $serverUri = "$($Protocol)://$($ComputerName)"
        }
        Write-Verbose "[INFO] Server Uri: $($serverUri)"

        #If parameters found, add them to the end of the uri
        if ($parameterList) {
            $uri = "$($serverUri)$($Key)$($parameterList)"
        } else {
            $uri = "$($serverUri)$($Key)"
        }
        Write-Verbose "[INFO] uri: $($uri)"
        
        $result = Invoke-RestMethod -Uri $uri -Method $method -Headers $headers -ErrorVariable resultError
        if ($result.node.dir) {
            Write-Verbose "[INFO] Directory"
            #$result.node.nodes
        } else {
            Write-Verbose "[INFO] Node"
            #$result.node.value
        }
        $result.node
    }
}
