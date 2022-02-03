function Convert-etcdTimeStamp
{
<#
.SYNOPSIS
  Converts etcd timestamp to the Local DateTime
.DESCRIPTION
  Takes an etcd2 timestamp like _datemodified and converts it to a datetime
  object in local time
.EXAMPLE
  PS> Convert-etcdTimeStamp -Time 1619773066504

  Friday, 30 April 2021 6:57:46 PM

.EXAMPLE
  PS> 1619773066504 | Convert-etcdTimeStamp

  Friday, 30 April 2021 6:57:46 PM
#>
Param
(
    [parameter(Mandatory,ValueFromPipeline)]
    [int64]$Time
)

    [System.DateTimeOffset]::FromUnixTimeMilliseconds($Time).LocalDateTime

}
