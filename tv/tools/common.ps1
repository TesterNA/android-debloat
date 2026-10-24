# Shared helpers for tools/*.ps1, dot-sourced. Works in Windows PowerShell 5.1 and in PowerShell 7 (pwsh)
# on Windows, macOS and Linux.

# Python inside CleanYourTV's venv: Scripts\python.exe on Windows, bin/python elsewhere.
function Get-CytPython([string]$Repo) {
    foreach ($p in "$Repo/tools/venv/Scripts/python.exe", "$Repo/tools/venv/bin/python") {
        if (Test-Path $p) { return (Resolve-Path $p).Path }
    }
    throw "No venv in $Repo/tools/venv: run scripts/update.ps1 or scripts/update.sh from the repo root first."
}

# TCP check without Test-NetConnection, which only exists on Windows.
function Test-TvPort([string]$TvHost, [int]$Port = 5555, [int]$TimeoutMs = 3000) {
    $parts = $TvHost -split ':'
    if ($parts.Count -gt 1) { $Port = [int]$parts[1] }
    $client = New-Object System.Net.Sockets.TcpClient
    try { return $client.ConnectAsync($parts[0], $Port).Wait($TimeoutMs) } catch { return $false } finally { $client.Dispose() }
}

function Assert-TvReachable([string]$TvHost) {
    if (-not (Test-TvPort $TvHost)) { throw "$TvHost does not answer on its ADB port: is the TV on and USB debugging enabled?" }
}

function Get-TempFile([string]$Name) { Join-Path ([System.IO.Path]::GetTempPath()) $Name }
