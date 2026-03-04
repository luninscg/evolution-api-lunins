# Configura .env para usar Supabase (sem Docker)
# Uso: .\configurar-supabase.ps1

$ErrorActionPreference = "Stop"
$envPath = Join-Path $PSScriptRoot ".env"

Write-Host ""
Write-Host "=== Evolution API - Configurar para Supabase ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Voce vai precisar da senha do banco Supabase."
Write-Host "Ache em: Supabase Dashboard > Settings > Database > Database password"
Write-Host ""
$senha = Read-Host "Cole a senha do banco (ou Enter para pular)" -AsSecureString
$senhaTexto = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($senha))

if ([string]::IsNullOrWhiteSpace($senhaTexto)) {
    Write-Host "Pulando. Edite o .env manualmente com a connection string do Supabase." -ForegroundColor Yellow
    exit 0
}

$uri = "postgresql://postgres:$senhaTexto@db.pitexeomwpgpmczujovr.supabase.co:5432/postgres"
$uriEscaped = $uri -replace "'", "''"

$content = Get-Content $envPath -Raw
$content = $content -replace "DATABASE_CONNECTION_URI=.*", "DATABASE_CONNECTION_URI='$uriEscaped'"
$content = $content -replace "CACHE_REDIS_ENABLED=true", "CACHE_REDIS_ENABLED=false"
$content = $content -replace "CACHE_LOCAL_ENABLED=false", "CACHE_LOCAL_ENABLED=true"
Set-Content $envPath $content -NoNewline

Write-Host ""
Write-Host ".env configurado para Supabase!" -ForegroundColor Green
Write-Host "Proximo: npm run db:deploy:win && npm run start" -ForegroundColor Cyan
