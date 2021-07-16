<#
.SYNOPSIS
    check_top_processes.ps1 - Script checks top processes memory consumption
.DESCRIPTION
    Using this script you are able to monitor processes which consume the most memory.
    For better readability, the result of the script is a table containing data about the processes.
.PARAMETER number
    Number of processes to monitor
  
.EXAMPLE
   ./check_top_processes.sh  -n 3
#>

[CmdletBinding(DefaultParameterSetName='args')]
param (
    [Parameter()][int]$number
)

# Convert from B to MB
function toMegaBytes {
    param (
        $value
    )

    # Expect bytes so it has to be int
    if (-not $value -is [int]) { Throw "Only integer can be cast to MB" }

    return ($value / (1000 * 1000))
}

# Convert from MB to B
function toBytes {
    param (
        $value
    )
    
    # Expect bytes so it has to be int
    if (-not $value -is [double]) { Throw "Only integer can be cast to MB" }

    return ($value * (1000 * 1000))
}

# By default check top1 process
if (-not $number) { $number = 1 }

$PROCESSES=(Get-Counter "\Process(*)\Working Set - Private" 2>$null).CounterSamples
$DICT=@{}

for ($i = 0; $i -lt $PROCESSES.Count; $i++) {
    # Cast value to MB for pretty plugin output
    $DICT[$PROCESSES[$i].InstanceName] += $(toMegaBytes $PROCESSES[$i].CookedValue)
}

$COUNT = $DICT.Count
$TOPPROCESSES = ($DICT.GetEnumerator() `
    | Sort-Object { $_.Value } -Descending) `
    | Select-Object -Skip 1 -First $number

# Plugin output
Write-Output "[OK]: Top $(if ($number -lt $COUNT) { Write-Output $number } else { Write-Output $COUNT })  $(if ($number -gt 1) { Write-Output "processes" } else { Write-Output "process" }):"
Write-Output $TOPPROCESSES

# Graphite output
Write-Host -NoNewline " | "
for ($i = 0; $i -lt $TOPPROCESSES.Count; $i++) {
    Write-Host -NoNewline "$($TOPPROCESSES[$i].Name -replace '\s','_')=$(toBytes $TOPPROCESSES[$i].Value);;;0; "
}

exit 0