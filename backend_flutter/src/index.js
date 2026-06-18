require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { connectDB } = require('./config/database');
const itemsRoutes = require('./routes/items');
const cheapsharkRoutes = require('./routes/cheapshark');
const { errorHandler, notFound } = require('./middleware/errorHandler');

const app = express();
const PORT = process.env.PORT || 3000;

// ── Middlewares globales ──────────────────────────────────────────────────────
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// ── Conectar BD antes de manejar rutas ───────────────────────────────────────
app.use(async (req, res, next) => {
  try {
    await connectDB();
    next();
  } catch (error) {
    res.status(503).json({
      success: false,
      error: 'Base de datos no disponible. Intenta de nuevo.',
    });
  }
});

// ── Health check ─────────────────────────────────────────────────────────────
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: '🎮 MediaExplorer API funcionando correctamente',
    version: '1.0.0',
    endpoints: {
      items: '/api/items',
      stats: '/api/items/stats',
      checkDuplicate: '/api/items/check-duplicate',
      cheapshark: '/api/cheapshark/deals',
    },
  });
});

app.get('/api', (req, res) => {
  res.json({
    success: true,
    message: 'MediaExplorer Backend API v1.0',
    routes: [
      'GET    /api/items                   — Listar items (page, limit, search, categoria, plataforma)',
      'GET    /api/items/stats             — Estadísticas globales',
      'POST   /api/items/check-duplicate   — Verificar duplicado',
      'GET    /api/items/:id               — Detalle de item',
      'POST   /api/items                   — Crear item',
      'PUT    /api/items/:id               — Actualizar item',
      'DELETE /api/items/:id               — Eliminar item',
      'GET    /api/cheapshark/deals        — Deals de CheapShark (page, pageSize, title)',
      'GET    /api/cheapshark/deals/:id    — Detalle de deal',
    ],
  });
});

// ── Rutas principales ─────────────────────────────────────────────────────────
app.use('/api/items', itemsRoutes);
app.use('/api/cheapshark', cheapsharkRoutes);

// ── Manejo de errores ─────────────────────────────────────────────────────────
app.use(notFound);
app.use(errorHandler);

// ── Iniciar servidor (solo en local, Vercel lo maneja diferente) ──────────────
if (process.env.NODE_ENV !== 'production') {
  app.listen(PORT, () => {
    console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
    console.log(`📋 Endpoints disponibles en http://localhost:${PORT}/api`);
  });
}

module.exports = app;
