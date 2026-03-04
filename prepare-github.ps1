# Prepara Evolution API para push no seu repositório GitHub
# Uso: .\prepare-github.ps1 -RepoUrl "https://github.com/SEU_USUARIO/evolution-api-lunins.git"

param(
    [Parameter(Mandatory=$true)]
    [string]$RepoUrl
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

Write-Host "=== Evolution API - Preparar para GitHub ===" -ForegroundColor Cyan
Write-Host ""

# Remover remote origin antigo e adicionar o novo
git remote remove origin 2>$null
git remote add origin $RepoUrl
Write-Host "Remote configurado: $RepoUrl" -ForegroundColor Green

# Verificar se há alterações para commit
$status = git status --porcelain
if ($status) {
    git add .
    git add -f .env.example 2>$null
    git status
    Write-Host ""
    Write-Host "Execute para commitar e enviar:" -ForegroundColor Yellow
    Write-Host "  git commit -m `"Evolution API - config para Hostinger Node.js`""
    Write-Host "  git push -u origin main"
} else {
    Write-Host "Nenhuma alteracao pendente. Para enviar:" -ForegroundColor Yellow
    Write-Host "  git push -u origin main"
}
