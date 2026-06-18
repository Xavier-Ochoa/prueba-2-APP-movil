class CheapSharkDeal {
  final String externalId;
  final String titulo;
  final String categoria;
  final String plataforma;
  final double precio;
  final double precioNormal;
  final String descuento;
  final int stock;
  final String imagen;
  final String descripcion;
  final String fuente;
  final int metacriticScore;
  final String steamRatingText;
  final int steamRatingPercent;

  CheapSharkDeal({
    required this.externalId,
    required this.titulo,
    required this.categoria,
    required this.plataforma,
    required this.precio,
    required this.precioNormal,
    required this.descuento,
    required this.stock,
    required this.imagen,
    required this.descripcion,
    required this.fuente,
    required this.metacriticScore,
    required this.steamRatingText,
    required this.steamRatingPercent,
  });

  factory CheapSharkDeal.fromJson(Map<String, dynamic> json) {
    return CheapSharkDeal(
      externalId: json['externalId']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? 'Sin título',
      categoria: json['categoria']?.toString() ?? 'Videojuego',
      plataforma: json['plataforma']?.toString() ?? 'PC',
      precio: _parseDouble(json['precio']),
      precioNormal: _parseDouble(json['precioNormal']),
      descuento: json['descuento']?.toString() ?? '0',
      stock: _parseInt(json['stock']),
      imagen: json['imagen']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      fuente: json['fuente']?.toString() ?? 'CheapShark API',
      metacriticScore: _parseInt(json['metacriticScore']),
      steamRatingText: json['steamRatingText']?.toString() ?? '',
      steamRatingPercent: _parseInt(json['steamRatingPercent']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}
