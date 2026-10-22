-- name: ListClinics :many
SELECT * FROM clinics
WHERE (sqlc.narg('city')::text IS NULL OR city = sqlc.narg('city'))
ORDER BY name;

-- name: ListClinicsWithDoctorCount :many
SELECT c.id, c.name, c.address, c.city, c.lat, c.lng, count(d.id)::int AS doctors_count
FROM clinics c
         LEFT JOIN doctors d ON d.clinic_id = c.id AND d.is_active
WHERE (sqlc.narg('city')::text IS NULL OR c.city = sqlc.narg('city'))
GROUP BY c.id
ORDER BY c.name;

-- name: GetClinic :one
SELECT * FROM clinics WHERE id = sqlc.arg('id');

-- name: CreateClinic :one
INSERT INTO clinics (name, address, city, phone, lat, lng, working_hours)
VALUES (
           sqlc.arg('name'),
           sqlc.arg('address'),
           sqlc.arg('city'),
           sqlc.narg('phone'),
           sqlc.narg('lat'),
           sqlc.narg('lng'),
           sqlc.narg('working_hours')
       )
    RETURNING *;

-- name: UpdateClinic :one
UPDATE clinics SET
                   name          = COALESCE(sqlc.narg('name'), name),
                   address       = COALESCE(sqlc.narg('address'), address),
                   city          = COALESCE(sqlc.narg('city'), city),
                   phone         = COALESCE(sqlc.narg('phone'), phone),
                   lat           = COALESCE(sqlc.narg('lat'), lat),
                   lng           = COALESCE(sqlc.narg('lng'), lng),
                   working_hours = COALESCE(sqlc.narg('working_hours'), working_hours)
WHERE id = sqlc.arg('id')
    RETURNING *;

-- name: DeleteClinic :exec
DELETE FROM clinics WHERE id = sqlc.arg('id');