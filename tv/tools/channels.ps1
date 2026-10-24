param(
    [Parameter(Mandatory = $true)][string]$TvHost,
    # Channel (row) names to switch OFF, exactly as the list shows them.
    [Parameter(Mandatory = $true)][string[]]$Off,
    # Apps whose row opens a sub-list of several channels: every channel in it goes OFF. Use with care.
    [string[]]$OffGroups = @(),
    [switch]$DryRun,
    # Local CleanYourTV clone, by default next to this repository.
    [string]$Repo = (Join-Path $PSScriptRoot '../../../cleanyourtv')
)
. (Join-Path $PSScriptRoot 'common.ps1')
# Stock Android TV (tvlauncher, Android 9-14) home screen: walk Settings > Home screen > Customize
# channels and switch off the named rows. Prints every row it sees, so run with -DryRun first.
# Afterwards: am force-stop com.google.android.tvlauncher, then Home, or the old rows stay cached.
# Example: tools\channels.ps1 -TvHost 192.168.1.50 -Off 'Основні сервіси Android TV','Netflix' -DryRun
$env:TV_HOST = $TvHost
Assert-TvReachable $TvHost
$py = Get-CytPython $Repo
$tv = "$Repo/tools/tv.py"
$local = Get-TempFile "tv-ch-$($TvHost -replace '\W','_').xml"
function Send([string[]]$c) { $c | & $py -I $tv --batch | Out-Null }

function Focused {
    Send 'uiautomator dump /sdcard/c.xml >/dev/null 2>&1'
    & $py -I $tv --pull /sdcard/c.xml $local | Out-Null
    $x = [IO.File]::ReadAllText($local, [Text.Encoding]::UTF8)
    $f = [regex]::Match($x, '<node [^>]*focused="true"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"')
    if (-not $f.Success) { return $null }
    $t = [int]$f.Groups[2].Value; $b = [int]$f.Groups[4].Value
    $texts = @(); $sw = ''
    foreach ($n in [regex]::Matches($x, '<node [^>]*>')) {
        $m = [regex]::Match($n.Value, 'bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"')
        if ([int]$m.Groups[2].Value -ge $t -and [int]$m.Groups[4].Value -le $b) {
            $tx = [System.Net.WebUtility]::HtmlDecode([regex]::Match($n.Value, ' text="([^"]*)"').Groups[1].Value)
            if ($n.Value -match 'class="android.widget.Switch"') { $sw = [regex]::Match($n.Value, 'checked="([a-z]+)"').Groups[1].Value }
            elseif ($tx) { $texts += $tx }
        }
    }
    [pscustomobject]@{ Text = ($texts -join ' | '); Name = $texts[0]; Switch = $sw }
}

Send 'am start -n com.google.android.tvlauncher/.settings.HomeScreenSettingsActivity'
Start-Sleep 3
Send 'input keyevent KEYCODE_DPAD_CENTER'      # first item: Customize channels
Start-Sleep 3
Send (1..30 | ForEach-Object { 'input keyevent KEYCODE_DPAD_UP' })

$last = ''
for ($i = 0; $i -lt 60; $i++) {
    $f = Focused
    if (-not $f -or $f.Text -eq $last) { break }   # bottom of the list
    $last = $f.Text
    if ($OffGroups -contains $f.Name) {
        "group $($f.Text)"
        if (-not $DryRun) {
            Send 'input keyevent KEYCODE_DPAD_CENTER'; Start-Sleep 2
            $subLast = ''
            for ($j = 0; $j -lt 15; $j++) {
                $s = Focused
                if (-not $s -or $s.Text -eq $subLast) { break }
                $subLast = $s.Text
                if ($s.Switch -eq 'true') { Send 'input keyevent KEYCODE_DPAD_CENTER'; Start-Sleep 1; "  OFF  $($s.Text)" }
                else { "  keep $($s.Text) switch=$($s.Switch)" }
                Send 'input keyevent KEYCODE_DPAD_DOWN'; Start-Sleep 1
            }
            Send 'input keyevent KEYCODE_BACK'; Start-Sleep 2
        }
    } elseif ($Off -contains $f.Name -and $f.Switch -eq 'true') {
        if ($DryRun) { "would OFF  $($f.Text)" }
        else { Send 'input keyevent KEYCODE_DPAD_CENTER'; Start-Sleep 1; "OFF  $($f.Text) (now: $((Focused).Switch))" }
    } else {
        "keep $($f.Text) switch=$($f.Switch)"
    }
    Send 'input keyevent KEYCODE_DPAD_DOWN'; Start-Sleep 1
}
