# Sobe o Evolution API para seu repositório no GitHub
# Uso: .\subir-github.ps1 -Usuario SEU_USUARIO
# Exemplo: .\subir-github.ps1 -Usuario joaosilva

param(
    [Parameter(Mandatory=$true)]
    [string]$Usuario
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$repoUrl = "https://github.com/$Usuario/evolution-api-lunins.git"

Write-Host "=== Evolution API - Subir para GitHub ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Crie o repositorio no GitHub (se ainda nao criou):" -ForegroundColor Yellow
Write-Host "   https://github.com/new?name=evolution-api-lunins" -ForegroundColor White
Write-Host "   Nome: evolution-api-lunins"
Write-Host "   Deixe vazio (sem README, sem .gitignore)"
Write-Host ""
Start-Process "https://github.com/new?name=evolution-api-lunins"
Write-Host "Pressione Enter apos criar o repositorio..." -ForegroundColor Gray
Read-Host

Write-Host "2. Configurando remote e enviando..." -ForegroundColor Green
git remote remove origin 2>$null
git remote add origin $repoUrl
git push -u origin main

Write-Host ""
Write-Host "Concluido! Repositorio: https://github.com/$Usuario/evolution-api-lunins" -ForegroundColor Green
