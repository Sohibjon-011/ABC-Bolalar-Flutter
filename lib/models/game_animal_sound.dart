/// O'yinlar uchun hayvon: ixtiyoriy asset + TTS «haqiqiy o'yin» uslubidagi onomatopeya.
class GameAnimalSound {
  const GameAnimalSound({
    required this.id,
    required this.emoji,
    required this.label,
    this.assetFile,
    required this.ttsCue,
  });

  final String id;
  final String emoji;
  final String label;

  /// `assets/game_sounds/animals/` ichidagi fayl nomi, masalan `mol.mp3`. Bo'lmasa faqat TTS.
  final String? assetFile;

  /// TTS bilan ijro (ovozli o'yin effekti). Qisqa va an'anaviy onomatopeya.
  final String ttsCue;
}
