param(
    [Parameter(Mandatory = $true)][string]$TvHost,
    # Measure once the TV has been up this many seconds (match the "before" measurement).
    [int]$Uptime = 450,
    # Reboot first (the usual "after" measurement). Without it, measures now / waits for $Uptime.
    [switch]$Reboot,
    # Local CleanYourTV clone, by default next to this repository.
    [string]$Repo = (Join-Path $PSScriptRoot '..\..\..\cleanyourtv')
)
# Fair memory measurement: same uptime before and after. Prints uptime, MemAvailable, swap used,
# what HOME is, disabled-package count and the top processes by PSS. Takes ~8-10 min with -Reboot:
# run it in the background.
$env:TV_HOST = $TvHost
$py = "$Repo\tools\venv\Scripts\python.exe"
$ip = ($TvHost -split ':')[0]
if ($Reboot) {
    $j = Start-Job { param($py, $repo, $h) $env:TV_HOST = $h; & $py -I "$repo\tools\tv.py" 'reboot' } -ArgumentList $py, $Repo, $TvHost
    Start-Sleep 25; Stop-Job $j -ErrorAction SilentlyContinue; Remove-Job $j -Force
}
$t = Get-Date; $u = 0
while (((Get-Date) - $t).TotalSeconds -lt 900) {
    if (Test-NetConnection $ip -Port 5555 -InformationLevel Quiet -WarningAction SilentlyContinue) {
        $o = & $py -I "$Repo\tools\tv.py" 'getprop sys.boot_completed; cat /proc/uptime' 2>$null
        if ($o -and "$($o[0])".Trim() -eq '1') { $u = [double]("$($o[1])" -split ' ')[0]; if ($u -ge $Uptime) { break } }
    }
    Start-Sleep 20
}
"uptime=$u s"
& $py -I "$Repo\tools\tv.py" 'grep -E "MemTotal|MemAvailable|SwapTotal|SwapFree" /proc/meminfo; echo "disabled packages: $(pm list packages -d | wc -l)"; echo "HOME: $(cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME | tail -1)"; dumpsys meminfo | grep -A25 "Total PSS by process"'
