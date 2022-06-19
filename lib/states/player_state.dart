import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

import '../models/player_mode.dart';
import '../models/pronunciation_method.dart';
import '../models/speech_rate.dart';

class PlayerState with ChangeNotifier {
  final FlutterTts ttsPlayer = FlutterTts();
  late AudioPlayer syllablesPlayer = AudioPlayer();
  PlayerMode playerMode = PlayerMode.none;
  int? playerKey;
  int nextPlayerKey = 0;
  bool playerStoppedDueToSwitch = false;

  PlayerState() {
    (() async {
      await ttsPlayer.setSharedInstance(true);
      await ttsPlayer.setLanguage("zh-HK");
      await ttsPlayer.setSpeechRate(0.5);
      await ttsPlayer.setVolume(0.3);
      await ttsPlayer.setPitch(1.0);
      await ttsPlayer.isLanguageAvailable("zh-HK");
    })();
  }

  int getPlayerKey() {
    nextPlayerKey += 1;
    return nextPlayerKey - 1;
  }

  Future<bool> setPlayerKey(int newKey) async {
    if (playerKey != null) {
      await stopHelper();
      if (playerKey == newKey) {
        playerMode = PlayerMode.none;
        playerKey = null;
        notifyListeners();
        playerStoppedDueToSwitch = false;
        return true; // break
      } else {
        playerStoppedDueToSwitch = true;
      }
    }
    playerKey = newKey;
    return false;
  }

  refreshPlayerState() async {
    await stop();
    nextPlayerKey = 0;
    playerStoppedDueToSwitch = false;
    notifyListeners();
  }

  Future<void> syllablesPlay(int newKey, List<String> prs,
      PronunciationMethod method, SpeechRate rate) async {
    if (await setPlayerKey(newKey)) {
      return;
    }
    playerMode = PlayerMode.syllables;
    notifyListeners();
    final String speakerGender =
        method == PronunciationMethod.syllableRecordingsMale
            ? "male"
            : "female";
    await syllablesPlayer.setAudioSource(ConcatenatingAudioSource(
        children: prs
            .map((syllable) => AudioSource.uri(Uri.parse(
                "asset:///assets/jyutping_$speakerGender/$syllable.mp3")))
            .toList()));
    syllablesPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (!playerStoppedDueToSwitch) {
          playerMode = PlayerMode.none;
          playerKey = null;
          notifyListeners();
        } else {
          playerStoppedDueToSwitch = false;
        }
      }
    });
    final speed = method == PronunciationMethod.syllableRecordingsMale
        ? (rate == SpeechRate.slow
            ? 0.6
            : rate == SpeechRate.medium
                ? 1.0
                : 1.3)
        : (rate == SpeechRate.slow
            ? 0.8
            : rate == SpeechRate.medium
                ? 1.5
                : 2.0);
    final volume =
        method == PronunciationMethod.syllableRecordingsMale ? 0.4 : 0.5;
    await syllablesPlayer.setSpeed(speed);
    await syllablesPlayer.setVolume(volume);
    await syllablesPlayer.seek(Duration.zero, index: 0);
    await syllablesPlayer.play();
  }

  Future<void> ttsPlay(int newKey, String text, SpeechRate rate) async {
    if (await setPlayerKey(newKey)) {
      return;
    }
    playerMode = PlayerMode.tts;
    notifyListeners();
    final speed = rate == SpeechRate.slow
        ? 0.15
        : rate == SpeechRate.medium
            ? 0.5
            : 0.6;
    await ttsPlayer.setSpeechRate(speed);
    await ttsPlayer.speak(text);
    ttsPlayer.setCompletionHandler(() {
      if (!playerStoppedDueToSwitch) {
        playerMode = PlayerMode.none;
        playerKey = null;
        notifyListeners();
      } else {
        playerStoppedDueToSwitch = false;
      }
    });
  }

  stop() async {
    if (playerMode != PlayerMode.none) {
      await stopHelper();
      playerMode = PlayerMode.none;
      playerKey = null;
    }
  }

  stopHelper() async {
    switch (playerMode) {
      case PlayerMode.tts:
        await ttsPlayer.stop();
        break;
      case PlayerMode.syllables:
        await syllablesPlayer.stop();
        break;
      case PlayerMode.none:
        // do nothing
        break;
    }
  }
}
