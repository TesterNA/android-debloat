# Bring this repo and every repo it depends on to the newest version. Safe to run any time.
#   powershell -ExecutionPolicy Bypass -File scripts\update.ps1
# Dependencies are cloned next to this repo (in its parent folder). A repo with local changes that
# block a fast-forward is left alone and reported: nothing is ever reset, stashed or overwritten.
$root = Split-Path -Parent $PSScriptRoot
$parent = Split-Path -Parent $root
# Keep in sync with scripts/update.sh and the SOURCES.md files.
$deps = [ordered]@{
    'cleanyourtv' = 'https://github.com/Gathin23/cleanyourtv'
    'tv-detox'    = 'https://github.com/Ansub/tv-detox'
    'free-my-tv'  = 'https://github.com/simbasjungles/free-my-tv'
}
$script:status = 0

function Update-Clone([string]$dir, [string]$label) {
    $before = (git -C $dir rev-parse --short HEAD 2>$null)
    $err = git -C $dir pull --ff-only -q 2>&1
    if ($LASTEXITCODE -eq 0) {
        $after = (git -C $dir rev-parse --short HEAD)
        if ($before -eq $after) { "ok       $label  up to date ($after)" } else { "updated  $label  $before -> $after" }
    } else {
        "BLOCKED  $label  $(($err | Select-Object -First 1))  (local changes or conflict: ask the user, do not reset)"
        $script:status = 1
    }
}

git -C $root remote get-url origin *> $null
if ($LASTEXITCODE -eq 0) { Update-Clone $root 'android-debloat' }

foreach ($name in $deps.Keys) {
    $dir = Join-Path $parent $name
    if (Test-Path (Join-Path $dir '.git')) { Update-Clone $dir $name }
    elseif (Test-Path $dir) { "BLOCKED  $name  $dir exists but is not a git clone" }
    else {
        git clone -q $deps[$name] $dir
        if ($LASTEXITCODE -eq 0) { "cloned   $name  $(git -C $dir rev-parse --short HEAD)" } else { $script:status = 1 }
    }
}

# CleanYourTV's ADB client (adb-shell) lives in a venv inside its clone.
$cyt = Join-Path $parent 'cleanyourtv'
if ((Test-Path "$cyt/tools/requirements.txt") -and -not (Test-Path "$cyt/tools/venv")) {
    # A Python 3 that really runs (on Windows "python3" can be a Microsoft Store stub).
    $py = $null
    foreach ($c in 'python3', 'python', 'py') {
        if (Get-Command $c -ErrorAction SilentlyContinue) {
            & $c -c 'import sys; sys.exit(sys.version_info[0] != 3)' *> $null
            if ($LASTEXITCODE -eq 0) { $py = $c; break }
        }
    }
    if ($py) {
        & $py -m venv "$cyt/tools/venv"
        # Scripts\python.exe on Windows, bin/python on macOS / Linux (pwsh).
        $vpy = @("$cyt/tools/venv/Scripts/python.exe", "$cyt/tools/venv/bin/python") | Where-Object { Test-Path $_ } | Select-Object -First 1
        if ($vpy) { & $vpy -m pip install -q -r "$cyt/tools/requirements.txt" }
        if ($vpy -and $LASTEXITCODE -eq 0) { 'venv     cleanyourtv/tools/venv created' }
        else { 'FAILED   could not create cleanyourtv/tools/venv'; $script:status = 1 }
    } else { 'MISSING  Python 3: install it, then run this again (CleanYourTV needs it)'; $script:status = 1 }
}

# UAD-ng package database for phones (refresh if missing or older than 30 days).
$uad = Join-Path $root 'phone/uad/uad_lists.json'
if (-not (Test-Path $uad) -or ((Get-Date) - (Get-Item $uad).LastWriteTime).TotalDays -gt 30) {
    New-Item -ItemType Directory -Force (Split-Path $uad) | Out-Null
    try {
        Invoke-WebRequest -UseBasicParsing -OutFile $uad 'https://raw.githubusercontent.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation/main/resources/assets/uad_lists.json'
        Get-Date -Format 'yyyy-MM-dd' | Set-Content -Encoding ascii (Join-Path $root 'phone/uad/updated.txt')
        'updated  UAD-ng database'
    } catch { "FAILED   UAD-ng database update: $($_.Exception.Message)"; $script:status = 1 }
} else { "ok       UAD-ng database ($(Get-Content (Join-Path $root 'phone/uad/updated.txt') -ErrorAction SilentlyContinue))" }
exit $script:status
