BEGIN;

CREATE TYPE user_role AS ENUM ('patient', 'doctor', 'admin');

CREATE TABLE users (
                       id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                       email         TEXT        NOT NULL,
                       phone         TEXT,
                       password_hash TEXT        NOT NULL,
                       role          user_role   NOT NULL DEFAULT 'patient',
                       created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
                       updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX uniq_users_email ON users (lower(email));
CREATE UNIQUE INDEX uniq_users_phone ON users (phone) WHERE phone IS NOT NULL;

COMMIT;