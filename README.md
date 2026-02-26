# gotasks

Monorepo com backend em Go e frontend em React + TypeScript para gerenciamento de tarefas.

## Estrutura

```
gotasks/
├── backend/          # API Go (chi + PostgreSQL + sqlc)
│   ├── internal/
│   │   ├── api/      # Handlers e rotas
│   │   └── generated/db/  # Código gerado pelo sqlc
│   ├── sql/
│   │   ├── migrations/    # Migrations SQL
│   │   └── queries/       # Queries SQL (sqlc)
│   ├── sqlc.yaml
│   └── main.go
└── frontend/         # React + TypeScript (Vite)
    └── src/api/      # Client fetch + módulo tasks
```

## Desenvolvimento com Codespaces / Dev Containers

A configuração em `.devcontainer/` permite abrir o projeto direto no GitHub Codespaces ou no VS Code com a extensão [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers), sem nenhuma instalação manual.

### O que é provisionado automaticamente

| Componente | Versão |
|---|---|
| Go | 1.24 |
| Node.js | 22 |
| PostgreSQL | 16 |
| `sqlc` | latest |
| `migrate` (golang-migrate) | latest |

### Abrindo no GitHub Codespaces

1. Clique em **Code → Codespaces → Create codespace on main** no repositório.
2. Aguarde o container iniciar (o `postCreateCommand` instala as dependências automaticamente).
3. O banco de dados Postgres já está disponível em `db:5432` (dentro do container) ou `localhost:5432` (a partir do host).

### Abrindo no VS Code com Dev Containers

1. Instale a extensão [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) e o [Docker](https://docs.docker.com/get-docker/).
2. Abra o repositório no VS Code e clique em **Reopen in Container** quando solicitado (ou use `Ctrl+Shift+P → Dev Containers: Reopen in Container`).

### Variáveis de ambiente no devcontainer

As variáveis já são definidas via `remoteEnv` no `devcontainer.json` e ficam disponíveis no terminal do container:

| Variável | Valor padrão (devcontainer) |
|---|---|
| `DATABASE_URL` | `postgres://postgres:postgres@db:5432/gotasks?sslmode=disable` |
| `PORT` | `8080` |
| `CORS_ORIGINS` | `http://localhost:5173` |
| `VITE_API_URL` | `http://localhost:8080` |

> **Nota:** Fora do devcontainer (host), use `localhost` no lugar de `db` na DATABASE_URL (ex.: `postgres://postgres:postgres@localhost:5432/gotasks?sslmode=disable`).

### Primeiros passos dentro do container

```bash
# 1. Aplicar migrations
make migrate-up

# 2. (Opcional) Regenerar código sqlc após alterar queries SQL
make sqlc-gen

# 3. Rodar o backend (porta 8080)
make backend

# 4. Em outro terminal, rodar o frontend (porta 5173)
make frontend
```

Os comandos `make migrate-up` e `make backend` lêem a variável `DATABASE_URL` já configurada. Para ver todos os alvos disponíveis:

```bash
make help
```

### Portas encaminhadas

| Porta | Serviço |
|---|---|
| 8080 | Backend API |
| 5173 | Frontend Vite |
| 5432 | PostgreSQL |

---

## Pré-requisitos

- Go 1.24+
- Node.js 18+
- PostgreSQL 14+
- [golang-migrate](https://github.com/golang-migrate/migrate) (para migrations)
- [sqlc](https://sqlc.dev/) (para regenerar código gerado)

## Rodando localmente

### 1. Banco de dados

```bash
# Crie o banco
createdb gotasks

# Execute as migrations (com golang-migrate instalado)
migrate -path backend/sql/migrations -database "postgres://postgres:postgres@localhost:5432/gotasks?sslmode=disable" up
```

### 2. Backend

```bash
cd backend

# Copie e edite as variáveis de ambiente
cp .env.example .env

# Instale dependências e rode
go mod download
go run .
```

Variáveis de ambiente do backend (`.env`):

| Variável       | Descrição                                         | Exemplo                                         |
|----------------|---------------------------------------------------|-------------------------------------------------|
| `DATABASE_URL` | URL de conexão ao PostgreSQL                      | `postgres://user:pass@localhost:5432/gotasks?sslmode=disable` |
| `PORT`         | Porta do servidor (default: `8080`)               | `8080`                                          |
| `CORS_ORIGINS` | Origins CORS separadas por vírgula                | `http://localhost:5173,https://meusite.com`     |

### 3. Frontend

```bash
cd frontend

# Copie e edite as variáveis de ambiente
cp .env.example .env.local

# Instale dependências e rode
npm install
npm run dev
```

Variáveis de ambiente do frontend (`.env.local`):

| Variável        | Descrição             | Exemplo                    |
|-----------------|-----------------------|----------------------------|
| `VITE_API_URL`  | URL base da API       | `http://localhost:8080`    |

### 4. Regenerar código sqlc

```bash
cd backend
sqlc generate
```

## API

Base URL: `http://localhost:8080`

### Health Check

| Método | Rota      | Descrição   |
|--------|-----------|-------------|
| GET    | /healthz  | Health check|

### Tasks

| Método | Rota                      | Descrição                        |
|--------|---------------------------|----------------------------------|
| GET    | /api/v1/tasks?limit=&offset= | Listar tarefas (paginação)    |
| POST   | /api/v1/tasks             | Criar tarefa                     |
| GET    | /api/v1/tasks/{id}        | Buscar tarefa por ID             |
| PUT    | /api/v1/tasks/{id}        | Atualizar tarefa (completo)      |
| PATCH  | /api/v1/tasks/{id}        | Atualizar tarefa (parcial)       |
| DELETE | /api/v1/tasks/{id}        | Deletar tarefa                   |

#### Payload POST/PUT

```json
{
  "title": "Minha tarefa",
  "description": "Opcional",
  "done": false
}
```

#### Payload PATCH (todos os campos opcionais)

```json
{
  "title": "Novo título",
  "done": true
}
```

## Deploy no Render

### Backend — Web Service

- **Root Directory:** `backend`
- **Build Command:**
  ```
  go build -o server . && curl -L https://github.com/golang-migrate/migrate/releases/download/v4.18.1/migrate.linux-amd64.tar.gz | tar xvz && mv migrate /opt/render/project/go/bin/migrate
  ```
- **Start Command:**
  ```
  migrate -path sql/migrations -database "$DATABASE_URL" up && ./server
  ```
- **Health Check Path:** `/healthz`
- **Variáveis de ambiente:**
  - `DATABASE_URL` — URL do banco PostgreSQL (ex.: Render Postgres)
  - `PORT` — definido automaticamente pelo Render
  - `CORS_ORIGINS` — ex.: `https://meu-frontend.onrender.com`

### Frontend — Static Site

- **Root Directory:** `frontend`
- **Build Command:** `npm install && npm run build`
- **Publish Directory:** `dist`
- **Variáveis de ambiente:**
  - `VITE_API_URL` — URL do backend no Render (ex.: `https://gotasks-api.onrender.com`)
