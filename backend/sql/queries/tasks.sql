-- name: ListTasks :many
SELECT id, title, description, done, created_at, updated_at
FROM tasks
ORDER BY id
LIMIT $1 OFFSET $2;

-- name: GetTask :one
SELECT id, title, description, done, created_at, updated_at
FROM tasks
WHERE id = $1;

-- name: CreateTask :one
INSERT INTO tasks (title, description, done)
VALUES ($1, $2, $3)
RETURNING id, title, description, done, created_at, updated_at;

-- name: UpdateTask :one
UPDATE tasks
SET title = $2, description = $3, done = $4, updated_at = NOW()
WHERE id = $1
RETURNING id, title, description, done, created_at, updated_at;

-- name: PatchTask :one
UPDATE tasks
SET
    title       = COALESCE($2, title),
    description = COALESCE($3, description),
    done        = COALESCE($4, done),
    updated_at  = NOW()
WHERE id = $1
RETURNING id, title, description, done, created_at, updated_at;

-- name: DeleteTask :exec
DELETE FROM tasks WHERE id = $1;
