// import 'package:audioplayers/audioplayers.dart';
//
// class SoundManager {
//   static final SoundManager _instance = SoundManager._internal();
//   factory SoundManager() => _instance;
//
//   final Map<String, AudioPlayer> _audioPlayers = {};
//
//   SoundManager._internal();
//
//   Future<void> loadSounds() async {
//     await _loadSound("anyButton", "sounds/anyButton.mp3");
//     await _loadSound("bazaarMatch", "sounds/bazaarMatch.mp3");
//     await _loadSound("bazaarSwipeLeft", "sounds/bazaarSwipeLeft.mp3");
//     await _loadSound("bazaarSwipeRight", "sounds/bazaarSwipeRight.mp3");
//     await _loadSound("traderRevealed", "sounds/traderRevealed.mp3");
//   }
//
//   Future<void> _loadSound(String key, String path) async {
//     AudioPlayer player = AudioPlayer();
//     await player.setSource(AssetSource(path)); // Preload the asset.
//     _audioPlayers[key] = player;
//   }
//
//   void play(String key) {
//     final player = _audioPlayers[key];
//     player?.resume();
//   }
// }

import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;

  final Map<String, AudioPlayer> _audioPlayers = {};

  SoundManager._internal();

  /// Preload all sounds into memory.
  Future<void> loadSounds() async {
    await _loadSound("bazaarMatch", "sounds/bazaarMatch.mp3");
    await _loadSound("bazaarSwipeLeft", "sounds/bazaarSwipeLeft.mp3");
    await _loadSound("bazaarSwipeRight", "sounds/bazaarSwipeRight.mp3");
    await _loadSound("traderRevealed", "sounds/traderRevealed.mp3");
  }

  /// Load a single sound into an `AudioPlayer`.
  Future<void> _loadSound(String key, String path) async {
    AudioPlayer player = AudioPlayer();
    await player.setSource(AssetSource(path)); // Preload the sound.
    _audioPlayers[key] = player;
  }

  /// Play a sound based on its key.
  void play(String key) async {
    final player = _audioPlayers[key];
    if (player != null) {
      await player.stop(); // Reset the player state.
      await player.play(AssetSource('sounds/$key.mp3')); // Play from start.
    } else {
      print("No player found for key: $key");
    }
  }
}
