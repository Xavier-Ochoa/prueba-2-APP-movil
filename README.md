#  MediaExplorer App

**Aplicación móvil Flutter para explorar y gestionar una colección multimedia personal, con backend Node.js en Vercel, base de datos MongoDB Atlas y almacenamiento de imágenes en Cloudinary.**

> Desarrollado por **Xavier Ochoa** · ESFOT – Escuela de Formación de Tecnólogos · Proyecto académico de Desarrollo de Software

---

## 📋 Tabla de contenidos

- [Descripción general](#descripción-general)
- [Backend](#backend)
- [API consumida: CheapShark](#api-consumida-cheapshark)
- [Subida de imágenes (Cloudinary)](#subida-de-imágenes-cloudinary)
- [CRUD en MongoDB Atlas](#crud-en-mongodb-atlas)
- [Infinite Scrolling](#infinite-scrolling)
- [Pantallas de la app](#pantallas-de-la-app)
- [Instrucciones de ejecución](#instrucciones-de-ejecución)
- [Asistencia de IA en el desarrollo](#asistencia-de-ia-en-el-desarrollo)
- [Funcionalidades extras](#funcionalidades-extras)
- [Evidencias y capturas](#evidencias-y-capturas)

---

## Descripción general

MediaExplorer es una app Flutter que permite al usuario:

- Guardar y organizar items multimedia (videojuegos, libros, series, etc.) en MongoDB Atlas
- Subir la imagen de cada item directamente desde la galería del celular, almacenada en Cloudinary
- Explorar ofertas de videojuegos en tiempo real desde la API pública de CheapShark
- Guardar items externos a la colección propia con un toque
- Navegar entre pantallas con un diseño Material Design 3

**Stack tecnológico:**

| Capa | Tecnología |
|------|-----------|
| Frontend | Flutter 3.x + Provider |
| Backend | Node.js + Express |
| Base de datos | MongoDB Atlas |
| Almacenamiento de imágenes | Cloudinary |
| Deploy backend | Vercel |
| API externa | CheapShark API |

---

## Backend

El backend actúa como intermediario entre la app Flutter y los servicios externos (MongoDB Atlas y Cloudinary). Está construido con **Node.js + Express** y desplegado en **Vercel** (plan gratuito).

Flutter nunca se conecta directamente a MongoDB ni a Cloudinary: todas las credenciales viven solo en el backend, como variables de entorno.

**URL de producción:** `https://back-flutter-1.vercel.app`

**Estructura del proyecto:**

```
back_flutter_1-main/
├── src/
│   ├── config/
│   │   ├── database.js            ← conexión MongoDB Atlas
│   │   └── cloudinary.js          ← configuración del SDK de Cloudinary
│   ├── controllers/
│   │   ├── itemsController.js     ← lógica CRUD de items
│   │   ├── cheapsharkController.js← proxy hacia la API externa
│   │   └── uploadController.js    ← subida de imágenes a Cloudinary
│   ├── middleware/
│   │   └── errorHandler.js        ← manejo centralizado de errores
│   ├── routes/
│   │   ├── items.js
│   │   ├── cheapshark.js
│   │   └── upload.js
│   └── index.js                   ← Express app
├── .env.example                   ← variables de entorno requeridas
└── vercel.json                    ← configuración de deploy
```

### Endpoints disponibles

| Método | Endpoint | Descripción |
|--------|----------|--------------|
| `GET` | `/` | Health check; confirma que el servidor está activo |
| `GET` | `/api/items` | Lista items con paginación, búsqueda y filtros (`page`, `limit`, `search`, `categoria`, `plataforma`) |
| `GET` | `/api/items/stats` | Estadísticas globales: total de items, promedio de precios, stock total |
| `GET` | `/api/items/filters` | Categorías y plataformas actualmente en uso, para poblar los filtros |
| `POST` | `/api/items/check-duplicate` | Verifica si ya existe un item con el mismo título y fuente |
| `GET` | `/api/items/:id` | Obtiene el detalle de un item por su id |
| `POST` | `/api/items` | Crea un nuevo item en la colección |
| `PUT` | `/api/items/:id` | Actualiza un item existente |
| `DELETE` | `/api/items/:id` | Elimina un item |
| `GET` | `/api/cheapshark/deals` | Proxy paginado a CheapShark (`pageNumber`, `pageSize`, `title`) |
| `GET` | `/api/cheapshark/deals/:dealId` | Detalle de una oferta puntual de CheapShark |
| `POST` | `/api/upload` | Sube una imagen en base64 a Cloudinary y devuelve su URL pública (ver [Subida de imágenes](#subida-de-imágenes-cloudinary)) |

### Variables de entorno

El backend necesita las siguientes variables, definidas en `.env` (local) o en el dashboard de Vercel (producción):

| Variable | Descripción |
|----------|--------------|
| `MONGODB_URI` | String de conexión a MongoDB Atlas |
| `DB_NAME` | Nombre de la base de datos (`flutter_1`) |
| `COLLECTION_NAME` | Nombre de la colección (`items_coleccion`) |
| `CLOUDINARY_CLOUD_NAME` | Cloud name de la cuenta de Cloudinary |
| `CLOUDINARY_API_KEY` | API key de Cloudinary |
| `CLOUDINARY_API_SECRET` | API secret de Cloudinary |

---

## API consumida: CheapShark

**URL base:** `https://www.cheapshark.com/api/1.0`

CheapShark es una API pública y gratuita (sin API key) que devuelve ofertas de videojuegos de múltiples tiendas digitales como Steam, Epic Games, GOG y más.

**¿Por qué CheapShark?**
- Soporta paginación real con `pageNumber` y `pageSize` (ideal para infinite scrolling)
- Devuelve imágenes, precios y puntuaciones de Metacritic
- Sus campos mapean de forma natural al modelo `ItemColeccion`

**Endpoint principal usado:**

```
GET https://www.cheapshark.com/api/1.0/deals?pageNumber=0&pageSize=10
```

**Mapeo al modelo local:**

| Campo CheapShark | Campo ItemColeccion |
|-----------------|-------------------|
| `title` | `titulo` |
| `salePrice` | `precio` |
| `thumb` | `imagen` |
| `storeID` | `plataforma` (nombre de tienda) |
| `normalPrice` + `metacriticScore` | `descripcion` |
| — | `fuente: "CheapShark API"` |

---

## Subida de imágenes (Cloudinary)

Cada item de la colección tiene una imagen asociada, guardada en **Cloudinary** en lugar de pedir una URL externa.

**Flujo en la app:**

1. En el formulario de crear/editar item, el usuario toca **"Elegir imagen de la galería"** y selecciona una foto del celular (`image_picker`).
2. Al guardar, la app codifica la imagen en base64 y la envía a `POST /api/upload`.
3. El backend sube la imagen a Cloudinary usando el `id` del item como `public_id`, con `overwrite: true`.
4. Cloudinary responde con la URL pública de la imagen, que se guarda en el campo `imagen` del item.

**Body esperado por `/api/upload`:**

```json
{
  "image": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ...",
  "itemId": "uuid-del-item"
}
```

Como se reutiliza el mismo `public_id` (el `itemId`), **editar un item y subir una nueva imagen reemplaza automáticamente la anterior en Cloudinary**, sin acumular archivos huérfanos.

---

## CRUD en MongoDB Atlas

La app implementa las cuatro operaciones completas contra la colección `items_coleccion` en MongoDB Atlas.

**Modelo principal — `ItemColeccion`:**

```dart
class ItemColeccion {
  final String id;        // UUID generado localmente
  final String titulo;
  final String categoria;
  final String plataforma;
  final double precio;
  final int stock;
  final String imagen;    // URL de Cloudinary
  final String descripcion;
  final String fuente;    // "manual" o "CheapShark API"
}
```

### Operaciones implementadas

**Create** — Desde el formulario manual o al guardar un deal de CheapShark:
```dart
await ApiService.createItem(item);  // POST /api/items
```

**Read** — Lista paginada con búsqueda y filtros, y vista de detalle:
```dart
await ApiService.getItems(page: 0, search: 'halo', categoria: 'Videojuego');
```

**Update** — Formulario precargado con los datos actuales del item:
```dart
await ApiService.updateItem(item.id, itemActualizado);  // PUT /api/items/:id
```

**Delete** — Con confirmación mediante `AlertDialog` antes de eliminar:
```dart
await ApiService.deleteItem(item.id);  // DELETE /api/items/:id
```

---

## Infinite Scrolling

Tanto la lista local (`CollectionPage`) como el explorador de API (`ApiExplorerPage`) implementan carga progresiva de datos.

**Lógica base utilizada:**

```dart
final ScrollController _scrollController = ScrollController();

@override
void initState() {
  super.initState();
  provider.loadMore();

  _scrollController.addListener(() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      provider.loadMore();
    }
  });
}
```

El método `loadMore()` en los providers controla el estado de carga y evita llamadas duplicadas:

```dart
Future<void> loadMore() async {
  if (_loading || !_hasMore) return;  // evita llamadas dobles
  // ... fetch paginado al backend
  _hasMore = result['hasMore'];       // para cuando no hay más datos
}
```

**Características adicionales:**
- Pull to refresh con `RefreshIndicator`
- Skeleton loading con `shimmer` mientras carga
- Estado `hasMore` para detener el scroll cuando se agotan los datos

---

## Pantallas de la app

La app cuenta con **7 pantallas** conectadas mediante navegación nombrada:

| Pantalla | Ruta | Descripción |
|----------|------|-------------|
| **HomePage** | `/` | Menú principal con accesos directos y estadísticas rápidas (total items, promedio de precio, stock total) |
| **CollectionPage** | `/collection` | Lista de items guardados en MongoDB. Incluye búsqueda por título, filtros por categoría y plataforma, pull to refresh e infinite scrolling |
| **FormPage** | `/form` | Formulario para crear o editar items, con selector de imagen desde la galería (subida a Cloudinary). Se precarga automáticamente con los datos del item cuando es edición. Incluye validaciones en todos los campos |
| **DetailPage** | `/detail` | Vista completa de un item con imagen, precio, stock, descripción y metadata. Desde aquí se puede editar o eliminar con confirmación |
| **ApiExplorerPage** | `/api-explorer` | Explorador de deals de CheapShark con infinite scrolling y búsqueda. Botón "Guardar" en cada card para agregar a la colección, con detección de duplicados |
| **StatsPage** | `/stats` | Estadísticas globales: total de registros, precio promedio, stock total y distribución por categoría, plataforma y fuente |
| **AboutPage** | `/about` | Información del proyecto, stack técnico, descripción de las pantallas y datos del autor |

---

## Instrucciones de ejecución

### Requisitos previos

- Flutter SDK 3.x ([flutter.dev](https://flutter.dev/docs/get-started/install))
- Android Studio (para el emulador y SDK de Android)
- VS Code con extensión Flutter
- Node.js 18+ (para el backend local)
- Cuenta de [Cloudinary](https://cloudinary.com/) (plan gratuito es suficiente)

### 1. Backend local

```bash
cd back_flutter_1-main
npm install
cp .env.example .env
```

Completar `.env` con tus credenciales de MongoDB Atlas y Cloudinary (ver tabla de [variables de entorno](#variables-de-entorno)).

```bash
npm run dev
# Servidor en http://localhost:3000
```

### 2. App Flutter

```bash
cd mediaexplorer_app
flutter pub get
```

Editar `lib/services/api_service.dart` y cambiar la URL base si se requiere:

```dart
// Desarrollo local (emulador Android):
static const String baseUrl = 'http://10.0.2.2:3000/api';

// Producción (Vercel):
static const String baseUrl = 'https://back-flutter-1.vercel.app/api';
```

Agregar los permisos necesarios en `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

> El permiso `READ_MEDIA_IMAGES` es necesario para que `image_picker` pueda acceder a la galería en Android 13+. En versiones anteriores, Flutter usa el selector nativo de fotos del sistema y no requiere permisos adicionales.

```bash
# Ejecutar en emulador o dispositivo conectado:
flutter run

# Generar APK:
flutter build apk --release
# APK generado en: build/app/outputs/flutter-apk/app-release.apk
```

### 3. Deploy backend en Vercel

```bash
npm install -g vercel
cd back_flutter_1-main
vercel
```

Las variables de entorno (ver tabla en la sección [Backend](#variables-de-entorno)) deben configurarse en el dashboard de Vercel, o mediante:

```bash
vercel env add MONGODB_URI
vercel env add DB_NAME
vercel env add COLLECTION_NAME
vercel env add CLOUDINARY_CLOUD_NAME
vercel env add CLOUDINARY_API_KEY
vercel env add CLOUDINARY_API_SECRET
```

```bash
vercel --prod
```

---

## Asistencia de IA en el desarrollo

Durante el desarrollo de este proyecto se utilizó asistencia de IA (Claude de Anthropic) en cuatro partes que representaban mayor complejidad técnica:

### 1. Arquitectura del backend como intermediario

Conectar Flutter directamente a MongoDB no es seguro ni práctico (se expondrían las credenciales en el código de la app). La IA ayudó a diseñar el patrón correcto: **Flutter → Backend Express → MongoDB Atlas**, incluyendo la configuración del archivo `vercel.json` para que el deploy funcione correctamente y la gestión del cliente de MongoDB con reconexión automática entre las llamadas sin estado de Vercel.

### 2. Subida de imágenes a Cloudinary con reemplazo automático

Para evitar exponer las credenciales de Cloudinary en la app y para que cada edición de imagen sustituya a la anterior (en lugar de acumular archivos), la IA ayudó a diseñar un endpoint `POST /api/upload` que usa el `id` del item como `public_id` fijo con `overwrite: true`, y a integrar `image_picker` en el formulario de Flutter para capturar la imagen, convertirla a base64 y subirla antes de guardar el item.

### 3. Provider + infinite scrolling sin duplicados

Coordinar el estado de carga entre el `ScrollController`, el `Provider` y las llamadas HTTP es una fuente común de bugs (llamadas dobles, items duplicados, spinners que no se detienen). La IA ayudó a estructurar los providers con las banderas `_loading` y `_hasMore` de forma que las llamadas se bloqueen correctamente cuando ya hay una en curso o cuando se agotaron los datos.

### 4. Transformación y deduplicación al guardar desde la API

Al guardar un deal de CheapShark en la colección local, fue necesario: transformar el JSON externo al modelo propio, consultar al backend si ese título ya existe (`check-duplicate`), y solo entonces insertar. La IA ayudó a encadenar estas tres operaciones de forma limpia y a manejar los tres estados posibles de respuesta (`success`, `duplicate`, `error`) para mostrar el mensaje correcto al usuario.

---

## Funcionalidades extras

### 🔎 Buscador por título
En la parte superior de **Mi Colección** y del **Explorador de API** hay una barra de búsqueda.
Al escribir parte del título de un item (por ejemplo "halo"), la lista se filtra en tiempo real mostrando solo los resultados que coinciden, sin necesidad de recargar toda la pantalla ni perder el scroll infinito: a medida que se sigue bajando, se siguen pidiendo más resultados que coincidan con el texto buscado.

### 🔄 Pull to refresh
Cuando estás viendo tu colección de items o explorando las ofertas de la API, puedes deslizar la lista hacia abajo para refrescarla.
Esto borra lo que estaba cargado y trae los datos desde el inicio, como si entraras de nuevo a la pantalla.

### 🎯 Filtro por categoría y plataforma
En la pantalla de **Mi Colección** hay un botón de filtro en la barra superior que abre un panel desde abajo con dos listas desplegables:
- **Categoría**
- **Plataforma**

Estas opciones no son fijas, sino que se generan automáticamente según las categorías y plataformas que existen en ese momento en tu colección guardada.
Si agregas un item con una categoría nueva, esta aparecerá como opción de filtro la próxima vez que abras el panel.

Al aplicar un filtro:
- La lista se actualiza mostrando solo los items que coinciden.
- En la parte superior aparecen **etiquetas (chips)** con los filtros activos.
- Cada chip puede eliminarse con un toque para quitar ese filtro.

### 📊 Estadísticas de la colección
Desde el **HomePage** se ven accesos rápidos a algunos totales, y entrando a **StatsPage** se despliega el detalle completo: cuántos items hay guardados en total, el precio promedio de la colección, el stock total acumulado, y cómo se distribuyen los items por categoría, plataforma y fuente (manual o CheapShark API).
Estos números se recalculan en el backend cada vez que se abre la pantalla, así que siempre reflejan el estado actual de la colección.

### 🚫 Evitar duplicados
Cuando guardas una oferta encontrada en el explorador de la API dentro de tu colección, la aplicación verifica primero si ya existe un item con el **mismo título** y la **misma fuente**.

- Si el item **ya existe**, no se vuelve a guardar.
- Se muestra un **aviso visual** (mensaje naranja en la parte inferior) indicando que el item ya está en tu colección.

Esto ayuda a mantener la colección limpia y sin registros repetidos.

### 🖼️ Reemplazo automático de imágenes
Al editar un item y subir una nueva imagen desde la galería, la imagen anterior almacenada en Cloudinary se reemplaza automáticamente (mismo `public_id`), evitando que se acumulen archivos sin usar.

---

## Evidencias y capturas

> 📌 **Sección para completar con tus evidencias**

### Capturas de pantalla

<table>
  <tr>
    <td align="center"><b>HomePage</b><br><img src="https://github.com/user-attachments/assets/50a3abfd-cd9c-4108-89a8-f6bce9fcb87d" width="220" alt="HomePage"></td>
    <td align="center"><b>CollectionPage</b><br><img src="https://github.com/user-attachments/assets/f06f8588-66dc-4450-8937-2208d975b900" width="220" alt="CollectionPage"></td>
    <td align="center"><b>FormPage — Crear</b><br><img src="https://github.com/user-attachments/assets/68bae4d5-0622-4c5a-be50-567badd396e2" width="220" alt="FormPage Crear"></td>
  </tr>
  <tr>
    <td align="center"><b>FormPage — Editar</b><br><img src="https://github.com/user-attachments/assets/27d9bf8c-167d-47dd-bef8-1394ace3a65c" width="220" alt="FormPage Editar"></td>
    <td align="center"><b>DetailPage</b><br><img src="https://github.com/user-attachments/assets/2a09f5ea-a605-4082-a141-dfdd56e47e68" width="220" alt="DetailPage"></td>
    <td align="center"><b>ApiExplorerPage</b><br><img src="https://github.com/user-attachments/assets/273689af-784e-4a8d-b12f-7ea968a203d5" width="220" alt="ApiExplorerPage"></td>
  </tr>
  <tr>
    <td align="center"><b>StatsPage</b><br><img src="https://github.com/user-attachments/assets/d7ed443d-0c4b-45cf-8e86-c7b8aa82fe76" width="220" alt="StatsPage"></td>
    <td align="center"><b>AboutPage</b><br><img src="https://github.com/user-attachments/assets/fec84214-20f7-43d8-a58e-b8c40d6a39ca" width="220" alt="AboutPage"></td>
    <td></td>
  </tr>
</table>

### Video de demostración

> _(insertar enlace a video: YouTube, Drive, etc.)_

### Icono y Splash Screen

<table>
  <tr>
    <td align="center"><b>Icono</b><br><img src="https://github.com/user-attachments/assets/609b13c7-12fa-4911-81aa-c9807ebfd0b9" width="120" alt="Icono"></td>
    <td align="center"><b>Splash Screen</b><br><img src="https://github.com/user-attachments/assets/62c790ef-f79f-42d7-9a68-0b9f8c8c274e" width="180" alt="Splash Screen"></td>
  </tr>
</table>

### Evidencias de servicios

<p>
  <b>MongoDB Atlas</b><br>
  <img src="https://github.com/user-attachments/assets/92261b4f-4897-435f-ae22-e824bd172e04" width="600" alt="Evidencia MongoDB Atlas">
</p>

<p>
  <b>Vercel</b><br>
  <img src="https://github.com/user-attachments/assets/d259e410-e3d9-4f5b-a349-955a65d2e3fb" width="600" alt="Evidencia Vercel">
</p>

https://back-flutter-1.vercel.app/

*Proyecto académico — ESFOT · Uso educativo, sin fines comerciales.*
