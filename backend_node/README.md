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
   - `CLOUDINARY_CLOUD_NAME` = tu cloud name de Cloudinary
   - `CLOUDINARY_API_KEY` = tu API key de Cloudinary
   - `CLOUDINARY_API_SECRET` = tu API secret de Cloudinary

## 🖼️ Subida de imágenes (Cloudinary)

La app sube las imágenes directamente desde el celular (galería) en base64 al
endpoint `POST /api/upload`, que las almacena en Cloudinary y devuelve la URL
pública para guardarla en el campo `imagen` del item.

Body esperado:
```json
{
  "image": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ...",
  "itemId": "uuid-del-item"
}
```

Si se envía `itemId`, la imagen se guarda con ese mismo `public_id` en
Cloudinary (`overwrite: true`), de modo que subir una nueva imagen para el
mismo item reemplaza automáticamente la anterior en lugar de acumular
archivos.

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
| POST | `/api/upload` | Subir imagen a Cloudinary (`image`, `itemId`) |

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
