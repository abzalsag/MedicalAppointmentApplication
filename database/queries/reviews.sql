-- name: CreateReview :one
INSERT INTO reviews (appointment_id, patient_id, doctor_id, rating, comment)
SELECT a.id, a.patient_id, a.doctor_id, sqlc.arg('rating'), sqlc.narg('comment')
FROM appointments a
WHERE a.id = sqlc.arg('appointment_id')
  AND a.patient_id = sqlc.arg('patient_id')
  AND a.status = 'completed'
    RETURNING *;

-- name: GetReview :one
SELECT * FROM reviews WHERE id = sqlc.arg('id');

-- name: GetReviewByAppointment :one
SELECT * FROM reviews WHERE appointment_id = sqlc.arg('appointment_id');

-- name: ListDoctorReviews :many

SELECT r.id, r.rating, r.comment, r.created_at, p.full_name AS patient_name
FROM reviews r
         JOIN patients p ON p.id = r.patient_id
WHERE r.doctor_id = sqlc.arg('doctor_id')
ORDER BY r.created_at DESC
    LIMIT sqlc.arg('limit_count') OFFSET sqlc.arg('offset_count');

-- name: ListMyReviews :many
SELECT r.id, r.rating, r.comment, r.created_at,
       d.id AS doctor_id, d.full_name AS doctor_name
FROM reviews r
         JOIN doctors d ON d.id = r.doctor_id
WHERE r.patient_id = sqlc.arg('patient_id')
ORDER BY r.created_at DESC;

-- name: UpdateReview :one
UPDATE reviews SET
                   rating  = COALESCE(sqlc.narg('rating'), rating),
                   comment = COALESCE(sqlc.narg('comment'), comment)
WHERE id = sqlc.arg('id')
  AND patient_id = sqlc.arg('patient_id')
    RETURNING *;

-- name: DeleteReview :exec
DELETE FROM reviews
WHERE id = sqlc.arg('id')
  AND patient_id = sqlc.arg('patient_id');

-- name: GetDoctorRatingDistribution :many
SELECT rating, count(*)::int AS total
FROM reviews
WHERE doctor_id = sqlc.arg('doctor_id')
GROUP BY rating
ORDER BY rating DESC;

-- name: RecalcDoctorRating :exec
UPDATE doctors SET
                   rating = COALESCE(
                           (SELECT ROUND(AVG(r.rating)::numeric, 1) FROM reviews r WHERE r.doctor_id = sqlc.arg('doctor_id')),
                           0
                            ),
                   reviews_count = (SELECT count(*) FROM reviews r WHERE r.doctor_id = sqlc.arg('doctor_id')),
                   updated_at = now()
WHERE id = sqlc.arg('doctor_id');