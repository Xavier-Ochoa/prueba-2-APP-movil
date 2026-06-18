import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() { _loading = true; _error = null; });
    try {
      final stats = await ApiService.getStats();
      if (mounted) setState(() { _stats = stats; _loading = false; });
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStats),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: _loadStats, child: const Text('Reintentar')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStats,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Tarjetas principales
                      _buildMainStats(theme, colorScheme),
                      const SizedBox(height: 24),

                      // Por categoría
                      if (_stats?['porCategoria'] != null && (_stats!['porCategoria'] as List).isNotEmpty) ...[
                        _buildSectionTitle(theme, 'Por categoría', Icons.category_outlined),
                        const SizedBox(height: 12),
                        _buildBarList(theme, colorScheme, _stats!['porCategoria'],
                            colorScheme.primary),
                        const SizedBox(height: 24),
                      ],

                      // Por plataforma
                      if (_stats?['porPlataforma'] != null && (_stats!['porPlataforma'] as List).isNotEmpty) ...[
                        _buildSectionTitle(theme, 'Por plataforma', Icons.devices_outlined),
                        const SizedBox(height: 12),
                        _buildBarList(theme, colorScheme, _stats!['porPlataforma'],
                            colorScheme.secondary),
                        const SizedBox(height: 24),
                      ],

                      // Por fuente
                      if (_stats?['porFuente'] != null && (_stats!['porFuente'] as List).isNotEmpty) ...[
                        _buildSectionTitle(theme, 'Por fuente', Icons.source_outlined),
                        const SizedBox(height: 12),
                        _buildBarList(theme, colorScheme, _stats!['porFuente'],
                            colorScheme.tertiary),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMainStats(ThemeData theme, ColorScheme colorScheme) {
    final total = _stats?['totalRegistros'] ?? 0;
    final promedio = _stats?['precioPromedio'] ?? '0.00';
    final precioTotal = _stats?['precioTotal'] ?? '0.00';
    final stockTotal = _stats?['stockTotal'] ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard(theme, colorScheme, '$total', 'Total items',
                Icons.library_books_outlined, colorScheme.primaryContainer, colorScheme.onPrimaryContainer)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(theme, colorScheme, '$stockTotal', 'Stock total',
                Icons.inventory_outlined, colorScheme.secondaryContainer, colorScheme.onSecondaryContainer)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard(theme, colorScheme, '\$$promedio', 'Precio promedio',
                Icons.trending_up_outlined, colorScheme.tertiaryContainer, colorScheme.onTertiaryContainer)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(theme, colorScheme, '\$$precioTotal', 'Valor total',
                Icons.account_balance_wallet_outlined, colorScheme.errorContainer, colorScheme.onErrorContainer)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, ColorScheme colorScheme, String value, String label,
      IconData icon, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg, size: 28),
          const SizedBox(height: 10),
          Text(value, style: theme.textTheme.headlineSmall?.copyWith(
              color: fg, fontWeight: FontWeight.bold)),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: fg.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBarList(ThemeData theme, ColorScheme colorScheme, List items, Color color) {
    final maxCount = items.fold<int>(0, (max, item) {
      final count = item['count'] as int? ?? 0;
      return count > max ? count : max;
    });

    return Column(
      children: items.map<Widget>((item) {
        final label = item['_id']?.toString() ?? 'Sin nombre';
        final count = item['count'] as int? ?? 0;
        final ratio = maxCount > 0 ? count / maxCount : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: theme.textTheme.bodyMedium),
                  Text('$count', style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold, color: color)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: color,
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
