# BCCK — Restaurant Ordering App

A full-stack restaurant ordering application built with **Flutter** (mobile frontend) and **Node.js / Express** (REST API backend), backed by a **PostgreSQL** database hosted on Neon.

**Author:** Nguyen Minh Nghi — minhhnghiii@gmail.com

---

## Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Backend Setup](#backend-setup)
  - [Frontend Setup](#frontend-setup)
- [API Reference](#api-reference)
- [Database Schema](#database-schema)
- [Environment Variables](#environment-variables)
- [Screenshots / User Flow](#screenshots--user-flow)
- [License](#license)

---

## Overview

BCCK is a mobile-first restaurant ordering platform where users can:

- Browse food categories and menu items
- Manage a shopping cart
- Checkout with automatic discount, tax, and delivery fee calculation
- View order receipts

The project is split into two independent sub-projects:

| Sub-project | Path | Purpose |
|---|---|---|
| Flutter app | `frontend/` | Cross-platform mobile/web UI |
| Express API | `restaurant-backend/` | RESTful backend + business logic |

---

## Tech Stack

### Frontend
| Technology | Version | Role |
|---|---|---|
| Dart | 3.11.4+ | Language |
| Flutter | stable | UI framework |
| Provider | 6.1.2 | State management |
| GoRouter | 14.6.2 | Navigation / routing |
| http | 1.2.2 | HTTP client |
| SharedPreferences | 2.3.0 | Local session storage |
| CachedNetworkImage | 3.4.1 | Image loading & caching |
| Badges | 3.1.2 | Cart count badge |

### Backend
| Technology | Version | Role |
|---|---|---|
| Node.js | 18+ | Runtime |
| Express.js | 5.2.1 | Web framework |
| PostgreSQL (Neon) | — | Database |
| pg | 8.20.0 | PostgreSQL client |
| jsonwebtoken | 9.0.3 | JWT authentication |
| bcryptjs | 3.0.3 | Password hashing |
| dotenv | 17.4.2 | Environment config |
| cors | 2.8.6 | CORS middleware |
| nodemon | 3.1.14 | Dev hot-reload |

---

## Project Structure

```
BCCK-Flutter/
├── docs/                              # Project documents / requirements
│   └── KTGK01 (1).pdf
│
├── frontend/                          # Flutter application
│   ├── lib/
│   │   ├── main.dart                  # App entry point, theme, session restore
│   │   ├── models/                    # Data classes (fromJson / toJson)
│   │   │   ├── cart_item_model.dart
│   │   │   ├── category_model.dart
│   │   │   ├── food_model.dart
│   │   │   └── user_model.dart
│   │   ├── router/
│   │   │   └── app_router.dart        # GoRouter config + auth redirect
│   │   ├── screens/                   # Page-level widgets
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   ├── categories_screen.dart
│   │   │   ├── food_list_screen.dart
│   │   │   ├── cart_screen.dart
│   │   │   └── payment_screen.dart
│   │   ├── services/                  # API layer (one service per domain)
│   │   │   ├── api_client.dart        # HTTP client with JWT injection
│   │   │   ├── auth_service.dart
│   │   │   ├── cart_service.dart
│   │   │   ├── food_service.dart
│   │   │   └── order_service.dart
│   │   ├── store/
│   │   │   └── index.dart             # AppProvider — global app state
│   │   └── widgets/                   # Reusable UI components
│   │       ├── app_drawer.dart
│   │       ├── bill_receipt.dart
│   │       ├── cart_badge_icon.dart
│   │       ├── category_card.dart
│   │       ├── food_card.dart
│   │       └── quantity_control.dart
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── windows/
│   ├── linux/
│   ├── macos/
│   ├── test/
│   └── pubspec.yaml
│
└── restaurant-backend/                # Node.js Express API
    ├── src/
    │   ├── app.js                     # Express setup, route registration, error handler
    │   ├── config/
    │   │   └── db.js                  # PostgreSQL connection pool (Neon + SSL)
    │   ├── controllers/               # Business logic
    │   │   ├── auth.controller.js
    │   │   ├── cart.controller.js
    │   │   ├── category.controller.js
    │   │   ├── food.controller.js
    │   │   └── order.controller.js
    │   ├── middleware/
    │   │   └── auth.middleware.js     # JWT verification
    │   └── routes/                    # Route declarations
    │       ├── auth.routes.js
    │       ├── cart.routes.js
    │       ├── category.routes.js
    │       ├── food.routes.js
    │       └── order.routes.js
    ├── docs/
    │   └── restaurant-api.postman_collection.json
    ├── .env.example
    └── package.json
```

---

## Features

- **Authentication** — Register, login, JWT-based session, forgot password
- **Browse** — Category listing and per-category food list with images and prices
- **Cart** — Add / remove / adjust quantities; server-side persistence per user
- **Checkout** — Automatic order total with 1.7 % discount, 8 % tax, and flat delivery fee
- **Order receipt** — Full itemized bill displayed after checkout
- **Cross-platform** — Runs on Android, iOS, Web, Windows, Linux, and macOS

---

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.11.4
- Dart SDK ≥ 3.11.4
- Node.js ≥ 18
- A Neon (or any PostgreSQL) database

---

### Backend Setup

```bash
cd restaurant-backend

# Install dependencies
npm install

# Copy environment template and fill in your values
cp .env.example .env
# Edit .env — see Environment Variables section below

# Start development server (hot-reload)
npm run dev

# Or start production server
npm start
```

The API will be available at `http://localhost:3000`.

---

### Frontend Setup

```bash
cd frontend

# Install Flutter packages
flutter pub get

# Run on connected device or emulator
flutter run
```

> **API base URL note**
> The base URL is set in `lib/services/api_client.dart`.
> - Android emulator → `http://10.0.2.2:3000`
> - iOS simulator → `http://127.0.0.1:3000`
> - Physical device → replace with your machine's local IP, e.g. `http://192.168.x.x:3000`

---

## API Reference

A full Postman collection is available at `restaurant-backend/docs/restaurant-api.postman_collection.json`.

### Auth

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| POST | `/api/auth/register` | — | Create account |
| POST | `/api/auth/login` | — | Login, returns JWT |
| POST | `/api/auth/forgot-password` | — | Password reset |

### Categories

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/api/categories` | JWT | List all categories |

### Foods

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/api/foods` | JWT | List all foods |
| GET | `/api/foods?categoryId=:id` | JWT | Filter by category |
| GET | `/api/foods/:id` | JWT | Single food item |

### Cart

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/api/cart` | JWT | Get current user's cart |
| POST | `/api/cart` | JWT | Add item (upsert) |
| PUT | `/api/cart/:id` | JWT | Update item quantity |
| DELETE | `/api/cart/:id` | JWT | Remove item |

### Orders

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| POST | `/api/orders/checkout` | JWT | Checkout cart → creates order |
| GET | `/api/orders/:id` | JWT | Get order by ID |

---

## Database Schema

```sql
users (
  id           SERIAL PRIMARY KEY,
  email        TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  full_name    TEXT,
  created_at   TIMESTAMPTZ DEFAULT now()
)

categories (
  id        SERIAL PRIMARY KEY,
  name      TEXT NOT NULL,
  image_url TEXT,
  culture   TEXT
)

foods (
  id          SERIAL PRIMARY KEY,
  name        TEXT NOT NULL,
  category_id INT REFERENCES categories(id),
  price       NUMERIC(10,2) NOT NULL,
  image_url   TEXT,
  description TEXT
)

cart_items (
  id       SERIAL PRIMARY KEY,
  user_id  INT REFERENCES users(id),
  food_id  INT REFERENCES foods(id),
  quantity INT NOT NULL DEFAULT 1,
  UNIQUE (user_id, food_id)
)

orders (
  id              SERIAL PRIMARY KEY,
  user_id         INT REFERENCES users(id),
  items_total     NUMERIC(10,2),
  discount        NUMERIC(10,2),
  tax             NUMERIC(10,2),
  delivery_charge NUMERIC(10,2),
  total_pay       NUMERIC(10,2),
  status          TEXT DEFAULT 'pending',
  created_at      TIMESTAMPTZ DEFAULT now()
)

order_items (
  order_id   INT REFERENCES orders(id),
  food_id    INT REFERENCES foods(id),
  quantity   INT NOT NULL,
  unit_price NUMERIC(10,2) NOT NULL
)
```

---

## Environment Variables

Create `restaurant-backend/.env` from `.env.example`:

```env
DATABASE_URL=postgresql://<user>:<password>@<host>/<database>?sslmode=require
JWT_SECRET=your_jwt_secret_here
JWT_EXPIRES_IN=7d
PORT=3000
```

| Variable | Description |
|---|---|
| `DATABASE_URL` | Full Neon (or PostgreSQL) connection string |
| `JWT_SECRET` | Secret used to sign and verify JWTs |
| `JWT_EXPIRES_IN` | Token lifetime (e.g. `7d`, `24h`) |
| `PORT` | Port the Express server listens on |

---

## Screenshots / User Flow

```
Login / Register
      ↓
Category List  →  Food List  →  Cart  →  Checkout / Receipt
```

---

## License

This project is for educational purposes.
