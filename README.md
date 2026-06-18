# 🎮 MediaExplorer App

**Aplicación móvil Flutter para explorar y gestionar una colección multimedia personal, con backend Node.js en Vercel y base de datos MongoDB Atlas.**

> Desarrollado por **Xavier Ochoa** · ESFOT – Escuela de Formación de Tecnólogos · Proyecto académico de Desarrollo de Software

---

## 📋 Tabla de contenidos

- [Descripción general](#descripción-general)
- [API consumida](#api-consumida-cheapshark)
- [Backend en Vercel](#backend-en-vercel)
- [CRUD en MongoDB Atlas](#crud-en-mongodb-atlas)
- [Infinite Scrolling](#infinite-scrolling)
- [Pantallas de la app](#pantallas-de-la-app)
- [Instrucciones de ejecución](#instrucciones-de-ejecución)
- [Asistencia de IA en el desarrollo](#asistencia-de-ia-en-el-desarrollo)
- [Evidencias y capturas](#evidencias-y-capturas)

---

## Descripción general

MediaExplorer es una app Flutter que permite al usuario:

- Guardar y organizar items multimedia (videojuegos, libros, series, etc.) en MongoDB Atlas
- Explorar ofertas de videojuegos en tiempo real desde la API pública de CheapShark
- Guardar items externos a la colección propia con un toque
- Navegar entre pantallas con un diseño Material Design 3

**Stack tecnológico:**

| Capa | Tecnología |
|------|-----------|
| Frontend | Flutter 3.x + Provider |
| Backend | Node.js + Express |
| Base de datos | MongoDB Atlas |
| Deploy backend | Vercel |
| API externa | CheapShark API |

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

## Backend en Vercel

El backend actúa como intermediario entre la app Flutter y MongoDB Atlas. Está construido con **Node.js + Express** y desplegado en **Vercel** (plan gratuito).

**URL de producción:** `https://TU-PROYECTO.vercel.app`

### Endpoints disponibles

| Método | Ruta | Descripción |
|--------|------|-------------|
| `GET` | `/api/items` | Listar items con paginación, búsqueda y filtros |
| `GET` | `/api/items/stats` | Estadísticas: total, promedio de precios, stock |
| `POST` | `/api/items/check-duplicate` | Verificar si un item ya existe |
| `GET` | `/api/items/:id` | Detalle de un item |
| `POST` | `/api/items` | Crear nuevo item |
| `PUT` | `/api/items/:id` | Actualizar item existente |
| `DELETE` | `/api/items/:id` | Eliminar item |
| `GET` | `/api/cheapshark/deals` | Proxy paginado a CheapShark |
| `GET` | `/api/cheapshark/deals/:id` | Detalle de un deal |

**Query params para listado:**

```
GET /api/items?page=0&limit=10&search=halo&categoria=Videojuego&plataforma=Steam
```

**Estructura del proyecto backend:**

```
mediaexplorer_backend/
├── src/
│   ├── config/database.js        ← conexión MongoDB Atlas
│   ├── controllers/
│   │   ├── itemsController.js    ← lógica CRUD
│   │   └── cheapsharkController.js ← proxy API externa
│   ├── routes/
│   │   ├── items.js
│   │   └── cheapshark.js
│   └── index.js                  ← Express app
└── vercel.json                   ← configuración deploy
```

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
  final String imagen;
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
| **FormPage** | `/form` | Formulario para crear o editar items. Se precarga automáticamente con los datos del item cuando es edición. Incluye validaciones en todos los campos |
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

### 1. Backend local

```bash
cd mediaexplorer_backend
npm install
cp .env.example .env
npm run dev
# Servidor en http://localhost:3000
```

### 2. App Flutter

```bash
cd mediaexplorer_app
flutter pub get
```

Editar `lib/services/api_service.dart` y cambiar la URL:

```dart
// Desarrollo local (emulador Android):
static const String baseUrl = 'http://10.0.2.2:3000/api';

// Producción (Vercel):
static const String baseUrl = 'https://TU-PROYECTO.vercel.app/api';
```

Agregar permiso en `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

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
cd mediaexplorer_backend
vercel
```

Variables de entorno requeridas en Vercel:

| Variable | Valor |
|----------|-------|
| `MONGODB_URI` | `mongodb+srv://admin:...` |
| `DB_NAME` | `flutter_1` |
| `COLLECTION_NAME` | `items_coleccion` |

---

## Asistencia de IA en el desarrollo

Durante el desarrollo de este proyecto se utilizó asistencia de IA (Claude de Anthropic) en tres partes que representaban mayor complejidad técnica:

### 1. Arquitectura del backend como intermediario

Conectar Flutter directamente a MongoDB no es seguro ni práctico (se expondrían las credenciales en el código de la app). La IA ayudó a diseñar el patrón correcto: **Flutter → Backend Express → MongoDB Atlas**, incluyendo la configuración del archivo `vercel.json` para que el deploy funcione correctamente y la gestión del cliente de MongoDB con reconexión automática entre las llamadas sin estado de Vercel.

### 2. Provider + infinite scrolling sin duplicados

Coordinar el estado de carga entre el `ScrollController`, el `Provider` y las llamadas HTTP es una fuente común de bugs (llamadas dobles, items duplicados, spinners que no se detienen). La IA ayudó a estructurar los providers con las banderas `_loading` y `_hasMore` de forma que las llamadas se bloqueen correctamente cuando ya hay una en curso o cuando se agotaron los datos.

### 3. Transformación y deduplicación al guardar desde la API

Al guardar un deal de CheapShark en la colección local, fue necesario: transformar el JSON externo al modelo propio, consultar al backend si ese título ya existe (`check-duplicate`), y solo entonces insertar. La IA ayudó a encadenar estas tres operaciones de forma limpia y a manejar los tres estados posibles de respuesta (`success`, `duplicate`, `error`) para mostrar el mensaje correcto al usuario.

---

## Funcionalidades extras

### 🔄 Pull to refresh
Cuando estás viendo tu colección de items o explorando las ofertas de la API, puedes deslizar la lista hacia abajo para refrescarla.  
Esto borra lo que estaba cargado y trae los datos desde el inicio, como si entraras de nuevo a la pantalla.

---

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

---

### 🚫 Evitar duplicados
Cuando guardas una oferta encontrada en el explorador de la API dentro de tu colección, la aplicación verifica primero si ya existe un item con el **mismo título** y la **misma fuente**.

- Si el item **ya existe**, no se vuelve a guardar.
- Se muestra un **aviso visual** (mensaje naranja en la parte inferior) indicando que el item ya está en tu colección.

Esto ayuda a mantener la colección limpia y sin registros repetidos.



## Evidencias y capturas

> 📌 **Sección para completar con tus evidencias**

### Capturas de pantalla

| Pantalla | Captura |
|----------|---------|
| HomePage | _(insertar imagen)_ |
| CollectionPage | _(insertar imagen)_ |
| FormPage — Crear | _(insertar imagen)_ |
| FormPage — Editar | _(insertar imagen)_ |
| DetailPage | _(insertar imagen)_ |
| ApiExplorerPage | _(insertar imagen)_ |
| StatsPage | _(insertar imagen)_ |

### Video de demostración

> _(insertar enlace a video: YouTube, Drive, etc.)_

### Icono

<img width="1024" height="1024" alt="image" src="https://github.com/user-attachments/assets/609b13c7-12fa-4911-81aa-c9807ebfd0b9" />


### Splash Screen

<img width="768" height="1376" alt="image" src="https://github.com/user-attachments/assets/62c790ef-f79f-42d7-9a68-0b9f8c8c274e" />


### Evidencia MongoDB Atlas

<img width="1326" height="755" alt="image" src="https://github.com/user-attachments/assets/92261b4f-4897-435f-ae22-e824bd172e04" />


### Evidencia Vercel

<img width="1349" height="617" alt="image" src="https://github.com/user-attachments/assets/d259e410-e3d9-4f5b-a349-955a65d2e3fb" />
https://back-flutter-1.vercel.app/

*Proyecto académico — ESFOT · Uso educativo, sin fines comerciales.*
