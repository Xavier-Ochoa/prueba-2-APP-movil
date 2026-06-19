class ItemColeccion {
  final String id;
  final String titulo;
  final String categoria;
  final String plataforma;
  final double precio;
  final int stock;
  final String imagen;
  final String descripcion;
  final String fuente;
  final String? creadoEn;
  final String? actualizadoEn;

  ItemColeccion({
    required this.id,
    required this.titulo,
    required this.categoria,
    required this.plataforma,
    required this.precio,
    required this.stock,
    required this.imagen,
    required this.descripcion,
    required this.fuente,
    this.creadoEn,
    this.actualizadoEn,
  });

  factory ItemColeccion.fromJson(Map<String, dynamic> json) {
    return ItemColeccion(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      categoria: json['categoria']?.toString() ?? '',
      plataforma: json['plataforma']?.toString() ?? '',
      precio: _parseDouble(json['precio']),
      stock: _parseInt(json['stock']),
      imagen: json['imagen']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      fuente: json['fuente']?.toString() ?? 'manual',
      creadoEn: json['creadoEn']?.toString(),
      actualizadoEn: json['actualizadoEn']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'categoria': categoria,
      'plataforma': plataforma,
      'precio': precio,
      'stock': stock,
      'imagen': imagen,
      'descripcion': descripcion,
      'fuente': fuente,
    };
  }

  ItemColeccion copyWith({
    String? id,
    String? titulo,
    String? categoria,
    String? plataforma,
    double? precio,
    int? stock,
    String? imagen,
    String? descripcion,
    String? fuente,
  }) {
    return ItemColeccion(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      categoria: categoria ?? this.categoria,
      plataforma: plataforma ?? this.plataforma,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
      imagen: imagen ?? this.imagen,
      descripcion: descripcion ?? this.descripcion,
      fuente: fuente ?? this.fuente,
      creadoEn: creadoEn,
      actualizadoEn: actualizadoEn,
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
