const express = require('express');
const router = express.Router();
const { getDeals, getDealById } = require('../controllers/cheapsharkController');

router.get('/deals', getDeals);
router.get('/deals/:dealId', getDealById);

module.exports = router;
