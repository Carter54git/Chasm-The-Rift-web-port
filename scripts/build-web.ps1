# Chasm: The Rift (PanzerChasm) — Emscripten web build
param(
    [string]$EmsdkRoot = (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'bloodweb\emsdk')
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path $PSScriptRoot -Parent
$Src = Join-Path $Root 'Chasm-Reverse'
$Web = Join-Path $Root 'web'
$Build = Join-Path $Src 'build-wasm'
$EnvPs1 = Join-Path $EmsdkRoot 'emsdk_env.ps1'
$Gamefiles = Join-Path $Root 'gamefiles'
$DefaultGameSrc = Join-Path ([Environment]::GetFolderPath('Desktop')) 'AwesomeChasm-main\game\CSM.BIN'

if (-not (Test-Path $EnvPs1)) {
    Write-Error "Emscripten not found at $EmsdkRoot"
}

if (-not (Test-Path (Join-Path $Gamefiles 'CSM.BIN'))) {
    if (Test-Path $DefaultGameSrc) {
        Write-Host '==> Importing CSM.BIN from AwesomeChasm-main\game'
        Copy-Item $DefaultGameSrc (Join-Path $Gamefiles 'CSM.BIN') -Force
    } else {
        Write-Warning 'Missing gamefiles\CSM.BIN'
    }
} else {
    Write-Host '==> Using gamefiles\CSM.BIN'
}

$DefaultCfgSrc = Join-Path $Src 'default_PanzerChasm.cfg'
$CfgDest = Join-Path $Gamefiles 'PanzerChasm.cfg'
if (-not (Test-Path $CfgDest) -and (Test-Path $DefaultCfgSrc)) {
    Copy-Item $DefaultCfgSrc $CfgDest -Force
}

New-Item -ItemType Directory -Force -Path $Web, $Gamefiles | Out-Null

Write-Host '==> Configuring PanzerChasm (Emscripten)'
& $EnvPs1 | Out-Null
if (-not (Get-Command emcc -ErrorAction SilentlyContinue)) {
    throw 'emcc not in PATH after emsdk_env.ps1'
}

if (Test-Path $Build) { Remove-Item $Build -Recurse -Force }
New-Item -ItemType Directory -Force -Path $Build | Out-Null
Push-Location $Build
try {
    emcmake cmake .. -DCMAKE_BUILD_TYPE=Release
    if ($LASTEXITCODE -ne 0) { throw 'cmake configure failed' }
    emmake cmake --build . --target PanzerChasm -j 4
    if ($LASTEXITCODE -ne 0) { throw 'cmake build failed' }
} finally {
    Pop-Location
}

$buildId = Get-Date -Format 'yyyyMMddHHmmss'
foreach ($f in @('PanzerChasm.js', 'PanzerChasm.wasm', 'PanzerChasm.data')) {
    $srcFile = Join-Path $Build $f
    if (Test-Path $srcFile) {
        Copy-Item $srcFile (Join-Path $Web $f) -Force
        Write-Host "  $f ($((Get-Item (Join-Path $Web $f)).Length) bytes)"
    }
}

$runHtml = Join-Path $Web 'run.html'
if (Test-Path $runHtml) {
    $html = Get-Content $runHtml -Raw
    $html = $html -replace "var buildTag\s+=\s+'[^']*';", "var buildTag   = '$buildId';"
    Set-Content $runHtml $html.TrimEnd() -NoNewline
}

$shadersSrc = Join-Path $Src 'shaders'
$shadersDest = Join-Path $Web 'shaders'
if (Test-Path $shadersSrc) {
    if (Test-Path $shadersDest) { Remove-Item $shadersDest -Recurse -Force }
    Copy-Item -Path $shadersSrc -Destination $shadersDest -Recurse -Force
}

$iconSrc = Join-Path ([Environment]::GetFolderPath('Desktop')) 'AwesomeChasm-main\game\CHASM.ICO'
if (Test-Path $iconSrc) {
    Copy-Item $iconSrc (Join-Path $Web 'favicon.ico') -Force
}

Write-Host ''
Write-Host "Build id: $buildId"
Write-Host 'Done. Run:  cd web; python serve.py'
Write-Host 'Open:     http://127.0.0.1:8771/run.html'
