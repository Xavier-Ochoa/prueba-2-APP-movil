import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item_coleccion.dart';
import '../models/cheapshark_deal.dart';

class ApiService {
  
  static const String baseUrl = 'https://back-flutter-1.vercel.app/api';

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // ── ITEMS CRUD ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getItems({
    int page = 0,
    int limit = 10,
    String search = '',
    String categoria = '',
    String plataforma = '',
  }) async {
    try {
      final params = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search.isNotEmpty) 'search': search,
        if (categoria.isNotEmpty) 'categoria': categoria,
        if (plataforma.isNotEmpty) 'plataforma': plataforma,
      };

      final uri = Uri.parse('$baseUrl/items').replace(queryParameters: params);
      final response = await http.get(uri, headers: _headers).timeout(
        const Duration(seconds: 15),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final items = (data['data'] as List)
            .map((e) => ItemColeccion.fromJson(e))
            .toList();
        return {
          'items': items,
          'hasMore': data['pagination']['hasMore'] ?? false,
          'total': data['pagination']['total'] ?? 0,
        };
      }

      throw Exception(data['error'] ?? 'Error al obtener items');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<ItemColeccion> getItemById(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/items/$id'), headers: _headers)
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ItemColeccion.fromJson(data['data']);
      }

      throw Exception(data['error'] ?? 'Item no encontrado');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<ItemColeccion> createItem(ItemColeccion item) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/items'),
            headers: _headers,
            body: jsonEncode(item.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return ItemColeccion.fromJson(data['data']);
      }

      throw Exception(data['error'] ?? 'Error al crear item');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<ItemColeccion> updateItem(String id, ItemColeccion item) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/items/$id'),
            headers: _headers,
            body: jsonEncode(item.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ItemColeccion.fromJson(data['data']);
      }

      throw Exception(data['error'] ?? 'Error al actualizar item');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<void> deleteItem(String id) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/items/$id'), headers: _headers)
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['error'] ?? 'Error al eliminar item');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<bool> checkDuplicate(String titulo) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/items/check-duplicate'),
            headers: _headers,
            body: jsonEncode({'titulo': titulo}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return data['isDuplicate'] ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/items/stats'), headers: _headers)
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      }

      throw Exception(data['error'] ?? 'Error al obtener estadísticas');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, List<String>>> getFilterOptions() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/items/filters'), headers: _headers)
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'categorias': List<String>.from(data['data']['categorias'] ?? []),
          'plataformas': List<String>.from(data['data']['plataformas'] ?? []),
        };
      }

      throw Exception(data['error'] ?? 'Error al obtener filtros');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ── CHEAPSHARK ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getCheapSharkDeals({
    int page = 0,
    int pageSize = 10,
    String title = '',
  }) async {
    try {
      final params = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        if (title.isNotEmpty) 'title': title,
      };

      final uri =
          Uri.parse('$baseUrl/cheapshark/deals').replace(queryParameters: params);
      final response = await http.get(uri, headers: _headers).timeout(
        const Duration(seconds: 20),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final deals = (data['data'] as List)
            .map((e) => CheapSharkDeal.fromJson(e))
            .toList();
        return {
          'deals': deals,
          'hasMore': data['pagination']['hasMore'] ?? false,
        };
      }

      throw Exception(data['error'] ?? 'Error al obtener deals');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}