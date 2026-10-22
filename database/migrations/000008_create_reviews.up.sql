CREATE TABLE reviews (
                         id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                         appointment_id UUID        NOT NULL UNIQUE REFERENCES appointments (id) ON DELETE CASCADE,
                         patient_id     UUID        NOT NULL REFERENCES patients (id) ON DELETE CASCADE,
                         doctor_id      UUID        NOT NULL REFERENCES doctors (id) ON DELETE CASCADE,
                         rating         SMALLINT    NOT NULL CHECK (rating BETWEEN 1 AND 5),
                         comment        TEXT,
                         created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_reviews_doctor ON reviews (doctor_id, created_at DESC);