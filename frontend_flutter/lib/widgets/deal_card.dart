import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cheapshark_deal.dart';

class DealCard extends StatelessWidget {
  final CheapSharkDeal deal;
  final bool isSaved;
  final VoidCallback onSave;

  const DealCard({
    super.key,
    required this.deal,
    required this.isSaved,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                child: deal.imagen.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: deal.imagen,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, url, error) => _placeholder(colorScheme),
                      )
                    : _placeholder(colorScheme),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.titulo,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${deal.precio.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${deal.precioNormal.toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${deal.descuento}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.store_outlined, size: 13, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text(deal.plataforma,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant)),
                      if (deal.metacriticScore > 0) ...[
                        const SizedBox(width: 10),
                        Icon(Icons.star_outlined, size: 13, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text('${deal.metacriticScore}',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Botón guardar
            FilledButton.tonal(
              onPressed: isSaved ? null : onSave,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
              ),
              child: Icon(
                isSaved ? Icons.check : Icons.save_outlined,
                size: 18,
                color: isSaved ? Colors.green : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.videogame_asset_outlined,
          color: colorScheme.onSurfaceVariant, size: 30),
    );
  }
}
