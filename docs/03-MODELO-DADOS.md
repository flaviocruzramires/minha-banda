# Minha Banda — Modelo de Dados (Postgres via Serverpod)

No Serverpod cada tabela nasce de um arquivo `.yaml` em `lib/src/models/`, e o `serverpod generate` cria a classe Dart + a migration Postgres. Abaixo está o modelo conceitual (ERD em texto) e um exemplo de arquivo `.yaml` real para dois modelos, servindo de padrão para os demais.

## 1. Entidades principais

```
AppUser
 ├─< Membership >─ Banda
 ├─< ResponsavelLocal >─ LocalShow
 ├─< BloqueioAgenda (pessoal)
 └─< ConfirmacaoPresenca >─ Evento

Banda
 ├─< Membership
 ├─< Musica (repertório)
 └─< Evento

Evento
 ├─ Banda (dono)
 ├─ LocalShow (opcional)
 ├─< SetlistItem >─ Musica
 ├─< ConfirmacaoPresenca >─ AppUser
 └─< ChecklistItem

Musica
 ├─ Banda (dono)
 └─< SetlistItem

LocalShow
 └─< ResponsavelLocal >─ AppUser

ConflitoAgenda (calculado, não persistido — ou cacheado por evento)
```

## 2. Dicionário de tabelas (resumo)

| Tabela | Campos-chave | Observações |
|---|---|---|
| `app_user` | id, nome, email, senha_hash, foto_url, criado_em | Base do `serverpod_auth` |
| `banda` | id, nome, genero, cor_hex, cidade, bio, logo_url | |
| `membership` | id, banda_id, usuario_id, papel (enum), instrumento, ativo, entrou_em | Chave única (banda_id, usuario_id) |
| `local_show` | id, nome, endereco, cidade, capacidade, tipo (enum), tem_equipamento_som, tem_camarim | |
| `responsavel_local` | id, local_id, usuario_id, papel (enum) | Chave única (local_id, usuario_id) |
| `musica` | id, banda_id, titulo, artista_original, tom, bpm, duracao_segundos, letra, cifra_texto, cifra_pdf_url, status (enum: aprendendo/pronta), tags[] | |
| `evento` | id, banda_id, local_id (nullable), tipo (enum: show/ensaio), status (enum), data_hora_inicio, data_hora_fim, observacoes, criado_por | |
| `setlist_item` | id, evento_id, musica_id, ordem | |
| `checklist_item` | id, evento_id, descricao, concluido | |
| `confirmacao_presenca` | id, evento_id, usuario_id, status (enum: pendente/confirmado/recusado), respondido_em | |
| `bloqueio_agenda` | id, usuario_id, data_hora_inicio, data_hora_fim, motivo | Indisponibilidade pessoal, cruza todas as bandas |
| `notificacao` | id, usuario_id, tipo, titulo, corpo, lida, criado_em | |

## 3. Exemplo de arquivo de modelo Serverpod

`lib/src/models/banda.yaml`:
```yaml
class: Banda
table: banda
fields:
  nome: String
  genero: String?
  corHex: String
  cidade: String?
  bio: String?
  logoUrl: String?
  criadoEm: DateTime
indexes:
  banda_nome_idx:
    fields: nome
```

`lib/src/models/membership.yaml`:
```yaml
class: Membership
table: membership
fields:
  bandaId: int
  banda: Banda?, relation(field=bandaId)
  usuarioId: int
  papel: PapelBanda
  instrumento: String?
  ativo: bool
  entrouEm: DateTime
indexes:
  membership_unico_idx:
    fields: bandaId, usuarioId
    unique: true
```

`lib/src/models/papel_banda.yaml` (enum):
```yaml
enum: PapelBanda
values:
  - admin
  - musico
```

Esse padrão (uma entidade = um `.yaml`, relations explícitas via `relation(field=...)`, enums em arquivo próprio) é o que as Skills de backend (`skills/skill-backend-serverpod.md`) vão seguir para manter consistência entre sessões de desenvolvimento.

## 4. Índices e performance desde o início

- `evento(banda_id, data_hora_inicio)` — toda tela de agenda filtra por isso.
- `membership(usuario_id, ativo)` — resolvido a cada login para montar o seletor de contexto.
- `confirmacao_presenca(evento_id)` e `(usuario_id)` — ambos os sentidos são consultados o tempo todo (card do evento e agenda pessoal).
- `bloqueio_agenda(usuario_id, data_hora_inicio, data_hora_fim)` — usado pelo motor de conflito.

## 5. Migrations

O fluxo padrão do Serverpod: alterar o `.yaml` → `serverpod generate` → `serverpod create-migration` → revisar o SQL gerado antes de aplicar em produção (`--apply-migrations` só em dev). Cada migration fica versionada em `migrations/` dentro do server, então o histórico de schema vive junto do código, sem depender de ferramenta externa.
