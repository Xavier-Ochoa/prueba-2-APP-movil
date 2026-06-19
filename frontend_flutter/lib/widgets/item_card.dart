import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/item_coleccion.dart';
import '../utils/app_theme.dart';

class ItemCard extends StatelessWidget {
  final ItemColeccion item;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: item.imagen.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.imagen,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          errorWidget: (context, url, error) => _buildPlaceholder(colorScheme),
                        )
                      : _buildPlaceholder(colorScheme),
                ),
              ),
              const SizedBox(width: 12),
              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.titulo,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildChip(context, item.categoria, colorScheme.primaryContainer,
                            colorScheme.onPrimaryContainer),
                        const SizedBox(width: 4),
                        _buildChip(context, item.plataforma, colorScheme.secondaryContainer,
                            colorScheme.onSecondaryContainer),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${item.precio.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 14, color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: 2),
                            Text(
                              'Stock: ${item.stock}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (item.fuente.isNotEmpty)
                      Text(
                        item.fuente,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              // Acciones
              if (onEdit != null || onDelete != null)
                Column(
                  children: [
                    if (onEdit != null)
                      IconButton(
                        icon: Icon(Icons.edit_outlined,
                            color: colorScheme.primary, size: 20),
                        onPressed: onEdit,
                        tooltip: 'Editar',
                        visualDensity: VisualDensity.compact,
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppTheme.errorColor, size: 20),
                        onPressed: onDelete,
                        tooltip: 'Eliminar',
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.image_not_supported_outlined,
          color: colorScheme.onSurfaceVariant, size: 30),
    );
  }

  Widget _buildChip(
      BuildContext context, String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}
