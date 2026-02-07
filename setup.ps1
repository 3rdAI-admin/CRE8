# Shim for the actual setup script in bin/
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& (Join-Path $ScriptDir "bin\setup.ps1") @args
