const { getCollection } = require('../config/database');

// GET /api/items — listar con paginación, búsqueda y filtros
async function getItems(req, res, next) {
  try {
    const collection = getCollection();

    const page = parseInt(req.query.page) || 0;
    const limit = parseInt(req.query.limit) || 10;
    const search = req.query.search || '';
    const categoria = req.query.categoria || '';
    const plataforma = req.query.plataforma || '';

    const filter = {};

    if (search) {
      filter.titulo = { $regex: search, $options: 'i' };
    }
    if (categoria) {
      filter.categoria = { $regex: categoria, $options: 'i' };
    }
    if (plataforma) {
      filter.plataforma = { $regex: plataforma, $options: 'i' };
    }

    const skip = page * limit;

    const [items, total] = await Promise.all([
      collection.find(filter).skip(skip).limit(limit).sort({ _id: -1 }).toArray(),
      collection.countDocuments(filter),
    ]);

    const hasMore = skip + items.length < total;

    res.json({
      success: true,
      data: items,
      pagination: {
        page,
        limit,
        total,
        hasMore,
      },
    });
  } catch (error) {
    next(error);
  }
}

// GET /api/items/:id — detalle de un item
async function getItemById(req, res, next) {
  try {
    const collection = getCollection();
    const { id } = req.params;

    const item = await collection.findOne({ id });

    if (!item) {
      return res.status(404).json({ success: false, error: 'Item no encontrado' });
    }

    res.json({ success: true, data: item });
  } catch (error) {
    next(error);
  }
}

// POST /api/items — crear nuevo item
async function createItem(req, res, next) {
  try {
    const collection = getCollection();
    const body = req.body;

    // Validaciones básicas
    if (!body.titulo || !body.categoria || !body.plataforma) {
      return res.status(400).json({
        success: false,
        error: 'Campos requeridos: titulo, categoria, plataforma',
      });
    }

    const item = {
      id: body.id || require('crypto').randomUUID(),
      titulo: body.titulo,
      categoria: body.categoria,
      plataforma: body.plataforma,
      precio: parseFloat(body.precio) || 0,
      stock: parseInt(body.stock) || 0,
      imagen: body.imagen || '',
      descripcion: body.descripcion || '',
      fuente: body.fuente || 'manual',
      creadoEn: new Date().toISOString(),
      actualizadoEn: new Date().toISOString(),
    };

    await collection.insertOne(item);

    res.status(201).json({ success: true, data: item, message: 'Item creado exitosamente' });
  } catch (error) {
    next(error);
  }
}

// PUT /api/items/:id — actualizar item
async function updateItem(req, res, next) {
  try {
    const collection = getCollection();
    const { id } = req.params;
    const body = req.body;

    const existing = await collection.findOne({ id });
    if (!existing) {
      return res.status(404).json({ success: false, error: 'Item no encontrado' });
    }

    const updated = {
      ...existing,
      titulo: body.titulo ?? existing.titulo,
      categoria: body.categoria ?? existing.categoria,
      plataforma: body.plataforma ?? existing.plataforma,
      precio: body.precio !== undefined ? parseFloat(body.precio) : existing.precio,
      stock: body.stock !== undefined ? parseInt(body.stock) : existing.stock,
      imagen: body.imagen ?? existing.imagen,
      descripcion: body.descripcion ?? existing.descripcion,
      fuente: body.fuente ?? existing.fuente,
      actualizadoEn: new Date().toISOString(),
    };

    // Eliminar _id para evitar conflicto de MongoDB
    const { _id, ...updatedWithoutId } = updated;

    await collection.updateOne({ id }, { $set: updatedWithoutId });

    res.json({ success: true, data: updatedWithoutId, message: 'Item actualizado exitosamente' });
  } catch (error) {
    next(error);
  }
}

// DELETE /api/items/:id — eliminar item
async function deleteItem(req, res, next) {
  try {
    const collection = getCollection();
    const { id } = req.params;

    const result = await collection.deleteOne({ id });

    if (result.deletedCount === 0) {
      return res.status(404).json({ success: false, error: 'Item no encontrado' });
    }

    res.json({ success: true, message: 'Item eliminado exitosamente' });
  } catch (error) {
    next(error);
  }
}

// POST /api/items/check-duplicate — verificar duplicado por título (sin importar mayúsculas/minúsculas ni fuente)
async function checkDuplicate(req, res, next) {
  try {
    const collection = getCollection();
    const { titulo } = req.body;

    if (!titulo) {
      return res.status(400).json({ success: false, error: 'titulo es requerido' });
    }

    const existing = await collection.findOne({
      titulo: { $regex: `^${titulo}$`, $options: 'i' },
    });

    res.json({ success: true, isDuplicate: !!existing, data: existing || null });
  } catch (error) {
    next(error);
  }
}

// GET /api/items/filters — valores distintos de categoria y plataforma actualmente en uso
async function getFilterOptions(req, res, next) {
  try {
    const collection = getCollection();

    const [categorias, plataformas] = await Promise.all([
      collection.distinct('categoria'),
      collection.distinct('plataforma'),
    ]);

    res.json({
      success: true,
      data: {
        categorias: categorias.filter(Boolean).sort(),
        plataformas: plataformas.filter(Boolean).sort(),
      },
    });
  } catch (error) {
    next(error);
  }
}

// GET /api/items/stats — estadísticas generales
async function getStats(req, res, next) {
  try {
    const collection = getCollection();

    const [totalResult, priceResult, stockResult, categorias, plataformas, porFuente] =
      await Promise.all([
        collection.countDocuments(),
        collection
          .aggregate([{ $group: { _id: null, promedio: { $avg: '$precio' }, total: { $sum: '$precio' } } }])
          .toArray(),
        collection.aggregate([{ $group: { _id: null, totalStock: { $sum: '$stock' } } }]).toArray(),
        collection
          .aggregate([{ $group: { _id: '$categoria', count: { $sum: 1 } } }, { $sort: { count: -1 } }])
          .toArray(),
        collection
          .aggregate([{ $group: { _id: '$plataforma', count: { $sum: 1 } } }, { $sort: { count: -1 } }])
          .toArray(),
        collection
          .aggregate([{ $group: { _id: '$fuente', count: { $sum: 1 } } }])
          .toArray(),
      ]);

    res.json({
      success: true,
      data: {
        totalRegistros: totalResult,
        precioPromedio: priceResult[0]?.promedio?.toFixed(2) || '0.00',
        precioTotal: priceResult[0]?.total?.toFixed(2) || '0.00',
        stockTotal: stockResult[0]?.totalStock || 0,
        porCategoria: categorias,
        porPlataforma: plataformas,
        porFuente: porFuente,
      },
    });
  } catch (error) {
    next(error);
  }
}

module.exports = { getItems, getItemById, createItem, updateItem, deleteItem, checkDuplicate, getStats, getFilterOptions };
