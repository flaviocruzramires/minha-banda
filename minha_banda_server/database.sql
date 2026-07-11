-- Schema inicial do Minha Banda
-- Executar no Neon (ou qualquer Postgres 16+) antes do primeiro deploy.

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Usuários
CREATE TABLE IF NOT EXISTS users (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nome_artistico TEXT NOT NULL,
  email         TEXT NOT NULL UNIQUE,
  senha_hash    TEXT NOT NULL,
  criado_em     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);

-- Bandas
CREATE TABLE IF NOT EXISTS bandas (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nome           TEXT NOT NULL,
  genero_musical TEXT NOT NULL,
  cidade         TEXT NOT NULL,
  cor_hex        INTEGER NOT NULL DEFAULT 0,
  criado_por     UUID NOT NULL REFERENCES users(id),
  criado_em      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_bandas_nome ON bandas (lower(nome));

-- Memberships (vínculo usuário ↔ banda)
CREATE TABLE IF NOT EXISTS memberships (
  id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  banda_id  UUID NOT NULL REFERENCES bandas(id) ON DELETE CASCADE,
  user_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  papel     TEXT NOT NULL DEFAULT 'MUSICO',  -- ADMIN | MUSICO | PRODUTOR
  ativo     BOOLEAN NOT NULL DEFAULT true,
  criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (banda_id, user_id)
);
CREATE INDEX IF NOT EXISTS idx_memberships_user ON memberships (user_id);

-- Extensão de memberships: instrumento e função
ALTER TABLE memberships ADD COLUMN IF NOT EXISTS instrumento TEXT;
ALTER TABLE memberships ADD COLUMN IF NOT EXISTS apelido TEXT;
ALTER TABLE memberships ADD COLUMN IF NOT EXISTS telefone TEXT;

-- Convites pendentes
CREATE TABLE IF NOT EXISTS convites (
  id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  banda_id  UUID NOT NULL REFERENCES bandas(id) ON DELETE CASCADE,
  email     TEXT NOT NULL,
  token     TEXT NOT NULL UNIQUE,
  status    TEXT NOT NULL DEFAULT 'pendente',  -- pendente | aceito | expirado
  criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (banda_id, email)
);

-- Locais de show
CREATE TABLE IF NOT EXISTS locais (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nome             TEXT NOT NULL,
  endereco         TEXT,
  cidade           TEXT NOT NULL,
  tipo             TEXT NOT NULL DEFAULT 'bar',  -- bar | casa_de_show | evento_privado | festival | outro
  capacidade       INTEGER,
  contato          TEXT,
  tem_som          BOOLEAN NOT NULL DEFAULT false,
  tem_camarim      BOOLEAN NOT NULL DEFAULT false,
  notas            TEXT,
  criado_por       UUID NOT NULL REFERENCES users(id),
  criado_em        TIMESTAMPTZ NOT NULL DEFAULT now(),
  atualizado_em    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_locais_cidade ON locais (cidade);

-- Responsáveis de local
CREATE TABLE IF NOT EXISTS responsaveis_local (
  id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  local_id  UUID NOT NULL REFERENCES locais(id) ON DELETE CASCADE,
  user_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  papel     TEXT NOT NULL DEFAULT 'GERENTE',  -- DONO | GERENTE
  criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (local_id, user_id)
);

-- ---------------------------------------------------------------------------
-- EVENTOS (shows e ensaios)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS eventos (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  banda_id         UUID NOT NULL REFERENCES bandas(id) ON DELETE CASCADE,
  tipo             TEXT NOT NULL DEFAULT 'show',  -- show | ensaio
  titulo           TEXT NOT NULL,
  data_hora_inicio TIMESTAMPTZ NOT NULL,
  data_hora_fim    TIMESTAMPTZ,
  local_id         UUID REFERENCES locais(id),
  status           TEXT NOT NULL DEFAULT 'proposto',  -- proposto | confirmado | realizado | cancelado
  notas            TEXT,
  criado_por       UUID NOT NULL REFERENCES users(id),
  criado_em        TIMESTAMPTZ NOT NULL DEFAULT now(),
  atualizado_em    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_eventos_banda ON eventos (banda_id);
CREATE INDEX IF NOT EXISTS idx_eventos_data ON eventos (data_hora_inicio);

-- Confirmações de presença por integrante
CREATE TABLE IF NOT EXISTS evento_confirmacoes (
  id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  evento_id UUID NOT NULL REFERENCES eventos(id) ON DELETE CASCADE,
  user_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status    TEXT NOT NULL DEFAULT 'pendente',  -- pendente | confirmado | recusado
  criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (evento_id, user_id)
);

-- Checklist do evento
CREATE TABLE IF NOT EXISTS evento_checklist (
  id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  evento_id UUID NOT NULL REFERENCES eventos(id) ON DELETE CASCADE,
  descricao TEXT NOT NULL,
  concluido BOOLEAN NOT NULL DEFAULT false,
  criado_em TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Repertório
CREATE TABLE IF NOT EXISTS musicas (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  banda_id      UUID NOT NULL REFERENCES bandas(id) ON DELETE CASCADE,
  titulo        TEXT NOT NULL,
  artista_original TEXT,
  tonalidade    TEXT,
  bpm           INTEGER,
  duracao_seg   INTEGER,
  tags          TEXT[] NOT NULL DEFAULT '{}',
  letra         TEXT,
  cifra         TEXT,
  link_referencia TEXT,
  notas_arranjo TEXT,
  status        TEXT NOT NULL DEFAULT 'em_aprendizado', -- em_aprendizado | pronto_show
  criado_por    UUID NOT NULL REFERENCES users(id),
  criado_em     TIMESTAMPTZ NOT NULL DEFAULT now(),
  atualizado_em TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_musicas_banda ON musicas (banda_id);

-- Setlists (vínculo evento ↔ musica, com ordem)
CREATE TABLE IF NOT EXISTS setlist_itens (
  id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  evento_id UUID NOT NULL REFERENCES eventos(id) ON DELETE CASCADE,
  musica_id UUID NOT NULL REFERENCES musicas(id) ON DELETE CASCADE,
  posicao   INTEGER NOT NULL DEFAULT 0,
  UNIQUE (evento_id, musica_id)
);

-- ---------------------------------------------------------------------------
-- AGENDA (Bloqueios Pessoais)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS bloqueios_pessoais (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id          UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  titulo           TEXT NOT NULL,
  data_hora_inicio TIMESTAMPTZ NOT NULL,
  data_hora_fim    TIMESTAMPTZ NOT NULL,
  criado_em        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_bloqueios_user ON bloqueios_pessoais (user_id);
CREATE INDEX IF NOT EXISTS idx_bloqueios_data ON bloqueios_pessoais (data_hora_inicio);
