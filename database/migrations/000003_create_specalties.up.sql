CREATE TABLE specialties (
                             id   SERIAL PRIMARY KEY,
                             name TEXT NOT NULL UNIQUE,
                             icon TEXT
);