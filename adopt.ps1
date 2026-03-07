param(
  [string]$Tool = "claude",
  [string]$Target = "",
  [string]$Source = "",
  [switch]$Yes
)

$ErrorActionPreference = "Stop"

function Fail($Message) {
  Write-Host "[ERRO] $Message" -ForegroundColor Red
  exit 1
}

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  Fail "Node.js nao encontrado. Instale em: https://nodejs.org"
}

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
  Fail "npm nao encontrado. Verifique a instalacao do Node.js"
}

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $Target) {
  $Target = (Get-Location).Path
}

Push-Location $Root
try {
  if (-not (Test-Path "dist/adopt.js")) {
    Write-Host "[INFO] Build nao encontrado. Instalando dependencias e compilando..." -ForegroundColor Blue
    npm install
    if ($LASTEXITCODE -ne 0) {
      Fail "Falha ao executar npm install"
    }

    npm run build
    if ($LASTEXITCODE -ne 0) {
      Fail "Falha ao executar npm run build"
    }
  }

  $ArgsList = @("dist/adopt.js", "--tool", $Tool, "--target", $Target)
  if ($Source) {
    $ArgsList += @("--source", $Source)
  }
  if ($Yes) {
    $ArgsList += "--yes"
  }

  node @ArgsList
  if ($LASTEXITCODE -ne 0) {
    Fail "Falha ao executar CLI de adocao"
  }
}
finally {
  Pop-Location
}
