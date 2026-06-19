const express = require('express');
const router = express.Router();
const { uploadImage } = require('../controllers/uploadController');

// Subir imagen a Cloudinary (reemplaza la anterior si se envía el mismo itemId)
router.post('/', uploadImage);

module.exports = router;
