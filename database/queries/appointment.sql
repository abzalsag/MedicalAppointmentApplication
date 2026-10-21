-- name: CreateAppointment :one
INSERT INTO appointments (patient_id, doctor_id, slot_id, reason)
SELECT sqlc.arg('patient_id'), sl.doctor_id, sl.id, sqlc.narg('reason')
FROM slots sl
WHERE sl.id = sqlc.arg('slot_id')
  AND sl.is_active
  AND sl.starts_at > now()
    RETURNING *;

-- name: ListMyAppointments :many
SELECT
    a.id, a.status, a.reason, a.created_at,
    sl.starts_at, sl.ends_at,
    d.id AS doctor_id, d.full_name AS doctor_name, d.photo_url, d.price,
    s.name AS specialty_name,
    c.name AS clinic_name, c.address AS clinic_address
FROM appointments a
         JOIN slots sl       ON sl.id = a.slot_id
         JOIN doctors d      ON d.id = a.doctor_id
         JOIN specialties s  ON s.id = d.specialty_id
         JOIN clinics c      ON c.id = d.clinic_id
WHERE a.patient_id = sqlc.arg('patient_id')
  AND (sqlc.narg('status')::appointment_status IS NULL OR a.status = sqlc.narg('status'))
ORDER BY sl.starts_at DESC;

-- name: GetAppointment :one
SELECT
    a.id, a.patient_id, a.status, a.reason, a.created_at, a.cancelled_at,
    sl.id AS slot_id, sl.starts_at, sl.ends_at,
    d.id AS doctor_id, d.full_name AS doctor_name, d.photo_url, d.price,
    s.name AS specialty_name,
    c.name AS clinic_name, c.address AS clinic_address, c.lat, c.lng
FROM appointments a
         JOIN slots sl       ON sl.id = a.slot_id
         JOIN doctors d      ON d.id = a.doctor_id
         JOIN specialties s  ON s.id = d.specialty_id
         JOIN clinics c      ON c.id = d.clinic_id
WHERE a.id = sqlc.arg('id')
  AND a.patient_id = sqlc.arg('patient_id');

-- name: CancelAppointment :one
UPDATE appointments
SET status = 'cancelled', cancelled_at = now()
WHERE id = sqlc.arg('id')
  AND patient_id = sqlc.arg('patient_id')
  AND status = 'booked'
    RETURNING *;

-- name: CompleteAppointment :one
UPDATE appointments
SET status = 'completed'
WHERE id = sqlc.arg('id')
  AND doctor_id = sqlc.arg('doctor_id')
  AND status = 'booked'
    RETURNING *;

-- name: CountQueueAhead :one
SELECT count(*)::int AS ahead
FROM appointments a
         JOIN slots sl ON sl.id = a.slot_id
WHERE a.doctor_id = sqlc.arg('doctor_id')
  AND a.status = 'booked'
  AND sl.starts_at < sqlc.arg('starts_at')::timestamptz
  AND (sl.starts_at AT TIME ZONE 'Asia/Almaty')::date
      = (sqlc.arg('starts_at')::timestamptz AT TIME ZONE 'Asia/Almaty')::date;

-- name: ListDoctorAppointmentsByDate :many

SELECT a.id, a.status, a.reason, sl.starts_at, p.full_name AS patient_name
FROM appointments a
         JOIN slots sl    ON sl.id = a.slot_id
         JOIN patients p  ON p.id = a.patient_id
WHERE a.doctor_id = sqlc.arg('doctor_id')
  AND (sl.starts_at AT TIME ZONE 'Asia/Almaty')::date = sqlc.arg('date')::date
ORDER BY sl.starts_at;