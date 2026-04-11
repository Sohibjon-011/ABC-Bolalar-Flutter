import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../views/home_shell.dart';

class AbcBolalarApp extends StatelessWidget {
  const AbcBolalarApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<ThemeProvider, ThemeMode>((p) => p.themeMode);

    final lightScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF00BBF9),
      brightness: Brightness.light,
    ).copyWith(
      surface: const Color(0xFFF7FBFF),
      surfaceContainerHighest: const Color(0xFFFFFFFF).withOpacity(0.80),
    );

    final darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF00BBF9),
      brightness: Brightness.dark,
    ).copyWith(
      surface: const Color(0xFF070713),
      surfaceContainerHighest: const Color(0xFF121222).withOpacity(0.78),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ABC Bolalar',
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
        scaffoldBackgroundColor: lightScheme.surface,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
        scaffoldBackgroundColor: darkScheme.surface,
      ),
      home: const HomeShell(),
    );
  }
}

