# Minha Banda — Especificação de Features

Cada feature abaixo segue o formato: **Objetivo → Regras → Telas envolvidas → Casos de borda**. Serve tanto de referência de produto quanto de prompt-base para as Skills de desenvolvimento.

---

## 1. Agenda da banda

**Objetivo:** dar a cada integrante uma visão única de todos os compromissos (shows, ensaios, indisponibilidades pessoais) cruzando todas as bandas que ele participa.

**Regras:**
- A agenda é sempre **por pessoa**, com filtro opcional por banda.
- Três tipos de item: `Evento` (show/ensaio confirmado), `Bloqueio pessoal` (indisponibilidade), `Sugestão` (data proposta ainda não confirmada por todos).
- Visualização em mês/semana/dia + lista ("próximos compromissos").
- Cada item mostra a banda de origem por cor (cada banda tem uma cor definida no cadastro).

**Telas:** Agenda (calendário), Detalhe do dia, Novo bloqueio pessoal.

**Casos de borda:** integrante sem nenhuma banda ainda (agenda vazia com CTA para entrar/criar banda); usuário com 5+ bandas (a agenda não pode virar poluição visual — usar filtro de bandas ativado por padrão só para as favoritas/mais recentes).

---

## 2. Repertório da banda

**Objetivo:** cadastro de músicas por banda, servindo tanto de "catálogo" quanto de fonte para o teleprompter.

**Regras:**
- Campos por música: título, artista original (para covers), tonalidade, BPM, duração estimada, tags livres (ex. "abertura", "romântica", "animada"), letra, cifra (texto ou PDF anexo), link de referência (YouTube/Spotify), notas de arranjo.
- Cada `Evento` tem um **setlist** próprio: subconjunto ordenado do repertório, podendo reordenar por drag-and-drop.
- Duração total do setlist calculada automaticamente a partir da duração de cada música — útil para casar com o tempo contratado do show.
- Repertório pode ser marcado como "pronto para show" vs "em aprendizado", para diferenciar o que a banda já manda bem do que ainda está no forno.

**Telas:** Lista de repertório (com busca/filtro por tag), Cadastro/edição de música, Montagem de setlist do evento.

**Casos de borda:** mesma música em bandas diferentes (não compartilha cadastro — cada banda tem seu próprio repertório, mesmo que toque a mesma música, porque arranjo/tonalidade pode mudar); cifra muito longa para caber na tela do teleprompter (paginação/scroll contínuo, não corte).

---

## 3. Eventos (shows e ensaios)

**Objetivo:** núcleo do app — tudo (agenda, repertório, conflito, local) converge no evento.

**Regras:**
- Tipos: `Show` e `Ensaio`. Show exige local + responsável do local; ensaio pode ser em local livre (casa de alguém, estúdio).
- Status: `Proposto → Confirmado → Realizado → Cancelado`.
- Checklist do evento (equipamento a levar, horário de chegada, passagem de som) — itens simples de check, não um projeto complexo.
- Confirmação individual: cada integrante confirma presença separadamente; o card do evento mostra "4/5 confirmados".
- Ao criar/editar, dispara o motor de conflito de agenda (feature 6) e mostra aviso antes de salvar.

**Telas:** Lista de eventos (próximos/passados), Detalhe do evento (com abas: Info, Setlist, Checklist, Confirmações), Novo evento (wizard curto: tipo → data/hora → local → integrantes → revisão).

**Casos de borda:** evento sem local definido ainda (permitir salvar como rascunho); cancelamento com integrantes já confirmados (notificar todos automaticamente).

---

## 4. Teleprompter para o vocalista

**Objetivo:** modo de performance ao vivo, legível a distância, com controle simples durante o show.

**Regras:**
- Acessa direto do setlist do evento em andamento — sem navegação extra durante o show.
- Fonte grande (ajustável), alto contraste, tema escuro por padrão (palco).
- Scroll automático com velocidade ajustável + play/pause + pular para próxima música do setlist.
- Tela sempre ligada (`wakelock`) enquanto em uso.
- Modo offline garantido (repertório do evento pré-carregado).
- Fase 2: modo sincronizado entre dispositivos (vocal principal + backing vocals seguem o mesmo scroll).

**Telas:** Tela de teleprompter (full-screen, gestos para controlar), seletor rápido de música dentro do evento.

**Casos de borda:** letra com acordes embutidos (opção de mostrar/ocultar cifra sobre a letra); usuário girando o celular (travar orientação configurável, já que teleprompter costuma ficar em suporte fixo).

---

## 5. Cadastro de integrantes

**Objetivo:** perfil da pessoa dentro da banda — quem toca o quê, contato, papel administrativo.

**Regras:**
- Um integrante é sempre um `AppUser` vinculado via `Membership` — não existe "integrante fantasma" sem conta, pois ele precisa logar para confirmar presença/agenda. Convite por link/e-mail para quem ainda não tem conta.
- Campos: instrumento(s)/função (inclusive "técnico de som", "produtor", não só músico), papel na banda (admin/músico), telefone, apelido artístico.
- Admin da banda pode remover integrante (soft-delete, mantém histórico de eventos passados).

**Telas:** Lista de integrantes da banda, Perfil do integrante, Convite de novo integrante.

**Casos de borda:** integrante sai da banda no meio de um evento já confirmado (evento mantém o histórico, mas ele some da lista de "ativos" para eventos futuros).

---

## 6. Gerenciar conflito de agenda de integrantes multi-banda

Ver detalhamento técnico em `01-ARQUITETURA.md`, seção 6. Do ponto de vista de produto:

**Regras de UX:**
- Conflito nunca **bloqueia** — só **avisa**. Decisão final é humana (pode ser flexibilidade de horário real).
- Aviso mostra claramente: "Carlos também tem show com Banda Zeta nesse mesmo horário" com link direto pro evento conflitante (se o usuário atual tiver visibilidade dele).
- Selo visual de conflito no card do evento, visível para o admin, até ser resolvido ou ignorado explicitamente.

**Telas:** Modal/banner de conflito no fluxo de criação de evento, indicador no card do evento na lista.

---

## 7. Cadastro de banda

**Objetivo:** identidade da banda dentro do app.

**Regras:**
- Campos: nome, gênero(s), cor de identificação (usada na agenda), logo/foto, cidade base, bio curta, links (Instagram, YouTube).
- Quem cria a banda vira automaticamente `ADMIN`.
- Uma banda pode ter mais de um admin (ex. dois fundadores).

**Telas:** Cadastro/edição de banda, Perfil público da banda (útil se um responsável de local quiser ver antes de confirmar contratação).

---

## 8. Cadastro de locais de show e responsáveis

**Objetivo:** trazer o "outro lado" do show para dentro do app — quem contrata/recebe a banda.

**Regras:**
- Local: nome, endereço, capacidade, tipo (bar, casa de show, evento privado, festival), contato, estrutura disponível (tem equipamento de som? camarim?).
- Responsável do local é um `AppUser` com vínculo `ResponsavelLocal` — mesmo mecanismo de login único da banda. Se essa pessoa também toca em uma banda, um único login carrega os dois contextos.
- Responsável de local pode ver (e opcionalmente confirmar) os eventos marcados no seu local, sem enxergar dados internos da banda (repertório, agenda pessoal dos músicos) — isolamento de dados por papel.

**Telas:** Lista de locais, Cadastro/edição de local, Painel do responsável de local (visão restrita: só os eventos marcados ali).

**Casos de borda:** local sem responsável cadastrado ainda (banda cadastra o local "solto", útil para casas que não usam o app — funciona só como agenda da banda).

---

## 9. Login único multi-perfil

Ver modelagem técnica em `01-ARQUITETURA.md`, seção 5. Do ponto de vista de UX:

**Regras:**
- Login único (e-mail/senha ou Google/Apple).
- Se o usuário tem **um único vínculo**, entra direto na home daquele contexto — zero fricção.
- Se tem **mais de um vínculo** (2+ bandas, ou banda + local), mostra um seletor de perfil logo após o login, com possibilidade de trocar a qualquer momento por um menu no topo (sem precisar deslogar).
- O contexto ativo define o que aparece no menu principal: um responsável de local não vê "Repertório" nem "Teleprompter", por exemplo — o menu é montado dinamicamente por papel.

**Telas:** Login, Seletor de perfil/contexto, Home (varia por papel).

---

## Resumo de papéis e visibilidade

| Papel | Agenda | Repertório | Eventos | Teleprompter | Integrantes | Locais |
|---|---|---|---|---|---|---|
| Admin da banda | ✅ completa | ✅ CRUD | ✅ CRUD | ✅ | ✅ CRUD | ✅ visualizar/vincular |
| Músico | ✅ completa (todas bandas) | ✅ ver/usar | ✅ confirmar presença | ✅ | ✅ ver | — |
| Responsável de local | — (não tem agenda de banda) | — | ✅ só eventos no seu local | — | — | ✅ CRUD do próprio local |
