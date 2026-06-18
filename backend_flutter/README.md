# MediaExplorer Backend API

Backend Node.js + Express que actúa como intermediario entre la app Flutter y MongoDB Atlas. Compatible con Vercel.

## 🚀 Instalación local

```bash
npm install
cp .env.example .env
npm run dev
```

## 🌐 Deploy en Vercel

1. Instala Vercel CLI: `npm i -g vercel`
2. Ejecuta: `vercel`
3. Configura las variables de entorno en el dashboard de Vercel:
   - `MONGODB_URI` = tu string de conexión
   - `DB_NAME` = `flutter_1`
   - `COLLECTION_NAME` = `items_coleccion`

## 📋 Endpoints

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/` | Health check |
| GET | `/api/items` | Listar items (paginación + filtros) |
| GET | `/api/items/stats` | Estadísticas globales |
| POST | `/api/items/check-duplicate` | Verificar duplicado |
| GET | `/api/items/:id` | Detalle de item |
| POST | `/api/items` | Crear item |
| PUT | `/api/items/:id` | Actualizar item |
| DELETE | `/api/items/:id` | Eliminar item |
| GET | `/api/cheapshark/deals` | Deals externos |
| GET | `/api/cheapshark/deals/:id` | Detalle deal |

## 🔍 Query params para GET /api/items

- `page` (default: 0)
- `limit` (default: 10)
- `search` — buscar por título
- `categoria` — filtrar por categoría
- `plataforma` — filtrar por plataforma

## 🔍 Query params para GET /api/cheapshark/deals

- `page` (default: 0)
- `pageSize` (default: 10)
- `title` — buscar por título de juego
