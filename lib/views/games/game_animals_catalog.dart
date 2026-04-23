import '../../models/game_animal_sound.dart';

/// Barcha mini-o'yinlar bitta ro'yxatdan foydalanadi.
/// Haqiqiy ovoz: `assets/game_sounds/animals/` ga `assetFile` nomi bilan qo'ying (mp3/ogg/wav).
const List<GameAnimalSound> kGameAnimals = [
  GameAnimalSound(
    id: 'cow',
    emoji: '🐄',
    label: 'Mol',
    assetFile: 'mol.mp3',
    ttsCue: 'Muuu! Muuu!',
  ),
  GameAnimalSound(
    id: 'duck',
    emoji: '🦆',
    label: "O'rdak",
    assetFile: 'ordak.mp3',
    ttsCue: 'Gaak! Gaak!',
  ),
  GameAnimalSound(
    id: 'bird',
    emoji: '🐦',
    label: 'Qush',
    assetFile: 'qush.mp3',
    ttsCue: 'Chiq-chiq!',
  ),
  GameAnimalSound(
    id: 'bear',
    emoji: '🐻',
    label: 'Ayiq',
    assetFile: 'ayiq.mp3',
    ttsCue: 'Grrr! Grrr!',
  ),
  GameAnimalSound(
    id: 'snake',
    emoji: '🐍',
    label: 'Ilon',
    assetFile: 'ilon.mp3',
    ttsCue: 'Shhh! Shhh!',
  ),
  GameAnimalSound(
    id: 'fish',
    emoji: '🐟',
    label: 'Baliq',
    assetFile: 'baliq.mp3',
    ttsCue: 'Bul-bul-bul!',
  ),
  GameAnimalSound(
    id: 'zebra',
    emoji: '🦓',
    label: 'Zebra',
    assetFile: 'zebra.mp3',
    ttsCue: 'I-hii! I-hii!',
  ),
  GameAnimalSound(
    id: 'giraffe',
    emoji: '🦒',
    label: 'Jirafa',
    assetFile: 'jirafa.mp3',
    ttsCue: 'Hmm! Hmm!',
  ),
];
