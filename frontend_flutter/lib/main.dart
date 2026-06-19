import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/collection_provider.dart';
import 'providers/cheapshark_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/app_theme.dart';

import 'screens/home/home_page.dart';
import 'screens/collection/collection_page.dart';
import 'screens/form/form_page.dart';
import 'screens/detail/detail_page.dart';
import 'screens/api_explorer/api_explorer_page.dart';
import 'screens/about/about_page.dart';
import 'screens/about/stats_page.dart';

void main() {
  runApp(const MediaExplorerApp());
}

class MediaExplorerApp extends StatelessWidget {
  const MediaExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CollectionProvider()),
        ChangeNotifierProvider(create: (_) => CheapSharkProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'MediaExplorer',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            routes: {
              '/': (ctx) => const HomePage(),
              '/collection': (ctx) => const CollectionPage(),
              '/form': (ctx) => const FormPage(),
              '/detail': (ctx) => const DetailPage(),
              '/api-explorer': (ctx) => const ApiExplorerPage(),
              '/about': (ctx) => const AboutPage(),
              '/stats': (ctx) => const StatsPage(),
            },
            onUnknownRoute: (settings) => MaterialPageRoute(
              builder: (_) => const HomePage(),
            ),
          );
        },
      ),
    );
  }
}