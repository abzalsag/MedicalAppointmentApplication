-- name: CreateNotification :one
INSERT INTO notifications (user_id, type, title, body)
VALUES (sqlc.arg('user_id'), sqlc.arg('type'), sqlc.arg('title'), sqlc.narg('body'))
    RETURNING *;

-- name: GetNotification :one
SELECT * FROM notifications
WHERE id = sqlc.arg('id') AND user_id = sqlc.arg('user_id');

-- name: ListNotifications :many
SELECT * FROM notifications
WHERE user_id = sqlc.arg('user_id')
ORDER BY created_at DESC
    LIMIT sqlc.arg('limit_count') OFFSET sqlc.arg('offset_count');

-- name: ListUnreadNotifications :many
SELECT * FROM notifications
WHERE user_id = sqlc.arg('user_id') AND NOT is_read
ORDER BY created_at DESC;

-- name: CountUnreadNotifications :one
SELECT count(*)::int AS unread
FROM notifications
WHERE user_id = sqlc.arg('user_id') AND NOT is_read;

-- name: MarkNotificationRead :exec
UPDATE notifications
SET is_read = TRUE
WHERE id = sqlc.arg('id') AND user_id = sqlc.arg('user_id');

-- name: MarkAllNotificationsRead :exec
UPDATE notifications
SET is_read = TRUE
WHERE user_id = sqlc.arg('user_id') AND NOT is_read;

-- name: DeleteNotification :exec
DELETE FROM notifications
WHERE id = sqlc.arg('id') AND user_id = sqlc.arg('user_id');

-- name: DeleteOldNotifications :exec
DELETE FROM notifications
WHERE created_at < sqlc.arg('before')::timestamptz AND is_read;