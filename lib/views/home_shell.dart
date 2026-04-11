import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/toast_provider.dart';
import '../providers/fx_provider.dart';
import '../widgets/abc_background.dart';
import '../widgets/bottom_tabs.dart';
import '../widgets/toast_overlay.dart';
import '../widgets/top_bar.dart';
import '../widgets/victory_fx_overlay.dart';
import 'screens/abc_screen.dart';
import 'screens/animals_screen.dart';
import 'screens/colors_screen.dart';
import 'screens/numbers_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final screens = const [
      AbcScreen(),
      NumbersScreen(),
      ColorsScreen(),
      AnimalsScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const AbcBackground(),
          // Keep content clear of the bottom tabs on small screens.
          SafeArea(
            child: Column(
              children: [
                const TopBar(),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: IndexedStack(index: _tab, children: screens),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: BottomTabs.height + MediaQuery.paddingOf(context).bottom + 12),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
              child: BottomTabs(
                index: _tab,
                onChanged: (i) => setState(() => _tab = i),
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

