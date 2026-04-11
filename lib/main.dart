import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app.dart';
import 'providers/audio_provider.dart';
import 'providers/fx_provider.dart';
import 'providers/level_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/toast_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProvider(create: (_) => LevelProvider()..load()),
        Provider(create: (_) => AudioProvider()..init()),
        ChangeNotifierProvider(create: (_) => ToastProvider()),
        ChangeNotifierProvider(create: (_) => FxProvider()),
      ],
      child: const AbcBolalarApp(),
    ),
  );
}

