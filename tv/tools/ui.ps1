param(
    [Parameter(Mandatory = $true)][string]$TvHost,
    [string]$Keys = '',
    [int]$Wait = 2,
    # Local CleanYourTV clone, by default next to this repository.
    [string]$Repo = (Join-Path $PSScriptRoot '../../../cleanyourtv')
)
. (Join-Path $PSScriptRoot 'common.ps1')
# Press remote keys on the TV, then print what is on screen AS TEXT (uiautomator), so menus can be
# navigated even where screenshots come back empty (Live TV, HDMI, protected windows).
#   >> = focused element, * = selected; bounds and class follow each line.
# Keys: space-separated KEYCODE_* names; "start:<pkg>/<activity>" launches a screen.
# Example: tools\ui.ps1 -TvHost 192.168.1.50 -Keys 'KEYCODE_MENU KEYCODE_DPAD_RIGHT' -Wait 1
$env:TV_HOST = $TvHost
Assert-TvReachable $TvHost
$py = Get-CytPython $Repo
$tv = "$Repo/tools/tv.py"
$local = Get-TempFile "tv-ui-$($TvHost -replace '\W','_').xml"
$cmds = @()
foreach ($k in ($Keys -split ' ' | Where-Object { $_ })) {
    if ($k -like 'start:*') { $cmds += "am start -n $($k.Substring(6))" } else { $cmds += "input keyevent $k" }
}
$cmds += "sleep $Wait; uiautomator dump /sdcard/u.xml >/dev/null 2>&1"
$cmds | & $py -I $tv --batch 2>&1 | Out-Null
& $py -I $tv --pull /sdcard/u.xml $local | Out-Null
& $py -I $tv 'rm -f /sdcard/u.xml' | Out-Null
$xml = [System.IO.File]::ReadAllText($local, [System.Text.Encoding]::UTF8)
foreach ($n in [regex]::Matches($xml, '<node [^>]*>')) {
    $t = [System.Net.WebUtility]::HtmlDecode([regex]::Match($n.Value, ' text="([^"]*)"').Groups[1].Value)
    $d = [System.Net.WebUtility]::HtmlDecode([regex]::Match($n.Value, ' content-desc="([^"]*)"').Groups[1].Value)
    $f = $n.Value -match 'focused="true"'
    $s = $n.Value -match 'selected="true"'
    $c = [regex]::Match($n.Value, 'checked="([a-z]+)"').Groups[1].Value
    $b = [regex]::Match($n.Value, ' bounds="([^"]*)"').Groups[1].Value
    $cl = [regex]::Match($n.Value, ' class="[^"]*\.([^".]*)"').Groups[1].Value
    if ($n.Value -notmatch 'checkable="true"') { $c = '' }
    if ($t -or $d -or $f -or $c) {
        '{0}{1} {2} {3} {4}  {5} {6}' -f ($(if ($f) { '>>' } else { '  ' })), ($(if ($s) { '*' } else { ' ' })), $t,
            $(if ($d) { "[$d]" }), $(if ($c) { "checked=$c" }), $b, $cl
    }
}
