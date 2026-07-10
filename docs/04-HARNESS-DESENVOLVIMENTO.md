# Minha Banda — Harness de Desenvolvimento

Como este projeto vai ser construído em sessões incrementais (sozinho e/ou com Claude Code), este documento fixa o "arnês" que mantém consistência entre sessões: estrutura de pastas, fluxo de trabalho, testes e critério de pronto.

## 1. Estrutura de repositório

```
minha_banda/
  minha_banda_server/      → Serverpod backend
  minha_banda_client/      → gerado automaticamente, NUNCA editar à mão
  minha_banda_flutter/     → app Flutter (mobile + web)
  docs/                    → este conjunto de documentos
  skills/                  → skills de contexto para sessões com IA
```

## 2. Ordem de construção recomendada (roadmap do MVP)

Construir na ordem abaixo evita depender de feature que ainda não existe:

1. **Auth + Cadastro de banda + Membership** (login único já nasce certo, resto depende disso).
2. **Cadastro de integrantes** (convite, papéis).
3. **Repertório** (CRUD de música — não depende de evento).
4. **Cadastro de locais e responsáveis**.
5. **Eventos** (junta banda + local + integrantes + setlist do repertório já existente).
6. **Motor de conflito de agenda** (só faz sentido depois de eventos existirem).
7. **Agenda pessoal** (visão consolidada — já tem dado real de evento + bloqueio pessoal pra mostrar).
8. **Teleprompter** (consome repertório + setlist do evento, feature "de cima" do stack).
9. Notificações push (transversal, entra por último sem travar as anteriores).

## 3. Definition of Done por feature

Uma feature só é considerada pronta quando:
- [ ] Modelo `.yaml` criado/alterado e migration revisada manualmente.
- [ ] Endpoint(s) com validação de autorização testada (caso autorizado e caso negado).
- [ ] Teste de integração cobrindo o caminho feliz e pelo menos um caso de borda de `docs/02-FEATURES.md`.
- [ ] Tela Flutter com os 4 estados (loading/vazio/erro/sucesso) conforme `skills/SKILL-frontend-flutter.md`.
- [ ] Responsivo testado em mobile e web (mesmo que web não seja prioridade de lançamento, não pode quebrar).
- [ ] Rodou localmente contra Postgres real via docker-compose, não só mock.

## 4. Testes

- **Server**: testes de integração por endpoint (`serverpod test` roda o server real contra um Postgres de teste).
- **Client Flutter**: widget tests para os componentes reutilizáveis (`EventoCard`, `ConfirmacaoAvatarStack`, etc.) e um teste de fluxo por feature crítica (login → seleção de contexto → home).
- Não perseguir 100% de cobertura no MVP — priorizar: autorização, motor de conflito, teleprompter offline. São os três pontos onde um bug é caro (dado vazando entre bandas, aviso de conflito que não aparece, teleprompter que trava sem internet no meio de um show).

## 5. CI/CD e infraestrutura gratuita

Três GitHub Actions workflows em `.github/workflows/` (criar ao inicializar o repositório):

### `backend-ci.yml` — roda em todo PR que toca `minha_banda_server/**`
```yaml
# dart analyze --fatal-infos + dart test
```

### `backend-keepalive.yml` — a cada 4 minutos (24/7)
```yaml
# curl https://api.minha-banda.com.br/livez
# Mantém Render (suspend 15 min) e Neon (suspend 5 min) acordados
```

### `backend-backup.yml` — diário às 06:00 UTC (03:00 Brasília)
```yaml
# pg_dump do Neon via postgres:16 docker, upload para GitHub Artifacts (30 dias)
# secrets.NEON_DATABASE_URL_DIRECT
```

Os três arquivos completos estão em `.github/workflows/` — criados durante o setup do repositório seguindo o modelo do projeto Na Rota da Serra.

**Deploy Estágio 0 (Render free tier)**: manual via `git push` — o Render detecta push no `main` e re-deploya o Docker automaticamente. Não precisa de workflow de deploy manual.

## 6. Convenção de branches e commits

- `main` sempre deployável.
- Uma branch por feature (`feature/repertorio`, `feature/teleprompter`), seguindo a ordem do roadmap da seção 2.
- Commits pequenos e descritivos; mensagens em português, no imperativo ("Adiciona motor de conflito de agenda"), consistente com o restante do projeto.

## 7. Como retomar uma sessão de desenvolvimento com IA

No início de qualquer sessão nova (Claude Code ou claude.ai):
1. Carregar `skills/SKILL-minha-banda-contexto.md`.
2. Carregar a(s) skill(s) específica(s) do módulo em questão.
3. Apontar qual item do roadmap (seção 2) está em andamento.
4. Ao final da sessão, atualizar este documento se alguma decisão de arquitetura mudou — ele é a fonte de verdade viva do projeto, não um artefato estático.
