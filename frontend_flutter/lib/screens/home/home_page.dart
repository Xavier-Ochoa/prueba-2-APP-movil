import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/collection_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? _stats;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await ApiService.getStats();
      if (mounted) setState(() { _stats = stats; _loadingStats = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('MediaExplorer'),
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            actions: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return IconButton(
                    icon: Icon(
                      themeProvider.isDarkMode
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                    ),
                    tooltip: themeProvider.isDarkMode
                        ? 'Modo claro'
                        : 'Modo oscuro',
                    onPressed: () => themeProvider.toggleTheme(),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: 'Acerca de',
                onPressed: () => Navigator.pushNamed(context, '/about'),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats rápidas
                  if (!_loadingStats && _stats != null) _buildStatsRow(theme, colorScheme),
                  if (_loadingStats)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    )),
                  const SizedBox(height: 24),
                  Text('Menú principal',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildListDelegate([
                _buildMenuCard(
                  context,
                  icon: Icons.collections_outlined,
                  title: 'Mi Colección',
                  subtitle: 'Ver y gestionar\ntus items guardados',
                  color: colorScheme.primaryContainer,
                  onColor: colorScheme.onPrimaryContainer,
                  route: '/collection',
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.explore_outlined,
                  title: 'Explorar API',
                  subtitle: 'Descubrir juegos\ndesde CheapShark',
                  color: colorScheme.secondaryContainer,
                  onColor: colorScheme.onSecondaryContainer,
                  route: '/api-explorer',
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.add_circle_outline,
                  title: 'Nuevo Item',
                  subtitle: 'Agregar item\nmanualmene',
                  color: colorScheme.tertiaryContainer,
                  onColor: colorScheme.onTertiaryContainer,
                  route: '/form',
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.bar_chart_outlined,
                  title: 'Estadísticas',
                  subtitle: 'Ver resumen\nde tu colección',
                  color: colorScheme.errorContainer,
                  onColor: colorScheme.onErrorContainer,
                  route: '/stats',
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme, ColorScheme colorScheme) {
    final total = _stats?['totalRegistros'] ?? 0;
    final promedio = _stats?['precioPromedio'] ?? '0.00';
    final stock = _stats?['stockTotal'] ?? 0;

    return Row(
      children: [
        _buildStatCard(theme, colorScheme, '$total', 'Items', Icons.library_books_outlined,
            colorScheme.primary),
        const SizedBox(width: 8),
        _buildStatCard(theme, colorScheme, '\$$promedio', 'Promedio', Icons.attach_money,
            Colors.green),
        const SizedBox(width: 8),
        _buildStatCard(
            theme, colorScheme, '$stock', 'Stock', Icons.inventory_outlined, Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, ColorScheme colorScheme, String value, String label,
      IconData icon, Color color) {
    return Expanded(
      child: Card(
        color: colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(value,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold, color: color)),
              Text(label,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color onColor,
    required String route,
  }) {
    final theme = Theme.of(context);
    return Card(
      color: color,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: onColor, size: 32),
              const SizedBox(height: 10),
              Text(title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(color: onColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(color: onColor.withOpacity(0.8))),
            ],
          ),
        ),
      ),
    );
  }
}