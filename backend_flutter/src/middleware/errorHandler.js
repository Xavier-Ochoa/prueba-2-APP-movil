function errorHandler(err, req, res, next) {
  console.error('Error:', err.message);

  const status = err.status || 500;
  const message = err.message || 'Error interno del servidor';

  res.status(status).json({
    success: false,
    error: message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
}

function notFound(req, res, next) {
  const error = new Error(`Ruta no encontrada: ${req.method} ${req.originalUrl}`);
  error.status = 404;
  next(error);
}

module.exports = { errorHandler, notFound };
