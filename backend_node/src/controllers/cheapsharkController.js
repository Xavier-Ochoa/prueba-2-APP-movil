const fetch = require('node-fetch');

const CHEAPSHARK_BASE = 'https://www.cheapshark.com/api/1.0';

// GET /api/cheapshark/deals — proxy con paginación
async function getDeals(req, res, next) {
  try {
    const page = parseInt(req.query.page) || 0;
    const pageSize = parseInt(req.query.pageSize) || 10;
    const title = req.query.title || '';
    const sortBy = req.query.sortBy || 'Deal Rating';

    let url = `${CHEAPSHARK_BASE}/deals?pageNumber=${page}&pageSize=${pageSize}&sortBy=${encodeURIComponent(sortBy)}&onSale=1`;

    if (title) {
      url += `&title=${encodeURIComponent(title)}`;
    }

    const response = await fetch(url, {
      headers: { 'User-Agent': 'MediaExplorer-App/1.0' },
    });

    if (!response.ok) {
      throw new Error(`CheapShark API error: ${response.status}`);
    }

    const deals = await response.json();

    // Obtener encabezados de paginación de CheapShark
    const totalCount = response.headers.get('X-Total-Page-Count') || '0';

    // Transformar al formato del modelo ItemColeccion
    const transformed = deals.map((deal) => ({
      externalId: deal.dealID,
      titulo: deal.title || 'Sin título',
      categoria: 'Videojuego',
      plataforma: getStoreName(deal.storeID),
      precio: parseFloat(deal.salePrice) || 0,
      precioNormal: parseFloat(deal.normalPrice) || 0,
      descuento: deal.savings ? parseFloat(deal.savings).toFixed(0) : '0',
      stock: 1,
      imagen: deal.thumb || '',
      descripcion: `Precio normal: $${deal.normalPrice} | Metacritic: ${deal.metacriticScore || 'N/A'} | Ahorro: ${parseFloat(deal.savings || 0).toFixed(0)}%`,
      fuente: 'CheapShark API',
      metacriticScore: deal.metacriticScore || 0,
      steamRatingText: deal.steamRatingText || '',
      steamRatingPercent: deal.steamRatingPercent || 0,
    }));

    res.json({
      success: true,
      data: transformed,
      pagination: {
        page,
        pageSize,
        totalPages: parseInt(totalCount),
        hasMore: deals.length === pageSize,
      },
    });
  } catch (error) {
    next(error);
  }
}

// GET /api/cheapshark/deals/:dealId — detalle de un deal
async function getDealById(req, res, next) {
  try {
    const { dealId } = req.params;

    const url = `${CHEAPSHARK_BASE}/deals?id=${dealId}`;
    const response = await fetch(url);

    if (!response.ok) {
      throw new Error(`CheapShark API error: ${response.status}`);
    }

    const deal = await response.json();

    res.json({ success: true, data: deal });
  } catch (error) {
    next(error);
  }
}

// Helper: mapear storeID a nombre de tienda
function getStoreName(storeID) {
  const stores = {
    '1': 'Steam',
    '2': 'GamersGate',
    '3': 'GreenManGaming',
    '7': 'GOG',
    '8': 'Origin',
    '11': 'Humble Store',
    '13': 'Uplay',
    '15': 'Fanatical',
    '21': 'WinGameStore',
    '23': 'GameBillet',
    '24': 'Voidu',
    '25': 'Epic Games',
    '27': 'Games Planet',
    '28': 'Game Deals',
    '29': 'IndieGala Store',
    '31': 'Noctre',
    '33': 'DLGamer',
    '34': 'Dreamgame',
    '35': 'Chrono.gg',
  };
  return stores[String(storeID)] || `Tienda ${storeID}`;
}

module.exports = { getDeals, getDealById };
