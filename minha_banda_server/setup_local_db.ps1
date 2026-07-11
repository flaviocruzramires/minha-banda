# Script de criação do banco local para desenvolvimento
# Execute: .\setup_local_db.ps1 -PgPassword "sua_senha"

param(
    [Parameter(Mandatory=$true)]
    [string]$PgPassword,
    [string]$PgUser = "postgres",
    [string]$PgHost = "127.0.0.1",
    [string]$PgPort = "5432",
    [string]$DbName = "minha_banda"
)

$env:PGPASSWORD = $PgPassword

Write-Host "Criando banco '$DbName'..." -ForegroundColor Cyan
psql -U $PgUser -h $PgHost -p $PgPort -c "CREATE DATABASE $DbName;" 2>&1

Write-Host "Executando schema..." -ForegroundColor Cyan
psql -U $PgUser -h $PgHost -p $PgPort -d $DbName -f "$PSScriptRoot\database.sql" 2>&1

if ($?) {
    Write-Host "Banco criado com sucesso!" -ForegroundColor Green

    $dbUrl = "postgres://${PgUser}:${PgPassword}@${PgHost}:${PgPort}/${DbName}"
    $envContent = @"
DATABASE_URL=$dbUrl
JWT_SECRET=local-dev-secret-troque-em-producao-32chars!
JWT_EXPIRES_MINUTES=60
PORT=8080
HOST=0.0.0.0
DART_ENV=development
"@
    $envContent | Set-Content -Path "$PSScriptRoot\.env" -Encoding utf8
    Write-Host ".env criado em minha_banda_server/.env" -ForegroundColor Green
    Write-Host "DATABASE_URL=$dbUrl" -ForegroundColor Yellow
} else {
    Write-Host "Erro ao criar o banco. Verifique as credenciais." -ForegroundColor Red
}
