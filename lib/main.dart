import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/app.dart';
import 'providers/audio_provider.dart';
import 'services/animal_sound_player.dart';
import 'providers/fx_provider.dart';
import 'providers/level_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/toast_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // YouTube/WebView ekranlarida auto-rotate bo'lib ketmasligi uchun portraitga lock qilamiz.
  await SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProvider(create: (_) => LevelProvider()..load()),
        Provider(create: (_) => AudioProvider()..init()),
        Provider(
          create: (ctx) {
            final p = AnimalSoundPlayer(ctx.read<AudioProvider>());
            Future.microtask(p.ready);
            return p;
          },
          dispose: (_, p) => p.dispose(),
        ),
        ChangeNotifierProvider(create: (_) => ToastProvider()),
        ChangeNotifierProvider(create: (_) => FxProvider()),
      ],
      child: const AbcBolalarApp(),
    ),
  );
}

