

CREATE TABLE users(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL,
    phone NOT NULL,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL
    created_at TIMESTAMPETZ NOT NULL DEFAULT NOW()
);