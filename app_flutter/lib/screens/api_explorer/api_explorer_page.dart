import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cheapshark_provider.dart';
import '../../widgets/deal_card.dart';
import '../../widgets/loading_widgets.dart';

class ApiExplorerPage extends StatefulWidget {
  const ApiExplorerPage({super.key});

  @override
  State<ApiExplorerPage> createState() => _ApiExplorerPageState();
}

class _ApiExplorerPageState extends State<ApiExplorerPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CheapSharkProvider>();
      if (provider.deals.isEmpty) provider.loadMore();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<CheapSharkProvider>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSave(BuildContext context, dynamic deal) async {
    final provider = context.read<CheapSharkProvider>();
    final result = await provider.guardarDesdeApi(deal);

    if (!mounted) return;

    String message;
    Color color;

    switch (result) {
      case 'success':
        message = '✅ "${deal.titulo}" guardado en tu colección';
        color = Colors.green;
        break;
      case 'duplicate':
        message = '⚠️ "${deal.titulo}" ya existe en tu colección';
        color = Colors.orange;
        break;
      default:
        message = '❌ Error al guardar: ${result.replaceFirst("error: ", "")}';
        color = Colors.red;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar CheapShark'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar juego...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<CheapSharkProvider>().setSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onSubmitted: (v) => context.read<CheapSharkProvider>().setSearch(v),
              onChanged: (v) => setState(() {}),
            ),
          ),
        ),
      ),
      body: Consumer<CheapSharkProvider>(
        builder: (context, provider, _) {
          if (provider.error != null && provider.deals.isEmpty) {
            return ErrorWidget2(
              message: provider.error!,
              onRetry: provider.refresh,
            );
          }

          if (!provider.loading && provider.deals.isEmpty) {
            return EmptyWidget(
              title: 'Sin resultados',
              subtitle: 'No se encontraron juegos.\nIntenta con otro término de búsqueda.',
              icon: Icons.videogame_asset_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: provider.deals.length + (provider.loading ? 3 : 0),
              itemBuilder: (context, index) {
                if (index >= provider.deals.length) return const LoadingCard();

                final deal = provider.deals[index];
                return DealCard(
                  deal: deal,
                  isSaved: provider.isSaved(deal.titulo),
                  onSave: () => _handleSave(context, deal),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
