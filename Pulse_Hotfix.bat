@echo off
rem  Pulse hotfix: upgrades an old Pulse (the first "Release", which has no updater and broken macros)
rem  to the newest version from GitHub. Put this file next to pulse_autoclicker.exe and double-click it,
rem  or drag your old pulse_autoclicker.exe onto it. After this, Pulse updates itself (Settings > Updates).
set "PULSE_BAT=%~f0"
set "PULSE_TARGET=%~1"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$t=[IO.File]::ReadAllText($env:PULSE_BAT); iex $t.Substring($t.IndexOf('#'+'#PS'))"
if not defined PULSE_NOSTART timeout /t 6 >nul
exit /b
##PS
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = 'https://github.com/purelypassion/pulse_autoclicker/raw/main/pulse_autoclicker.exe'
try {
    $target = $env:PULSE_TARGET
    if (-not $target) { $target = Join-Path (Split-Path $env:PULSE_BAT) 'pulse_autoclicker.exe' }
    $target = [IO.Path]::GetFullPath($target)
    Write-Host ''
    Write-Host '  Pulse hotfix' -ForegroundColor Cyan
    Write-Host ('  Updating: ' + $target)
    $running = Get-Process | Where-Object { $_.Path -eq $target }
    if ($running) { Write-Host '  Closing the running Pulse...'; $running | Stop-Process -Force; Start-Sleep 2 }
    Write-Host '  Downloading the newest version from GitHub...'
    $new = $target + '.new'
    Invoke-WebRequest -Uri $url -OutFile $new -UseBasicParsing -UserAgent 'Pulse-Hotfix'
    $len = (Get-Item $new).Length
    $head = [IO.File]::ReadAllBytes($new)[0..1]
    if ($len -lt 5MB -or $head[0] -ne 0x4D -or $head[1] -ne 0x5A) { throw 'the download is not a valid Pulse program' }
    if (Test-Path $target) { Move-Item $target ($target + '.old') -Force }
    Move-Item $new $target -Force
    Write-Host '  Done! Your old version is kept as pulse_autoclicker.exe.old' -ForegroundColor Green
    if (-not $env:PULSE_NOSTART) { Start-Process $target }
} catch {
    Write-Host ('  Failed: ' + $_.Exception.Message) -ForegroundColor Red
    Write-Host '  Your Pulse was not changed (or the old one is kept as .old). Check your internet and try again.'
    if (Test-Path ($target + '.new')) { Remove-Item ($target + '.new') -Force }
}
