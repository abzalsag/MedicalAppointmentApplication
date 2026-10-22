CREATE TABLE clinics (
                         id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                         name          TEXT NOT NULL,
                         address       TEXT NOT NULL,
                         city          TEXT NOT NULL DEFAULT 'Almaty',
                         phone         TEXT,
                         lat           DOUBLE PRECISION,
                         lng           DOUBLE PRECISION,
                         working_hours TEXT,
                         created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_clinics_city ON clinics (city);