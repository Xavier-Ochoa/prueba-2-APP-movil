const cloudinary = require('../config/cloudinary');

const FOLDER = 'mediaexplorer/items';

// POST /api/upload — sube una imagen (base64) a Cloudinary.
// Si se envía itemId, usa un public_id fijo basado en ese id para que, al subir
// una nueva imagen para el mismo item, esta reemplace (overwrite) a la anterior
// en Cloudinary en lugar de crear un archivo nuevo cada vez.
async function uploadImage(req, res, next) {
  try {
    const { image, itemId } = req.body;

    if (!image) {
      return res.status(400).json({
        success: false,
        error: 'El campo image es requerido (base64 o data URL)',
      });
    }

    const options = {
      folder: FOLDER,
      overwrite: true,
      invalidate: true,
      resource_type: 'image',
    };

    if (itemId) {
      options.public_id = String(itemId);
    }

    const result = await cloudinary.uploader.upload(image, options);

    res.json({
      success: true,
      data: {
        url: result.secure_url,
        publicId: result.public_id,
      },
      message: 'Imagen subida exitosamente',
    });
  } catch (error) {
    next(error);
  }
}

module.exports = { uploadImage };
