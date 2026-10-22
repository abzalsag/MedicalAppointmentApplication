-- name: ListSpecialties :many
SELECT id, name, icon FROM specialties ORDER BY name;

-- name: ListSpecialtiesWithDoctorCount :many
SELECT s.id, s.name, s.icon, count(d.id)::int AS doctors_count
FROM specialties s
         LEFT JOIN doctors d ON d.specialty_id = s.id AND d.is_active
GROUP BY s.id
ORDER BY s.name;

-- name: GetSpecialty :one
SELECT * FROM specialties WHERE id = sqlc.arg('id');

-- name: CreateSpecialty :one
INSERT INTO specialties (name, icon)
VALUES (sqlc.arg('name'), sqlc.narg('icon'))
    RETURNING *;

-- name: UpdateSpecialty :one
UPDATE specialties SET
                       name = COALESCE(sqlc.narg('name'), name),
                       icon = COALESCE(sqlc.narg('icon'), icon)
WHERE id = sqlc.arg('id')
    RETURNING *;

-- name: DeleteSpecialty :exec
DELETE FROM specialties WHERE id = sqlc.arg('id');