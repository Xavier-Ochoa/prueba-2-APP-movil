import 'package:flutter/material.dart';
import '../models/cheapshark_deal.dart';
import '../models/item_coleccion.dart';
import '../services/api_service.dart';
import 'package:uuid/uuid.dart';

class CheapSharkProvider extends ChangeNotifier {
  List<CheapSharkDeal> _deals = [];
  bool _loading = false;
  bool _hasMore = true;
  int _page = 0;
  final int _pageSize = 10;
  String _searchQuery = '';
  String? _error;
  Set<String> _savedTitles = {};

  List<CheapSharkDeal> get deals => _deals;
  bool get loading => _loading;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;
  String? get error => _error;
  Set<String> get savedTitles => _savedTitles;

  Future<void> loadMore() async {
    if (_loading || !_hasMore) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.getCheapSharkDeals(
        page: _page,
        pageSize: _pageSize,
        title: _searchQuery,
      );

      final newDeals = result['deals'] as List<CheapSharkDeal>;

      _page++;
      _deals.addAll(newDeals);
      _hasMore = result['hasMore'] as bool;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _deals = [];
    _page = 0;
    _hasMore = true;
    _error = null;
    await loadMore();
  }

  void setSearch(String query) {
    _searchQuery = query;
    refresh();
  }

  bool isSaved(String titulo) => _savedTitles.contains(titulo.toLowerCase());

  Future<String> guardarDesdeApi(CheapSharkDeal deal) async {
    try {
      // Verificar duplicado (solo por título, sin importar mayúsculas/minúsculas ni fuente)
      final isDuplicate = await ApiService.checkDuplicate(deal.titulo);
      if (isDuplicate) {
        return 'duplicate';
      }

      const uuid = Uuid();
      final item = ItemColeccion(
        id: uuid.v4(),
        titulo: deal.titulo,
        categoria: deal.categoria,
        plataforma: deal.plataforma,
        precio: deal.precio,
        stock: deal.stock,
        imagen: deal.imagen,
        descripcion: deal.descripcion,
        fuente: deal.fuente,
      );

      await ApiService.createItem(item);
      _savedTitles.add(deal.titulo.toLowerCase());
      notifyListeners();
      return 'success';
    } catch (e) {
      return 'error: ${e.toString().replaceFirst("Exception: ", "")}';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}