# Minha Banda — Pacote de Planejamento

Conteúdo gerado para orientar a construção do app. Ordem de leitura sugerida:

1. `docs/01-ARQUITETURA.md` — stack (Flutter + Serverpod + Postgres), estratégia de deploy em 3 estágios com foco em custo mínimo, modelagem de multi-perfil e motor de conflito de agenda.
2. `docs/02-FEATURES.md` — especificação das 9 features pedidas, com regras de negócio, telas envolvidas e casos de borda.
3. `docs/03-MODELO-DADOS.md` — ERD conceitual e exemplo de modelos `.yaml` do Serverpod.
4. `docs/04-HARNESS-DESENVOLVIMENTO.md` — estrutura de repositório, ordem de construção do MVP, definição de pronto, testes e CI.
5. `skills/` — cinco arquivos `SKILL-*.md` no mesmo formato que você já usa no fluxo do Na Rota da Serra, prontos para carregar em sessões futuras com Claude/Claude Code:
   - `SKILL-minha-banda-contexto.md` (carregar sempre primeiro)
   - `SKILL-backend-serverpod.md`
   - `SKILL-frontend-flutter.md`
   - `SKILL-conflito-agenda.md`
   - `SKILL-teleprompter.md`
6. `mockups/telas-prototipo.html` — protótipo visual navegável (abra no navegador) com 6 telas: seletor de perfil, home, agenda, eventos (com selo de conflito), repertório e teleprompter.

## Sobre salvar em `D:\desenvolvimento\flutter\minha banda`

Eu não tenho acesso ao sistema de arquivos do seu computador Windows a partir deste chat — só consigo gerar os arquivos aqui e disponibilizá-los para download. Para ficarem exatamente nesse caminho:

1. Baixe os arquivos apresentados no final desta resposta.
2. Extraia/copie mantendo a estrutura de pastas (`docs/`, `skills/`, `mockups/`) dentro de `D:\desenvolvimento\flutter\minha banda`.

Se quiser que eu grave direto nesse caminho nas próximas vezes, o **Claude Code** (app desktop) roda localmente na sua máquina e tem acesso real ao seu sistema de arquivos — nesse caso eu poderia criar e editar os arquivos diretamente em `D:\desenvolvimento\flutter\minha banda` durante o desenvolvimento do app.
