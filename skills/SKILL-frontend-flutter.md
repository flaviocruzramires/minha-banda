---
name: frontend-flutter
description: Convenções de UI/estado para telas Flutter do Minha Banda. Carregar junto com minha-banda-contexto sempre que a tarefa envolver criação ou alteração de tela.
---

# Frontend Flutter — Minha Banda

## Estado e navegação
- Riverpod para estado (providers assíncronos para chamadas ao client Serverpod gerado).
- `go_router` para navegação, com guarda de rota por contexto ativo (banda/local) resolvido no login.
- Contexto ativo (banda ou local selecionado) vive num provider global, nunca é passado manualmente tela a tela.

## Todo componente de tela precisa tratar 4 estados
1. **Loading** — skeleton, nunca spinner genérico sozinho na tela toda (usar shimmer nos cards, mantendo layout estável).
2. **Vazio** — nunca uma tela em branco; sempre uma frase de direção + ação (ex. repertório vazio → "Nenhuma música ainda. Cadastre a primeira.").
3. **Erro** — mensagem no vocabulário do usuário (nunca stack trace/código de erro cru), com ação de tentar de novo.
4. **Sucesso/preenchido** — o estado normal.

## Responsividade
- Mobile: navegação por bottom bar (Agenda / Eventos / Repertório / Mais).
- Web/tablet: navegação lateral fixa, mesmas telas, layout em duas colunas quando fizer sentido (ex. lista de eventos + detalhe lado a lado).
- Teleprompter é a única tela que trava em full-screen e ignora a navegação padrão.

## Componentes reutilizáveis a criar cedo
- `EventoCard` (usado em agenda, lista de eventos e home) — mostra cor da banda, status, contagem de confirmações, selo de conflito se houver.
- `ConfirmacaoAvatarStack` — pilha de avatares dos integrantes com indicador de confirmado/pendente/recusado.
- `SeletorDeContexto` — dropdown/bottom sheet para trocar entre bandas/locais do usuário, sempre visível no topo quando há mais de um vínculo.
- `TagChip` — usado em repertório (tags de música) e em locais (tipo de local).

## Acessibilidade e uso em campo (show/ensaio)
- Alvos de toque grandes (o músico pode estar com o celular no bolso, luz de palco ruim, ou operando com uma mão só segurando instrumento).
- Contraste alto obrigatório nas telas usadas durante o evento (teleprompter, checklist do evento, confirmação de presença).
- Suporte a modo escuro em 100% do app, não como tema opcional secundário.

## O que NÃO fazer
- Não duplicar modelos de dados no app — sempre usar as classes geradas pelo client Serverpod (`*_client` package), nunca recriar um `Evento` local com campos divergentes do server.
- Não fazer lógica de autorização no app (esconder botão não é segurança) — o app reflete o que o servidor permite, mas o servidor é quem decide.
