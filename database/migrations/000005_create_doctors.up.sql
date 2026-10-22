CREATE TABLE doctors (
                         id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                         user_id          UUID          NOT NULL UNIQUE REFERENCES users (id) ON DELETE CASCADE,
                         clinic_id        UUID          NOT NULL REFERENCES clinics (id) ON DELETE RESTRICT,
                         specialty_id     INT           NOT NULL REFERENCES specialties (id) ON DELETE RESTRICT,
                         full_name        TEXT          NOT NULL,
                         experience_years INT           NOT NULL DEFAULT 0 CHECK (experience_years >= 0),
                         bio              TEXT,
                         price            NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (price >= 0),
                         rating           NUMERIC(2,1)  NOT NULL DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
                         reviews_count    INT           NOT NULL DEFAULT 0,
                         photo_url        TEXT,
                         is_active        BOOLEAN       NOT NULL DEFAULT TRUE,
                         created_at       TIMESTAMPTZ   NOT NULL DEFAULT now(),
                         updated_at       TIMESTAMPTZ   NOT NULL DEFAULT now()
);


CREATE INDEX idx_doctors_specialty ON doctors (specialty_id);
CREATE INDEX idx_doctors_clinic    ON doctors (clinic_id);
CREATE INDEX idx_doctors_rating    ON doctors (rating DESC);