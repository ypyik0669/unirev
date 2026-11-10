#Requires -Version 7
$ErrorActionPreference = 'Continue'
$root = Split-Path -Parent $PSScriptRoot
Write-Host '== unirev update =='

Write-Host '-- submodules (open-reverselab, reverse-skill) --'
git -C $root submodule update --remote --recursive

Write-Host '-- rea-agents --'
npm update -g rea-agents

Write-Host '-- craft-anything-cli: re-run install script for release refresh --'

Write-Host '-- re-run health checks --'
pwsh -NoProfile -File (Join-Path $PSScriptRoot 'install.ps1')
