import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.explore, size: 56, color: colorScheme.primary),
                ),
                const SizedBox(height: 16),
                Text('MediaExplorer App',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text('v1.0.0',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Descripción técnica
          _buildSection(theme, '📋 Descripción del proyecto', '''
MediaExplorer es una aplicación de gestión de colecciones multimedia que permite:
• Guardar y organizar videojuegos, libros, series y más
• Explorar ofertas en tiempo real desde CheapShark API
• Gestión completa CRUD contra MongoDB Atlas
• Infinite scrolling para carga progresiva de datos
• Búsqueda y filtros avanzados'''),
          const SizedBox(height: 20),

          // Stack técnico
          _buildSection(theme, '⚙️ Stack técnico', '''
Frontend:
  • Flutter 3.x (Material Design 3)
  • Provider (gestión de estado)
  • http, cached_network_image, uuid, shimmer

Backend:
  • Node.js + Express.js
  • MongoDB Atlas (base de datos en la nube)
  • Desplegado en Vercel

API Externa:
  • CheapShark API (cheapshark.com)
  • Paginación con pageNumber y pageSize
  • Sin API key requerida'''),
          const SizedBox(height: 20),

          // Pantallas
          _buildSection(theme, '📱 Pantallas implementadas', '''
1. HomePage — Menú principal y estadísticas rápidas
2. CollectionPage — Lista con búsqueda, filtros y scroll infinito
3. FormPage — Crear y editar items con validaciones
4. DetailPage — Detalle completo del item
5. ApiExplorerPage — CheapShark con infinite scroll
6. StatsPage — Estadísticas globales de la colección
7. AboutPage — Esta pantalla'''),
          const SizedBox(height: 20),

          // API
          _buildSection(theme, '🌐 API Externa: CheapShark', '''
Endpoint base: https://www.cheapshark.com/api/1.0
Ruta usada: /deals?pageNumber={n}&pageSize={n}

Campos mapeados al modelo:
  • title      → titulo
  • salePrice  → precio
  • thumb      → imagen
  • storeID    → plataforma (nombre de tienda)
  • normalPrice + metacriticScore → descripcion
  • fuente fija: "CheapShark API"'''),
          const SizedBox(height: 20),

          // Autor y contexto académico
          _buildSection(theme, 'Autor', '''
Aplicación desarrollada por:

Xavier Ochoa

Proyecto realizado con fines educativos como parte del proceso de formación en desarrollo de software.

Estudiante de Desarrollo de Software  
ESFOT – Escuela de Formación de Tecnólogos  

Este proyecto integra conocimientos prácticos de:
• Desarrollo de aplicaciones móviles con Flutter
• Consumo de APIs REST
• Backend con Node.js y MongoDB
• Arquitectura cliente-servidor
• Buenas prácticas de diseño y organización de código

Uso académico, sin fines comerciales.
'''),
          const SizedBox(height: 32),

          // Footer
          Center(
            child: Text(
              'Desarrollado con Flutter y Node.js',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary)),
          const SizedBox(height: 10),
          Text(content, style: theme.textTheme.bodySmall?.copyWith(height: 1.6)),
        ],
      ),
    );
  }
}