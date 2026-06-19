class AppConstants {
  static const List<String> categorias = [
    'Videojuego',
    'Libro',
    'Película',
    'Serie',
    'Música',
    'Podcast',
    'Anime',
    'Otro',
  ];

  static const List<String> plataformas = [
    'PC',
    'Steam',
    'Epic Games',
    'GOG',
    'PlayStation',
    'Xbox',
    'Nintendo Switch',
    'iOS',
    'Android',
    'Web',
    'Otro',
  ];

  static const List<String> fuentes = [
    'manual',
    'CheapShark API',
  ];
}

class AppHelpers {
  static String formatPrecio(double precio) {
    return '\$${precio.toStringAsFixed(2)}';
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
