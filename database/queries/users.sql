-- name: CreateUser :one
INSERT INTO users (email, phone, password_hash, role)
VALUES (sqlc.arg('email'), sqlc.narg('phone'), sqlc.arg('password_hash'), sqlc.arg('role'))
    RETURNING *;

-- name: GetUserByID :one
SELECT * FROM users WHERE id = sqlc.arg('id');

-- name: GetUserByEmail :one
SELECT * FROM users WHERE lower(email) = lower(sqlc.arg('email'));

-- name: GetUserByPhone :one
SELECT * FROM users WHERE phone = sqlc.arg('phone');

-- name: EmailExists :one
SELECT EXISTS (
    SELECT 1 FROM users WHERE lower(email) = lower(sqlc.arg('email'))
) AS exists;

-- name: PhoneExists :one
SELECT EXISTS (
    SELECT 1 FROM users WHERE phone = sqlc.arg('phone')
) AS exists;

-- name: UpdateUserPhone :exec
UPDATE users
SET phone = sqlc.narg('phone'), updated_at = now()
WHERE id = sqlc.arg('id');

-- name: UpdateUserPassword :exec
UPDATE users
SET password_hash = sqlc.arg('password_hash'), updated_at = now()
WHERE id = sqlc.arg('id');

-- name: UpdateUserRole :one
UPDATE users
SET role = sqlc.arg('role'), updated_at = now()
WHERE id = sqlc.arg('id')
    RETURNING *;

-- name: ListUsers :many
-- Admin үшін: рөл бойынша сүзгі міндетті емес.
SELECT id, email, phone, role, created_at
FROM users
WHERE (sqlc.narg('role')::user_role IS NULL OR role = sqlc.narg('role'))
ORDER BY created_at DESC
    LIMIT sqlc.arg('limit_count') OFFSET sqlc.arg('offset_count');

-- name: CountUsers :one
SELECT count(*)::int FROM users
WHERE (sqlc.narg('role')::user_role IS NULL OR role = sqlc.narg('role'));

-- name: DeleteUser :exec
DELETE FROM users WHERE id = sqlc.arg('id');