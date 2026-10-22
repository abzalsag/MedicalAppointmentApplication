CREATE TABLE slots (
                       id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                       doctor_id UUID        NOT NULL REFERENCES doctors (id) ON DELETE CASCADE,
                       starts_at TIMESTAMPTZ NOT NULL,
                       ends_at   TIMESTAMPTZ NOT NULL,
                       is_active BOOLEAN     NOT NULL DEFAULT TRUE,
                       CONSTRAINT chk_slot_time CHECK (ends_at > starts_at),
                       CONSTRAINT uniq_doctor_slot UNIQUE (doctor_id, starts_at)
);

CREATE INDEX idx_slots_doctor_starts ON slots (doctor_id, starts_at);