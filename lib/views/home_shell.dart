import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/fx_provider.dart';
import '../providers/toast_provider.dart';
import '../widgets/abc_background.dart';
import '../widgets/bottom_tabs.dart';
import '../widgets/platform_nav_bar.dart';
import '../widgets/toast_overlay.dart';
import '../widgets/top_bar.dart';
import '../widgets/victory_fx_overlay.dart';
import 'screens/abc_screen.dart';
import 'screens/animals_screen.dart';
import 'screens/colors_screen.dart';
import 'screens/games_section_screen.dart';
import 'screens/numbers_screen.dart';
import 'screens/parent_section_screen.dart';
import 'screens/videos_section_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  /// 0 — videolar, 1 — o'yinlar, 2 — ota-ona, 3 — hozirgi o'quv bo'limi.
  int _platformSection = 3;
  int _learnTab = 0;

  void _restoreUi() {
    // Youtube/WebView fullscreen yoki klaviatura fokusidan keyin UI "sakrashi"ni kamaytirish.
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Ba'zi Android qurilmalarda WebView YouTube sahifasi orientation'ni "bosib" qo'yishi mumkin.
    // Shu sabab UI qayta tiklanganda portrait lock'ni yana qo'llaymiz.
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
  }

  void _setPlatformSection(int i) {
    if (_platformSection == i) return;
    _restoreUi();
    setState(() => _platformSection = i);
  }

  double _bottomInset(BuildContext context) {
    const gap = 8.0;
    final safe = MediaQuery.paddingOf(context).bottom;
    final platform = PlatformNavBar.barHeight + 16;
    final learn = _platformSection == 3 ? BottomTabs.height + gap : 0.0;
    return platform + learn + safe + 12;
  }

  Widget _platformBody() {
    switch (_platformSection) {
      case 0:
        return const VideosSectionScreen(key: ValueKey('videos'));
      case 1:
        return const GamesSectionScreen(key: ValueKey('games'));
      case 2:
        return const ParentSectionScreen(key: ValueKey('parents'));
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final learnScreens = const [
      AbcScreen(),
      NumbersScreen(),
      ColorsScreen(),
      AnimalsScreen(),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const AbcBackground(),
          SafeArea(
            child: Column(
              children: [
                TopBar(showLevel: _platformSection == 2),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: _platformSection == 3
                              ? IndexedStack(
                                  key: const ValueKey('learn'),
                                  index: _learnTab,
                                  children: learnScreens,
                                )
                              : _platformBody(),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: _bottomInset(context)),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: MediaQuery.removeViewInsets(
              context: context,
              removeBottom: true,
              child: SafeArea(
                minimum: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_platformSection == 3) ...[
                      BottomTabs(
                        index: _learnTab,
                        onChanged: (i) {
                          _restoreUi();
                          setState(() => _learnTab = i);
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                    PlatformNavBar(
                      section: _platformSection,
                      onSectionChanged: _setPlatformSection,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Consumer<ToastProvider>(
            builder: (context, tp, _) => ToastOverlay(items: tp.items),
          ),
          Consumer<FxProvider>(
            builder: (context, fx, _) => VictoryFxOverlay(visible: fx.show, nonce: fx.nonce),
          ),
        ],
      ),
    );
  }
}
