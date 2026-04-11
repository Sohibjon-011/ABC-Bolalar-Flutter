import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LevelProvider extends ChangeNotifier {
  static const _levelKey = 'abc_user_level';
  static const _xpKey = 'abc_user_xp';

  int _level = 1;
  int _xp = 0;

  int get level => _level;
  int get xp => _xp;

  int get xpRequired => _xpForLevel(_level);

  int get progressPct {
    final req = xpRequired;
    if (req <= 0) return 0;
    return min(100, ((_xp / req) * 100).floor());
  }

  String get levelText => 'Level $_level';

  int _xpForLevel(int lvl) => (100 * pow(1.5, (lvl - 1))).floor();

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    _level = sp.getInt(_levelKey) ?? 1;
    _xp = sp.getInt(_xpKey) ?? 0;
    notifyListeners();
  }

  Future<void> addXP(int amount) async {
    if (amount <= 0) return;
    _xp += amount;
    while (_xp >= xpRequired) {
      _xp -= xpRequired;
      _level += 1;
    }
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_levelKey, _level);
    await sp.setInt(_xpKey, _xp);
  }
}

