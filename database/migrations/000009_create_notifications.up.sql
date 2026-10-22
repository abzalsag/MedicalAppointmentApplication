BEGIN;

CREATE TYPE notification_type AS ENUM (
    'booking_confirmed',
    'booking_cancelled',
    'time_changed',
    'reminder',
    'queue_update'
);

CREATE TABLE notifications (
                               id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                               user_id    UUID              NOT NULL REFERENCES users (id) ON DELETE CASCADE,
                               type       notification_type NOT NULL,
                               title      TEXT              NOT NULL,
                               body       TEXT,
                               is_read    BOOLEAN           NOT NULL DEFAULT FALSE,
                               created_at TIMESTAMPTZ       NOT NULL DEFAULT now()
);

CREATE INDEX idx_notifications_user ON notifications (user_id, is_read, created_at DESC);

COMMIT;