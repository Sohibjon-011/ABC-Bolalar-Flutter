import 'dart:async';

import 'package:flutter/foundation.dart';

class ToastItem {
  ToastItem({required this.id, required this.emoji, required this.text});

  final String id;
  final String emoji;
  final String text;
}

class ToastProvider extends ChangeNotifier {
  final List<ToastItem> _items = [];
  List<ToastItem> get items => List.unmodifiable(_items);

  void push(String emoji, String text) {
    final id = '${DateTime.now().microsecondsSinceEpoch}_${_items.length}';
    _items.add(ToastItem(id: id, emoji: emoji, text: text));
    notifyListeners();

    Timer(const Duration(milliseconds: 1400), () {
      _items.removeWhere((x) => x.id == id);
      notifyListeners();
    });
  }
}

