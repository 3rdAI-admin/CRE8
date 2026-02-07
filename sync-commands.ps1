# Shim for the actual sync script in bin/
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& (Join-Path $ScriptDir "bin\sync-commands.ps1") @args
