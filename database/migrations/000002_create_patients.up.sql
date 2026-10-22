CREATE TABLE patients (
                          id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                          user_id    UUID        NOT NULL UNIQUE REFERENCES users (id) ON DELETE CASCADE,
                          full_name  TEXT        NOT NULL,
                          birth_date DATE,
                          gender     gender,
                          iin        CHAR(12) UNIQUE,
                          avatar_url TEXT,
                          prefs      JSONB       NOT NULL DEFAULT '{}'::jsonb, -- large_text, high_contrast, hide_mascot, language
                          created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
                          updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);