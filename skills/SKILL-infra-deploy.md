---
name: minha-banda-infra-deploy
description: Infraestrutura e deploy do projeto Minha Banda. Carregar quando trabalhar em: configuração do Render, variáveis de ambiente, Dockerfile, GitHub Actions, Neon/Postgres, Cloudflare R2, ou qualquer problema de deploy/infraestrutura.
---

# Minha Banda — Infraestrutura & Deploy

## Stack de infra (100% gratuita, modelo Na Rota da Serra)

| Camada | Serviço | Tier | Limite relevante |
|---|---|---|---|
| Backend | Render | Free | 512 MB RAM, 0.1 CPU, suspend após 15 min |
| Banco | Neon Postgres 16 | Free | 0,5 GB storage, suspend após 5 min |
| Keep-alive | GitHub Actions | Free | 2.000 min/mês (sobra muito) |
| Backup | GitHub Actions Artifacts | Free | 30 dias de retenção |
| Storage assets | Cloudflare R2 | Free | 10 GB, 10 M leituras/mês |
| CDN + DNS + TLS | Cloudflare | Free | Proxy, HTTPS, DDoS básico |
| CI/CD | GitHub Actions | Free | 2.000 min/mês |

## Configuração Render

**`render.yaml`** (na raiz de `minha_banda_server/`):
```yaml
services:
  - type: web
    name: minha-banda-api
    runtime: docker
    plan: free
    rootDir: minha_banda_server
    dockerfilePath: ./Dockerfile
    healthCheckPath: /livez
    envVars:
      - key: DART_ENV
        value: production
      - key: DB_HOST
        fromDatabase:
          property: host
      # ... demais vars via Render dashboard ou render.yaml
```

**`Dockerfile`** (JIT, não AOT — respeita 512 MB):
```dockerfile
FROM dart:3.3-sdk AS runner
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN dart pub get --no-example
COPY . .
EXPOSE 8080
CMD ["dart", "run", "bin/main.dart"]
```

> **Não usar `dart compile exe`** (AOT) no Render free tier — consome mais RAM durante o boot e pode estourar o limite de 512 MB. Usar `dart run` (JIT) como no Na Rota da Serra.

## Variáveis de ambiente obrigatórias

```
# Serverpod
SERVERPOD_DATABASE_HOST=<neon-host>.neon.tech
SERVERPOD_DATABASE_PORT=5432
SERVERPOD_DATABASE_NAME=minha_banda
SERVERPOD_DATABASE_USER=<user>
SERVERPOD_DATABASE_PASS=<password>
SERVERPOD_DATABASE_REQUIRE_SSL=true

# JWT / Auth
SERVERPOD_API_KEY=<random-256-bit>

# Cloudflare R2
R2_ACCOUNT_ID=<cf-account>
R2_ACCESS_KEY_ID=<key>
R2_SECRET_ACCESS_KEY=<secret>
R2_BUCKET=minha-banda-assets
R2_PUBLIC_URL=https://assets.minha-banda.com.br

# FCM (push notifications)
FCM_SERVER_KEY=<firebase-key>
```

## GitHub Actions Workflows

### `.github/workflows/backend-ci.yml`
```yaml
name: Backend CI
on:
  push:
    branches: [main]
  pull_request:
    paths:
      - 'minha_banda_server/**'
      - 'minha_banda_client/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dart-lang/setup-dart@v1
        with:
          sdk: '3.3'
      - run: dart pub get
        working-directory: minha_banda_server
      - run: dart analyze --fatal-infos
        working-directory: minha_banda_server
      - run: dart test --reporter=expanded
        working-directory: minha_banda_server
```

### `.github/workflows/backend-keepalive.yml`
```yaml
name: Backend Keep-Alive
on:
  schedule:
    - cron: '*/4 * * * *'   # a cada 4 minutos
  workflow_dispatch:

jobs:
  ping:
    runs-on: ubuntu-latest
    steps:
      - name: Ping health endpoint
        run: |
          curl -fsS https://api.minha-banda.com.br/livez || echo "Health check failed"
```

### `.github/workflows/backend-backup.yml`
```yaml
name: Daily Postgres Backup
on:
  schedule:
    - cron: '0 6 * * *'    # 06:00 UTC = 03:00 Brasília
  workflow_dispatch:

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - name: Dump Neon Postgres
        run: |
          docker run --rm \
            -e PGPASSWORD=${{ secrets.NEON_DB_PASSWORD }} \
            postgres:16 \
            pg_dump \
              --host=${{ secrets.NEON_DB_HOST }} \
              --port=5432 \
              --username=${{ secrets.NEON_DB_USER }} \
              --dbname=minha_banda \
              --format=c \
              --file=/tmp/backup.dump
          cp /tmp/backup.dump backup-$(date +%Y%m%d).dump

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: db-backup-${{ github.run_id }}
          path: backup-*.dump
          retention-days: 30
```

## Secrets necessários no GitHub

```
NEON_DB_HOST        → hostname do Neon (ex: ep-xxx.us-east-2.aws.neon.tech)
NEON_DB_USER        → usuário do Neon
NEON_DB_PASSWORD    → senha do Neon
NEON_DATABASE_URL   → postgres://user:pass@host/db?sslmode=require
```

## Keep-alive: por que é obrigatório

- **Render free tier**: suspende após 15 min sem requisição. Cold-start = ~10-20s. Inaceitável.
- **Neon free tier**: suspende após 5 min de inatividade. Cold-start = ~1-2s. Soma com Render = até 22s de espera.
- **Solução**: GitHub Actions pinga `/livez` a cada 4 min. Mantém ambos acordados 24/7.
- O endpoint `/livez` do Serverpod responde sem tocar o banco (health check superficial) — ideal para keep-alive.

## Cloudflare R2 — configuração

1. Criar bucket `minha-banda-assets` na conta Cloudflare.
2. Configurar domínio customizado `assets.minha-banda.com.br` apontando para o bucket.
3. Usar SDK S3-compatible do Serverpod (já suporta S3 + endpoint customizado):
   ```dart
   // serverpod config (config/production.yaml)
   storage:
     public:
       bucketName: minha-banda-assets
       region: auto
       endpoint: https://<account-id>.r2.cloudflarestorage.com
       publicEndpointEnabled: true
       publicEndpoint: https://assets.minha-banda.com.br
   ```

## Passos para subir do zero

1. `git init` e push para GitHub.
2. Criar projeto no Neon, copiar `DATABASE_URL`.
3. Criar service no Render, apontar para o repositório, configurar vars de ambiente.
4. Criar bucket no Cloudflare R2, configurar CORS.
5. Criar secrets no GitHub (`NEON_DB_*`).
6. Criar os três workflows em `.github/workflows/`.
7. Push em `main` → Render deploya automaticamente.
8. Verificar `https://api.minha-banda.com.br/livez` → `{"status":"ok"}`.
