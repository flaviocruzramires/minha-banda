# Minha Banda — Arquitetura Técnica

> Documento de arquitetura de referência. Escrito para orientar tanto o desenvolvimento manual quanto sessões com Claude Code, usando as Skills descritas em `/skills`.

## 1. Visão geral

**Minha Banda** é um app de gestão de bandas: agenda, repertório, eventos (shows/ensaios), teleprompter, integrantes, conflitos de agenda entre múltiplas bandas, locais de show e login único multi-perfil.

Premissas do projeto:
- **100% Dart/Flutter** — front e back no mesmo idioma, um único time (você) consegue manter tudo.
- **Postgres** como única fonte de verdade relacional.
- **Custo mínimo** para lançar e validar, com caminho claro de escala sem reescrever nada.
- **Multi-tenant por relacionamento**, não por schema separado (ver seção 5) — um usuário só, várias bandas, vários papéis.

## 2. Stack escolhida

| Camada | Escolha | Por quê |
|---|---|---|
| Front-end | Flutter (mobile iOS/Android + Web responsivo) | Um código-fonte, três destinos (App Store, Play Store, Web para os donos de casas de show acessarem do notebook) |
| Backend | **Serverpod** (Dart) | É a única stack backend 100% Dart madura para Flutter: gera endpoints, ORM tipado sobre Postgres, autenticação, migrations, cache, upload de arquivo e streams em tempo real prontos. Evita escrever REST/GraphQL na mão e mantém modelos compartilhados entre app e servidor (zero duplicação de DTOs). |
| Banco de dados | PostgreSQL 16+ | Exigência do projeto; Serverpod já é construído em cima do Postgres nativamente, com migrations versionadas gerada a partir dos modelos `.yaml`. |
| Cache/Sessão (opcional, fase 2) | Redis | Serverpod já tem integração pronta; só liga quando o tráfego justificar. Não é necessário no MVP. |
| Autenticação | Módulo `serverpod_auth` (e-mail/senha + Google/Apple Sign-In) | Evita reinventar hashing de senha, refresh token e fluxo de recuperação de senha. |
| Push/Notificações | Firebase Cloud Messaging | Único ponto onde saímos do 100% Dart puro — é a forma mais barata e confiável de push cross-platform; o token FCM é só mais uma coluna no Postgres. |
| Storage de arquivos (fotos de banda, cifras em PDF, logo do local) | S3-compatible (Cloudflare R2) | Compatível com o módulo de storage do Serverpod, e o R2 não cobra egress — importante porque teleprompter/repertório vai puxar letras e cifras o tempo todo. |

### Por que não Firebase/Supabase puro
Ambos resolveriam mais rápido no dia 1, mas o requisito é "100% Flutter, front e back", banco Postgres explícito, e você já domina Dart/Flutter há 20 anos — não Node/Deno. Serverpod é a opção que respeita as três coisas ao mesmo tempo e ainda gera o client Dart automaticamente a partir do server, o que significa que **toda mudança de modelo se propaga para o app com type-safety em tempo de compilação** — nada de contrato de API quebrando em produção.

## 3. Deploy e custo — estratégia em 3 estágios

O objetivo é nunca pagar por capacidade que não está sendo usada, mas ter um caminho de subida sem re-arquitetar.

> **Referência de infraestrutura**: a stack gratuita abaixo é idêntica à usada em produção no projeto **Na Rota da Serra** — validada e funcionando. Oracle Cloud Free Tier e Hetzner foram descartados: Oracle exige cartão de crédito com risco de cobrança acidental, Hetzner custa US$ 5-10/mês. A stack abaixo é **R$ 0/mês**.

### Estágio 0 — Validação (0 a ~500 usuários, custo = **US$ 0/mês**)

| Componente | Serviço | Por quê gratuito |
|---|---|---|
| Backend (Serverpod) | **Render** — free tier, runtime Docker | 512 MB RAM, 0.1 CPU, auto-suspend após 15 min de inatividade |
| Banco de dados | **Neon** — Postgres 16 serverless | 0,5 GB storage, auto-suspend após 5 min de inatividade |
| Keep-alive | **GitHub Actions** | Workflow pinga `/health/` a cada 4 min, mantém Render e Neon acordados |
| Backup diário | **GitHub Actions** + artefatos | `pg_dump` diário para GitHub Artifacts (retenção 30 dias) |
| CI/CD | **GitHub Actions** | Lint + testes em cada PR |
| Storage de assets | **Cloudflare R2** | 10 GB / 10 M leituras gratuitos por mês, zero egress fee |
| CDN + TLS + DNS | **Cloudflare** | Plano gratuito cobre proxy, HTTPS e proteção DDoS básica |

**Configuração Render (`render.yaml`):**
```yaml
services:
  - type: web
    name: minha-banda-api
    runtime: docker
    plan: free
    rootDir: minha_banda_server
    dockerfilePath: ./Dockerfile
    healthCheckPath: /livez        # endpoint de health do Serverpod
```

**Nota sobre Serverpod no Render free tier**: compilar em modo JIT (`dart run`) em vez de AOT (`dart compile exe`) para respeitar o limite de 512 MB de RAM — idêntico à abordagem usada no Na Rota da Serra.

**Nota sobre keep-alive**: o Render suspende instâncias gratuitas após 15 min sem requisição; o Neon suspende o Postgres após 5 min. O GitHub Actions pinga `/livez` a cada 4 min (ver `.github/workflows/backend-keepalive.yml`) para evitar cold-start perceptível pelo usuário.

### Estágio 1 — Crescimento (500 a ~5.000 usuários)
- Sobe para **Serverpod Cloud** (plataforma oficial, paga por uso: CPU, storage do Postgres e banda) *ou* **Render pago** (Starter US$ 7/mês) se preferir manter a mesma infraestrutura.
- Migra Neon para plano pago (Launch US$ 19/mês) ou Supabase Postgres para mais storage.
- Liga Redis gerenciado só se cache/streams em tempo real (teleprompter compartilhado) começarem a pesar.
- **O código não muda** — Serverpod foi desenhado para essa migração ser configuração, não reescrita.

### Estágio 2 — Escala (múltiplas bandas grandes, teleprompter simultâneo pesado)
- Múltiplas instâncias Serverpod atrás de load balancer, Postgres com réplica de leitura, Redis para pub/sub do teleprompter em tempo real.
- CDN Cloudflare na frente do Flutter Web e dos assets do R2.

> Regra prática: **não construa o Estágio 2 no dia 1.** O erro mais caro em apps desse porte é otimizar prematuramente para uma escala que talvez nunca chegue. Serverpod garante que a migração entre estágios seja configuração, não reescrita.

## 4. Estrutura de módulos do backend (Serverpod)

Cada "feature" do escopo vira um conjunto de endpoints + modelos, isolados por domínio:

```
minha_banda_server/
  lib/src/
    auth/                → login único, papéis, sessão
    bandas/               → cadastro de banda, membros, papéis dentro da banda
    agenda/               → disponibilidade dos integrantes, bloqueios pessoais
    eventos/               → shows e ensaios, status, checklist
    locais/                → cadastro de locais + responsáveis
    repertorio/             → músicas, tags, tonalidade, letra/cifra
    teleprompter/            → sessão ao vivo, controle de scroll, sincronismo
    conflitos/               → motor de detecção de conflito de agenda
    notificacoes/            → push + e-mail transacional
```

Cada pasta acima tem seu próprio arquivo de modelo `.yaml`, seus `Endpoint`s e seus testes — isso mapeia 1:1 com as Skills em `/skills`, para que cada sessão de desenvolvimento (manual ou com IA) tenha escopo pequeno e previsível.

## 5. Multi-tenant e login único (requisito 9)

Modelo escolhido: **um único usuário (`AppUser`), múltiplos vínculos (`Membership`)**.

```
AppUser 1 ──< Membership >── Banda
AppUser 1 ──< ResponsavelLocal >── LocalShow
```

- `Membership` guarda: `banda_id`, `usuario_id`, `papel` (ADMIN, MUSICO, PRODUTOR), `instrumento`, `ativo`.
- `ResponsavelLocal` guarda: `local_id`, `usuario_id`, `papel` (DONO, GERENTE).
- No login, o backend devolve **todos os vínculos ativos do usuário** em uma única chamada (`getMeuContexto()`), e o app monta um seletor de perfil/contexto se houver mais de um vínculo.
- Toda chamada subsequente ao backend carrega um `contexto_ativo_id` (banda ou local) resolvido no app e validado no servidor — **nunca confie no front para autorização**, o Serverpod endpoint sempre re-valida que aquele `AppUser` realmente pertence àquele `banda_id`/`local_id` antes de responder.
- Trocar de perfil não desloga: é só trocar o contexto ativo guardado localmente (Riverpod/Provider) e re-fazer as queries daquele escopo.

Essa modelagem resolve diretamente o requisito 6 (conflito de agenda entre bandas): como agenda é por `AppUser`, e não por banda, o motor de conflito olha *todos* os `Membership`s ativos daquele músico para cruzar horários — independente de quantas bandas ele tenha.

## 6. Motor de conflito de agenda (requisito 6)

Regra de negócio central do app, então merece destaque:

1. Todo `Evento` (show ou ensaio) tem `banda_id`, `data_hora_inicio`, `data_hora_fim` (ou duração estimada) e `local_id`.
2. Ao criar/editar um evento, o backend busca todos os `Membership`s ativos da banda, e para cada integrante busca eventos confirmados em **outras bandas** que ele participe, no mesmo intervalo (+ margem de deslocamento configurável, ex. 1h antes/depois para logística de equipamento).
3. Se houver sobreposição, o endpoint não bloqueia a criação (decisão de UX: o admin da banda pode não se importar), mas retorna uma lista de `ConflitosDetectados` com integrante + banda conflitante + evento, para o app exibir um aviso claro antes de confirmar.
4. Cada integrante também pode marcar **indisponibilidade pessoal** (viagem, trabalho, etc.) que entra no mesmo motor de conflito, mesmo sem estar ligada a nenhuma banda.

## 7. Teleprompter (requisito 4)

Dois modos, mesmo motor:
- **Modo solo**: o vocalista abre a música do repertório e controla velocidade/scroll localmente. Não precisa nem de rede depois de carregado (cache local via Isar/Hive ou apenas SQLite embutido para modo offline em show).
- **Modo sincronizado** (fase 2, usa Serverpod Streams/WebSocket): um integrante (ex. baterista/produtor) controla o scroll e todos os dispositivos no palco seguem — útil quando mais de um músico usa teleprompter (vocal + backing vocals). Implementado com os Streams nativos do Serverpod, sem precisar de infraestrutura extra até que essa feature seja pedida de verdade.
- Requisito de UX crítico: **tela sempre acesa durante uso** (`wakelock`), **fonte grande e alto contraste configuráveis**, **controle de velocidade por gesto ou pedal bluetooth** (page-turner, comum entre músicos) como evolução futura.

## 8. Offline-first (não pedido explicitamente, mas essencial no contexto de show)

Show em local com sinal ruim é a norma, não a exceção. Recomendação:
- Repertório e letras/cifras do evento do dia ficam **cacheados localmente** assim que o app sincroniza (ex. ao entrar no evento "Show de sábado").
- Teleprompter em modo solo funciona 100% offline.
- Mudanças feitas offline (ex. marcar indisponibilidade) entram em fila local e sincronizam quando a rede voltar.

## 9. Segurança e boas práticas
- JWT/sessão via `serverpod_auth`, refresh automático.
- Toda regra de "quem pode ver o quê" fica no servidor (autorização por `Membership`/`ResponsavelLocal`), nunca só escondendo botão no app.
- Rate limiting básico nos endpoints públicos (login, cadastro).
- Auditoria simples: `criado_por`, `criado_em`, `atualizado_em` em todas as tabelas.
