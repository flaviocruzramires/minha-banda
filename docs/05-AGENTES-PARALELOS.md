# Minha Banda — Guia de Agentes Paralelos

> Como distribuir o trabalho entre múltiplos agentes Claude Code sem conflito, maximizando produtividade em sessões simultâneas.

## Princípio fundamental

Cada agente tem **escopo exclusivo de arquivos**. Dois agentes nunca tocam o mesmo arquivo ao mesmo tempo. O conflito de merge é o único problema a evitar — e ele é evitado por divisão de domínio, não por coordenação em tempo real.

---

## Mapa de Agentes por Fase

### Fase 0 — Setup (1 agente, sequencial)

Deve ser feito antes de qualquer paralelismo:

```
Agente SETUP
  ├── git init + estrutura de pastas
  ├── Serverpod scaffold (minha_banda_server / client / flutter)
  ├── Neon: criar banco, aplicar schema inicial
  ├── Render: criar service, configurar vars de ambiente
  ├── .github/workflows/ (ci + keepalive + backup)
  └── Dockerfile (JIT Dart, healthCheckPath /livez)
  Skill: SKILL-infra-deploy.md
```

**Entregável obrigatório antes de avançar**: `dart run bin/main.dart` no Render respondendo `/livez` com `{"status":"ok"}`.

---

### Fase 1 — Auth + Banda + Membership (sequencial, base de tudo)

```
Agente AUTH-BACKEND
  ├── minha_banda_server/lib/src/auth/         (exclusivo)
  ├── minha_banda_server/lib/src/bandas/       (exclusivo)
  ├── minha_banda_server/config/generator.yaml (exclusivo durante esta fase)
  └── migrations/                              (exclusivo)
  Skills: SKILL-backend-serverpod.md + SKILL-minha-banda-contexto.md
```

**Entregável obrigatório antes de avançar**: endpoints de login, cadastro de banda, convidar integrante — todos com teste de integração passando.

---

### Fase 2 — Paralelismo começa aqui

Após Fase 1 completa, os seguintes agentes podem rodar **simultaneamente** pois não tocam nos mesmos arquivos:

```
┌─────────────────────────────────────────────────────────────┐
│ Agente REPERTORIO-BACKEND           Agente AUTH-FRONTEND    │
│  minha_banda_server/src/repertorio/ apps/flutter/auth/      │
│  migrations/ (nova, com prefixo único)  apps/flutter/bandas/│
│  Skill: SKILL-backend-serverpod.md  Skill: SKILL-frontend-flutter.md │
└─────────────────────────────────────────────────────────────┘
```

**Regra de migração**: cada agente de backend usa um prefixo numérico exclusivo para o arquivo de migration (`20240101_repertorio_`, `20240101_locais_`, etc.) para evitar conflito de nome.

---

### Fase 3 — Locais + Eventos (paralelo)

```
┌──────────────────────────────────────────────────────────────────┐
│ Agente LOCAIS-BACKEND        Agente REPERTORIO-FRONTEND          │
│  src/locais/                  apps/flutter/repertorio/           │
│  Skills: SKILL-backend-serverpod.md  Skills: SKILL-frontend-flutter.md │
│                                                                  │
│ Agente EVENTOS-BACKEND       Agente LOCAIS-FRONTEND              │
│  src/eventos/                 apps/flutter/locais/               │
│  (depende de LOCAIS-BACKEND terminar primeiro)                   │
└──────────────────────────────────────────────────────────────────┘
```

---

### Fase 4 — Features avançadas (paralelo)

```
┌────────────────────────────────────────────────────────────────────┐
│ Agente CONFLITO-BACKEND      Agente TELEPROMPTER-BACKEND           │
│  src/conflitos/               src/teleprompter/                    │
│  Skill: SKILL-conflito-agenda.md  Skill: SKILL-teleprompter.md     │
│                                                                    │
│ Agente EVENTOS-FRONTEND      Agente AGENDA-FRONTEND                │
│  apps/flutter/eventos/        apps/flutter/agenda/                 │
│  Skills: SKILL-frontend-flutter.md                                 │
└────────────────────────────────────────────────────────────────────┘
```

---

### Fase 5 — Finalização (paralelo)

```
┌──────────────────────────────────────────────────────────────────┐
│ Agente CONFLITO-FRONTEND     Agente TELEPROMPTER-FRONTEND         │
│  apps/flutter/conflitos/      apps/flutter/teleprompter/          │
│  Skill: SKILL-conflito-agenda.md  Skill: SKILL-teleprompter.md    │
│                                                                   │
│ Agente NOTIFICACOES           Agente TESTES-E2E                   │
│  src/notificacoes/             test/integration/                  │
│  apps/flutter/notificacoes/    (somente leitura dos outros módulos)│
└──────────────────────────────────────────────────────────────────┘
```

---

## Tabela de Ownership de Arquivos

| Agente | Pastas/Arquivos exclusivos | Pode LER (não editar) |
|---|---|---|
| SETUP | `.github/`, `Dockerfile`, `render.yaml`, raiz | — |
| AUTH-BACKEND | `server/src/auth/`, `server/src/bandas/`, `migrations/` | — |
| REPERTORIO-BACKEND | `server/src/repertorio/`, `migrations/` | `src/auth/` (leitura) |
| LOCAIS-BACKEND | `server/src/locais/`, `migrations/` | `src/auth/` |
| EVENTOS-BACKEND | `server/src/eventos/`, `migrations/` | `src/bandas/`, `src/locais/` |
| CONFLITO-BACKEND | `server/src/conflitos/` | `src/eventos/`, `src/agenda/` |
| TELEPROMPTER-BACKEND | `server/src/teleprompter/` | `src/repertorio/`, `src/eventos/` |
| NOTIFICACOES | `server/src/notificacoes/` | todos os outros módulos |
| AUTH-FRONTEND | `flutter/lib/features/auth/`, `flutter/lib/features/bandas/` | `client/` (gerado) |
| REPERTORIO-FRONTEND | `flutter/lib/features/repertorio/` | `client/` (gerado) |
| LOCAIS-FRONTEND | `flutter/lib/features/locais/` | `client/` (gerado) |
| EVENTOS-FRONTEND | `flutter/lib/features/eventos/` | `client/` (gerado) |
| AGENDA-FRONTEND | `flutter/lib/features/agenda/` | `client/` (gerado) |
| CONFLITO-FRONTEND | `flutter/lib/features/conflitos/` | `client/` (gerado) |
| TELEPROMPTER-FRONTEND | `flutter/lib/features/teleprompter/` | `client/` (gerado) |
| TESTES-E2E | `test/integration/` | todos (somente leitura) |

> **Arquivo `client/`**: o `minha_banda_client/` é **gerado automaticamente** pelo Serverpod (`serverpod generate`). Nenhum agente edita esse diretório. O comando de geração é rodado pelo agente de backend após cada mudança de modelo, antes de o agente de frontend começar o módulo correspondente.

---

## Skills por Agente (o que carregar no início de cada sessão)

| Agente | Skills obrigatórias |
|---|---|
| Qualquer agente backend | `SKILL-minha-banda-contexto.md` + `SKILL-backend-serverpod.md` |
| Qualquer agente frontend | `SKILL-minha-banda-contexto.md` + `SKILL-frontend-flutter.md` |
| CONFLITO-BACKEND/FRONTEND | + `SKILL-conflito-agenda.md` |
| TELEPROMPTER-BACKEND/FRONTEND | + `SKILL-teleprompter.md` |
| SETUP / INFRA | `SKILL-minha-banda-contexto.md` + `SKILL-infra-deploy.md` |

---

## Protocolo de Handoff entre Agentes

Quando um agente BACKEND termina um módulo e o FRONTEND pode começar:

1. Agente backend roda `serverpod generate` → atualiza `minha_banda_client/`.
2. Agente backend commita tudo em `feature/<módulo>-backend`.
3. Agente backend registra no PR description quais endpoints estão disponíveis e quais tipos Dart foram gerados.
4. Agente frontend abre branch `feature/<módulo>-frontend`, parte dos tipos gerados.

---

## Regras anti-conflito

1. **Nunca dois agentes na mesma pasta de domínio** (`src/repertorio/` é de um agente só).
2. **Migrations com prefixo único por data+domínio**: `20240615_001_repertorio_create_musica.sql`.
3. **`config/generator.yaml` só muda no backend, nunca no frontend**.
4. **Shared widgets** (`flutter/lib/shared/`) só são editados pelo agente atual que precisa do widget — criar o widget e deixar pronto para os outros, não reescrever depois.
5. **Arquivos gerados** (`minha_banda_client/`) são somente-leitura para todos os agentes. Re-gerar é tarefa do agente backend.

---

## Ordem de execução resumida

```
[SETUP] → [AUTH-BACKEND] → [REPERTORIO-BACKEND] ─┐
                                                   ├─ paralelo ─→ [CONFLITO-BACKEND]
                         → [LOCAIS-BACKEND]       │               [TELEPROMPTER-BACKEND]
                         → [EVENTOS-BACKEND] ─────┘
                                                        ↕ (backend gera client, frontend começa)
                         [AUTH-FRONTEND] → [REPERTORIO-FRONTEND] → [EVENTOS-FRONTEND]
                                        → [LOCAIS-FRONTEND]      → [CONFLITO-FRONTEND]
                                                                  → [TELEPROMPTER-FRONTEND]

                         [NOTIFICACOES] → [TESTES-E2E]   ← entram por último, depois de tudo
```
