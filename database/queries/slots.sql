-- name: ListSlotsByDate :many
SELECT
    sl.id,
    sl.doctor_id,
    sl.starts_at,
    sl.ends_at,
    EXISTS (
        SELECT 1 FROM appointments a
        WHERE a.slot_id = sl.id AND a.status = 'booked'
    ) AS is_booked
FROM slots sl
WHERE sl.doctor_id = sqlc.arg('doctor_id')
  AND sl.is_active
  AND sl.starts_at > now()
  AND (sl.starts_at AT TIME ZONE 'Asia/Almaty')::date = sqlc.arg('date')::date
ORDER BY sl.starts_at;

-- name: GetSlot :one
SELECT * FROM slots WHERE id = sqlc.arg('id');

-- name: CreateSlot :one
INSERT INTO slots (doctor_id, starts_at, ends_at)
VALUES (sqlc.arg('doctor_id'), sqlc.arg('starts_at'), sqlc.arg('ends_at'))
    ON CONFLICT (doctor_id, starts_at) DO NOTHING
RETURNING *;

-- name: DeactivateSlot :exec
UPDATE slots SET is_active = FALSE WHERE id = sqlc.arg('id');