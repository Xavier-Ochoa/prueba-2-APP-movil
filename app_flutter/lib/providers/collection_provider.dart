import 'package:flutter/material.dart';
import '../models/item_coleccion.dart';
import '../services/api_service.dart';

class CollectionProvider extends ChangeNotifier {
  List<ItemColeccion> _items = [];
  bool _loading = false;
  bool _hasMore = true;
  int _page = 0;
  final int _limit = 10;
  String _searchQuery = '';
  String _filterCategoria = '';
  String _filterPlataforma = '';
  String? _error;
  int _total = 0;
  List<String> _categoriasDisponibles = [];
  List<String> _plataformasDisponibles = [];

  // Getters
  List<ItemColeccion> get items => _items;
  bool get loading => _loading;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;
  String get filterCategoria => _filterCategoria;
  String get filterPlataforma => _filterPlataforma;
  String? get error => _error;
  int get total => _total;
  List<String> get categoriasDisponibles => _categoriasDisponibles;
  List<String> get plataformasDisponibles => _plataformasDisponibles;

  Future<void> loadFilterOptions() async {
    try {
      final result = await ApiService.getFilterOptions();
      _categoriasDisponibles = result['categorias'] ?? [];
      _plataformasDisponibles = result['plataformas'] ?? [];
      notifyListeners();
    } catch (_) {
      // Si falla, los dropdowns simplemente quedan vacíos; no se interrumpe el resto de la app.
    }
  }

  Future<void> loadMore() async {
    if (_loading || !_hasMore) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.getItems(
        page: _page,
        limit: _limit,
        search: _searchQuery,
        categoria: _filterCategoria,
        plataforma: _filterPlataforma,
      );

      final newItems = result['items'] as List<ItemColeccion>;

      _page++;
      _items.addAll(newItems);
      _hasMore = result['hasMore'] as bool;
      _total = result['total'] as int;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _items = [];
    _page = 0;
    _hasMore = true;
    _error = null;
    await loadMore();
  }

  void setSearch(String query) {
    _searchQuery = query;
    refresh();
  }

  void setFilterCategoria(String categoria) {
    _filterCategoria = categoria;
    refresh();
  }

  void setFilterPlataforma(String plataforma) {
    _filterPlataforma = plataforma;
    refresh();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterCategoria = '';
    _filterPlataforma = '';
    refresh();
  }

  Future<bool> createItem(ItemColeccion item) async {
    try {
      final isDuplicate = await ApiService.checkDuplicate(item.titulo);
      if (isDuplicate) {
        _error = 'Ya existe un item con el título "${item.titulo}"';
        notifyListeners();
        return false;
      }
      await ApiService.createItem(item);
      await refresh();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateItem(String id, ItemColeccion item) async {
    try {
      await ApiService.updateItem(id, item);
      await refresh();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteItem(String id) async {
    try {
      await ApiService.deleteItem(id);
      _items.removeWhere((item) => item.id == id);
      _total = (_total - 1).clamp(0, _total);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}