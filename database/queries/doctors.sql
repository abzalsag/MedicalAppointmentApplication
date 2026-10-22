-- name: ListDoctors :many
SELECT
    d.id,
    d.full_name,
    d.experience_years,
    d.price,
    d.rating,
    d.reviews_count,
    d.photo_url,
    s.name AS specialty_name,
    c.name AS clinic_name,
    ns.starts_at AS nearest_slot
FROM doctors d
         JOIN specialties s ON s.id = d.specialty_id
         JOIN clinics c     ON c.id = d.clinic_id
         LEFT JOIN LATERAL (
    SELECT sl.starts_at
    FROM slots sl
    WHERE sl.doctor_id = d.id
      AND sl.is_active
      AND sl.starts_at > now()
      AND NOT EXISTS (
        SELECT 1 FROM appointments a
        WHERE a.slot_id = sl.id AND a.status = 'booked'
    )
    ORDER BY sl.starts_at
        LIMIT 1
) ns ON TRUE
WHERE d.is_active
  AND (sqlc.narg('specialty_id')::int   IS NULL OR d.specialty_id = sqlc.narg('specialty_id'))
  AND (sqlc.narg('clinic_id')::uuid     IS NULL OR d.clinic_id    = sqlc.narg('clinic_id'))
  AND (sqlc.narg('price_max')::numeric  IS NULL OR d.price       <= sqlc.narg('price_max'))
  AND (sqlc.narg('min_rating')::numeric IS NULL OR d.rating      >= sqlc.narg('min_rating'))
  AND (sqlc.narg('q')::text IS NULL OR d.full_name ILIKE '%' || sqlc.narg('q') || '%')
  AND (sqlc.narg('date')::date IS NULL OR EXISTS (
    SELECT 1 FROM slots sl
    WHERE sl.doctor_id = d.id
  AND sl.is_active
  AND sl.starts_at > now()
  AND (sl.starts_at AT TIME ZONE 'Asia/Almaty')::date = sqlc.narg('date')::date
  AND NOT EXISTS (
    SELECT 1 FROM appointments a
    WHERE a.slot_id = sl.id AND a.status = 'booked'
    )
    ))
ORDER BY
    CASE WHEN sqlc.arg('sort')::text = 'price' THEN d.price END ASC NULLS LAST,
    d.rating DESC,
    d.id
LIMIT sqlc.arg('limit_count') OFFSET sqlc.arg('offset_count');

-- name: GetDoctor :one
SELECT
    d.id, d.user_id, d.full_name, d.experience_years, d.bio, d.price,
    d.rating, d.reviews_count, d.photo_url,
    s.name AS specialty_name,
    c.id AS clinic_id, c.name AS clinic_name, c.address AS clinic_address,
    c.lat, c.lng, c.working_hours, c.phone AS clinic_phone
FROM doctors d
         JOIN specialties s ON s.id = d.specialty_id
         JOIN clinics c     ON c.id = d.clinic_id
WHERE d.id = sqlc.arg('id');

-- name: GetDoctorByUserID :one
SELECT * FROM doctors WHERE user_id = sqlc.arg('user_id');