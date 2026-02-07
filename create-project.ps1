# Shim for bin/create-project.ps1
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
& "$scriptDir\bin\create-project.ps1" @args
