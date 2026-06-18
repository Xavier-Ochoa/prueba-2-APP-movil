import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/collection_provider.dart';
import '../../widgets/item_card.dart';
import '../../widgets/loading_widgets.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoria;
  String? _selectedPlataforma;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CollectionProvider>();
      if (provider.items.isEmpty) provider.loadMore();
      provider.loadFilterOptions();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<CollectionProvider>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(BuildContext context, String id, String titulo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar item'),
        content: Text('¿Estás seguro de que deseas eliminar "$titulo"?\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<CollectionProvider>().deleteItem(id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '✅ Item eliminado' : '❌ Error al eliminar'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    final collectionProvider = context.read<CollectionProvider>();
    final categoriasDisponibles = collectionProvider.categoriasDisponibles;
    final plataformasDisponibles = collectionProvider.plataformasDisponibles;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filtros', style: Theme.of(ctx).textTheme.titleLarge),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _selectedCategoria = null;
                        _selectedPlataforma = null;
                      });
                      context.read<CollectionProvider>().clearFilters();
                      Navigator.pop(ctx);
                    },
                    child: const Text('Limpiar'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Categoría', style: Theme.of(ctx).textTheme.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategoria,
                decoration: const InputDecoration(hintText: 'Todas las categorías'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todas')),
                  ...categoriasDisponibles.map((c) =>
                      DropdownMenuItem(value: c, child: Text(c))),
                ],
                onChanged: (v) => setModalState(() => _selectedCategoria = v),
              ),
              const SizedBox(height: 16),
              Text('Plataforma', style: Theme.of(ctx).textTheme.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPlataforma,
                decoration: const InputDecoration(hintText: 'Todas las plataformas'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todas')),
                  ...plataformasDisponibles.map((p) =>
                      DropdownMenuItem(value: p, child: Text(p))),
                ],
                onChanged: (v) => setModalState(() => _selectedPlataforma = v),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final provider = context.read<CollectionProvider>();
                    provider.setFilterCategoria(_selectedCategoria ?? '');
                    provider.setFilterPlataforma(_selectedPlataforma ?? '');
                    Navigator.pop(ctx);
                  },
                  child: const Text('Aplicar filtros'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Colección'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtros',
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/form');
          if (mounted) context.read<CollectionProvider>().refresh();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      body: Consumer<CollectionProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Buscador
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por título...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.setSearch('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) => provider.setSearch(value),
                ),
              ),

              // Chips de filtros activos
              if (provider.filterCategoria.isNotEmpty || provider.filterPlataforma.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      if (provider.filterCategoria.isNotEmpty)
                        Chip(
                          label: Text(provider.filterCategoria),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() => _selectedCategoria = null);
                            provider.setFilterCategoria('');
                          },
                        ),
                      if (provider.filterPlataforma.isNotEmpty)
                        Chip(
                          label: Text(provider.filterPlataforma),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() => _selectedPlataforma = null);
                            provider.setFilterPlataforma('');
                          },
                        ),
                    ],
                  ),
                ),

              // Total
              if (provider.total > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${provider.total} ${provider.total == 1 ? "resultado" : "resultados"}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),

              // Lista
              Expanded(
                child: RefreshIndicator(
                  onRefresh: provider.refresh,
                  child: _buildList(context, provider),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, CollectionProvider provider) {
    if (provider.error != null && provider.items.isEmpty) {
      return ErrorWidget2(message: provider.error!, onRetry: provider.refresh);
    }

    if (!provider.loading && provider.items.isEmpty) {
      return EmptyWidget(
        title: 'Sin items',
        subtitle: 'No hay items en tu colección.\nAgrega uno nuevo o explora la API.',
        icon: Icons.collections_outlined,
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: provider.items.length + (provider.loading ? 3 : 0),
      itemBuilder: (context, index) {
        if (index >= provider.items.length) return const LoadingCard();

        final item = provider.items[index];
        return ItemCard(
          item: item,
          onTap: () => Navigator.pushNamed(context, '/detail', arguments: item),
          onEdit: () async {
            await Navigator.pushNamed(context, '/form', arguments: item);
            if (mounted) context.read<CollectionProvider>().refresh();
          },
          onDelete: () => _showDeleteDialog(context, item.id, item.titulo),
        );
      },
    );
  }
}