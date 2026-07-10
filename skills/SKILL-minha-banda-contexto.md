---
name: minha-banda-contexto
description: Contexto mestre do projeto Minha Banda. Carregar sempre no início de qualquer sessão de desenvolvimento (Claude Code ou claude.ai) sobre este app, antes de qualquer skill específica de módulo.
---

# Minha Banda — Contexto do Projeto

## O que é
App de gestão de bandas de música: agenda, repertório, eventos (shows/ensaios), teleprompter, integrantes, locais de show e login único multi-perfil. Detalhes completos em `docs/01-ARQUITETURA.md` e `docs/02-FEATURES.md` — leia-os antes de propor qualquer mudança estrutural.

## Stack (não sugerir alternativas sem justificativa forte)
- Front-end: Flutter (mobile + web), state management com Riverpod.
- Backend: **Serverpod** (Dart) — endpoints, ORM, migrations, auth, tudo em `.yaml` + Dart gerado.
- Banco: **Neon** (Postgres 16 serverless, free tier) — acessado pelo Serverpod via URL de conexão.
- Deploy: **Render** (free tier, Docker runtime, JIT Dart), sem VPS, sem Oracle, sem Kubernetes — é um monólito modular Serverpod.
- Keep-alive: GitHub Actions pinga `/livez` a cada 4 min (Render suspende após 15 min, Neon após 5 min).
- Storage: **Cloudflare R2** (10 GB grátis, zero egress fee) para fotos, cifras em PDF, logo de local.
- Infra completa: ver `docs/01-ARQUITETURA.md` seção 3 e `skills/SKILL-infra-deploy.md`.

## Convenções de código
- Nomes de classes de modelo em português claro (`Banda`, `Evento`, `Musica`, `Membership`) — já validados no time do projeto, manter consistência com `docs/03-MODELO-DADOS.md`.
- Cada domínio (agenda, bandas, eventos, locais, repertório, teleprompter, conflitos, notificações) é uma pasta isolada em `lib/src/` no server — não misturar lógica de domínios diferentes num mesmo endpoint.
- Autorização **sempre no servidor**: todo endpoint que recebe `bandaId` ou `localId` precisa validar que o `AppUser` autenticado tem `Membership`/`ResponsavelLocal` ativo naquele recurso antes de responder qualquer coisa.
- Conflito de agenda nunca bloqueia ação — só avisa (ver `skills/SKILL-conflito-agenda.md`).

## Identidade visual (para telas/mockups)
- Paleta: preto-palco (`#151317`), âmbar de refletor (`#F2A93B`), vinho de cortina (`#7A1F3D`), branco quente (`#F7F3EC`), verde-âmbar de "confirmado" (`#4C7A5E`).
- Tipografia: display condensado tipo pôster de show para títulos, sans neutra e muito legível para corpo (crítico no teleprompter).
- Elemento de assinatura: motivo de "ticket de show" (borda serrilhada/picotada) usado em cards de evento; indicadores tipo VU-meter para status de confirmação.
- Tema escuro é o padrão do app inteiro (uso em ambiente de palco/ensaio com pouca luz), não só do teleprompter.

## Como trabalhar módulo a módulo
Ao pedir para desenvolver uma feature específica, carregar também a skill do módulo correspondente:
- `SKILL-backend-serverpod.md` — para qualquer endpoint/modelo novo.
- `SKILL-frontend-flutter.md` — para qualquer tela nova.
- `SKILL-conflito-agenda.md` — para qualquer coisa envolvendo o motor de conflito.
- `SKILL-teleprompter.md` — para a experiência de performance ao vivo.
- `SKILL-infra-deploy.md` — para configuração de Render, Neon, R2, GitHub Actions.

## Trabalho com múltiplos agentes em paralelo
Ver `docs/05-AGENTES-PARALELOS.md` para o mapa completo de quais agentes podem rodar simultaneamente e quais arquivos são exclusivos de cada um. O princípio: cada agente tem ownership de uma pasta de domínio inteira — nunca dois agentes no mesmo diretório ao mesmo tempo.

## Definição de pronto (Definition of Done)
Ver checklist completo em `docs/04-HARNESS-DESENVOLVIMENTO.md`. Resumo: modelo `.yaml` + migration revisada, endpoint com validação de autorização, teste de integração do endpoint, tela Flutter com estado de loading/erro/vazio, responsivo mobile+web.
