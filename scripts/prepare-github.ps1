# One-time prep before first git commit: init repo, remove nested .git dirs.
$ErrorActionPreference = 'Stop'
$Root = Split-Path $PSScriptRoot -Parent

$nested = @(
    (Join-Path $Root 'Chasm-Reverse\.git'),
    (Join-Path $Root 'Chasm-Reverse\src\panzer_ogl_lib\.git')
)

foreach ($p in $nested) {
    if (Test-Path $p) {
        Write-Host "Remove nested repo: $p"
        Remove-Item $p -Recurse -Force
    }
}

if (-not (Test-Path (Join-Path $Root '.git'))) {
    Push-Location $Root
    git init
    Pop-Location
    Write-Host 'Initialized git repository at' $Root
} else {
    Write-Host 'Git repo already exists at' $Root
}

Write-Host ''
Write-Host 'Next: git add . ; git status ; see GITHUB_PUBLISH.txt'
