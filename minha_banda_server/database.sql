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
