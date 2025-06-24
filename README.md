# Currency Converter

The objective of this project is to create a simple API that allows users to convert values between different currencies.
---

## 🚀 Technologies

- Ruby 3.2
- Rails 7
- PostgreSQL
- Docker + Docker Compose

---

## ⚙️ Setup

### 1. Clone the repository

```bash
git clone https://github.com/darwinssilva/currency-converter.git
cd currency-converter
```

### 2. Build the Docker containers

```bash
docker compose build
```

### 3. Initialize the Rails application
```bash
docker compose run web rails new . --force --no-deps --database=postgresql
```
Change the `config/database.yml` to use the `db` service as the host for the database connection.

### 4. Start the Docker containers

```bash
docker compose up
```

## 🗃️ Database

### 1. Access the web container's bash:

```bash
docker compose exec web bash
```

### 2. Now you can run the Rails commands to create, migrate, and seed the database:

```bash
rails db:create
rails db:migrate
rails db:seed
```

## 📄 API Documentation (Swagger)

You can explore and test the API using Swagger UI.

### 1. Access it via browser:

```bash
http://localhost:3000/api-docs/index.html
```

## 🧪 Running tests

```bash
docker compose exec web bash
bundle exec rspec
```
