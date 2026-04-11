import 'package:flutter/material.dart';

/// [displayIcon] — ba'zi emoji'lar (masalan 🪿) eski Android'da ko'rinmaydi; shunda Material icon ishlatiladi.
class LearnItem {
  const LearnItem({
    required this.id,
    required this.big,
    required this.audioNumber,
    this.small,
    this.emoji,
    this.displayIcon,
    this.imageAsset,
    this.hex,
    this.dots,
  });

  final String id;
  final String big;
  final String? small;
  final String? emoji;
  final IconData? displayIcon;
  final String? imageAsset; // for local PNGs
  final String? hex; // for colors
  final int? dots; // for numbers
  final int audioNumber; // maps to public/MP4/<n>.ogg
}

