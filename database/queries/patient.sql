-- name: CreatePatient :one
INSERT INTO patients (user_id, full_name, birth_date, gender, iin)
VALUES (
           sqlc.arg('user_id'),
           sqlc.arg('full_name'),
           sqlc.narg('birth_date'),
           sqlc.narg('gender'),
           sqlc.narg('iin')
       )
    RETURNING *;

-- name: GetPatientByID :one
SELECT * FROM patients WHERE id = sqlc.arg('id');

-- name: GetPatientByUserID :one
SELECT * FROM patients WHERE user_id = sqlc.arg('user_id');

-- name: GetPatientProfile :one
SELECT
    p.id, p.user_id, p.full_name, p.birth_date, p.gender, p.iin,
    p.avatar_url, p.prefs, p.created_at,
    u.email, u.phone
FROM patients p
         JOIN users u ON u.id = p.user_id
WHERE p.user_id = sqlc.arg('user_id');

-- name: UpdatePatient :one

UPDATE patients SET
                    full_name  = COALESCE(sqlc.narg('full_name'), full_name),
                    birth_date = COALESCE(sqlc.narg('birth_date'), birth_date),
                    gender     = COALESCE(sqlc.narg('gender'), gender),
                    iin        = COALESCE(sqlc.narg('iin'), iin),
                    avatar_url = COALESCE(sqlc.narg('avatar_url'), avatar_url),
                    updated_at = now()
WHERE id = sqlc.arg('id')
    RETURNING *;

-- name: UpdatePatientPrefs :one

UPDATE patients
SET prefs = prefs || sqlc.arg('prefs')::jsonb,
    updated_at = now()
WHERE id = sqlc.arg('id')
    RETURNING *;

-- name: ListPatients :many

SELECT p.id, p.full_name, p.birth_date, u.email, u.phone, p.created_at
FROM patients p
         JOIN users u ON u.id = p.user_id
WHERE (sqlc.narg('q')::text IS NULL OR p.full_name ILIKE '%' || sqlc.narg('q') || '%')
ORDER BY p.created_at DESC
    LIMIT sqlc.arg('limit_count') OFFSET sqlc.arg('offset_count');

-- name: DeletePatient :exec
DELETE FROM patients WHERE id = sqlc.arg('id');