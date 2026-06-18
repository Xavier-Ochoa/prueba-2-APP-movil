import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/item_coleccion.dart';
import '../../providers/collection_provider.dart';
import '../../utils/app_theme.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final item = ModalRoute.of(context)!.settings.arguments as ItemColeccion;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                item.titulo,
                style: const TextStyle(shadows: [Shadow(blurRadius: 8, color: Colors.black54)]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: item.imagen.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.imagen,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: colorScheme.primaryContainer),
                      errorWidget: (_, __, ___) => _buildImagePlaceholder(colorScheme),
                    )
                  : _buildImagePlaceholder(colorScheme),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Editar',
                onPressed: () async {
                  await Navigator.pushNamed(context, '/form', arguments: item);
                  if (context.mounted) {
                    context.read<CollectionProvider>().refresh();
                    Navigator.pop(context);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Eliminar',
                onPressed: () => _showDeleteDialog(context, item),
              ),
            ],
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTag(item.categoria, colorScheme.primaryContainer,
                          colorScheme.onPrimaryContainer),
                      _buildTag(item.plataforma, colorScheme.secondaryContainer,
                          colorScheme.onSecondaryContainer),
                      _buildTag(item.fuente, colorScheme.tertiaryContainer,
                          colorScheme.onTertiaryContainer),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Precio y Stock
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          theme, colorScheme,
                          icon: Icons.attach_money,
                          label: 'Precio',
                          value: '\$${item.precio.toStringAsFixed(2)}',
                          color: AppTheme.successColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          theme, colorScheme,
                          icon: Icons.inventory_2_outlined,
                          label: 'Stock',
                          value: '${item.stock} unidades',
                          color: item.stock > 0 ? Colors.blue : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Descripción
                  if (item.descripcion.isNotEmpty) ...[
                    Text('Descripción',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.descripcion,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Detalles adicionales
                  Text('Detalles',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildDetailRow(theme, 'ID', item.id, Icons.fingerprint_outlined),
                  _buildDetailRow(theme, 'Categoría', item.categoria, Icons.category_outlined),
                  _buildDetailRow(theme, 'Plataforma', item.plataforma, Icons.devices_outlined),
                  _buildDetailRow(theme, 'Fuente', item.fuente, Icons.source_outlined),
                  if (item.creadoEn != null)
                    _buildDetailRow(
                        theme, 'Creado', _formatDate(item.creadoEn!), Icons.calendar_today_outlined),
                  if (item.actualizadoEn != null)
                    _buildDetailRow(
                        theme, 'Actualizado', _formatDate(item.actualizadoEn!),
                        Icons.update_outlined),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.primaryContainer,
      child: Icon(Icons.image_not_supported_outlined,
          size: 80, color: colorScheme.onPrimaryContainer.withOpacity(0.5)),
    );
  }

  Widget _buildTag(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }

  Widget _buildInfoCard(ThemeData theme, ColorScheme colorScheme,
      {required IconData icon,
      required String label,
      required String value,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(label,
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 2),
          Text(value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value, IconData icon) {
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Text('$label: ',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

  void _showDeleteDialog(BuildContext context, ItemColeccion item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar item'),
        content: Text('¿Eliminar "${item.titulo}"?\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final success =
                  await context.read<CollectionProvider>().deleteItem(item.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '✅ Item eliminado' : '❌ Error al eliminar'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                if (success) Navigator.pop(context);
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
