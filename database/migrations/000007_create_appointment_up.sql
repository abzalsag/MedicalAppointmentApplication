CREATE TABLE appointments (
                              id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                              patient_id   UUID               NOT NULL REFERENCES patients (id) ON DELETE CASCADE,
                              doctor_id    UUID               NOT NULL REFERENCES doctors (id) ON DELETE RESTRICT,
                              slot_id      UUID               NOT NULL REFERENCES slots (id) ON DELETE RESTRICT,
                              status       appointment_status NOT NULL DEFAULT 'booked',
                              reason       TEXT,
                              created_at   TIMESTAMPTZ        NOT NULL DEFAULT now(),
                              cancelled_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX uniq_active_slot
    ON appointments (slot_id)
    WHERE status = 'booked';

CREATE INDEX idx_appointments_patient ON appointments (patient_id, status);
CREATE INDEX idx_appointments_doctor  ON appointments (doctor_id, status);