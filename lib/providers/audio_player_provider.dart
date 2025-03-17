import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';

class AudioPlayerNotifier extends StateNotifier<Map<String, dynamic>> {
  FlutterSoundPlayer _player = FlutterSoundPlayer();
  Timer? _progressTimer;

  AudioPlayerNotifier() : super({
    'isPlaying': false,
    'isPaused': false,
    'progress': 0.0,
    'position': Duration.zero,
    'duration': Duration.zero,
  }) {
    _player.openPlayer();
  }

  Future<void> playPauseAudio(String url) async {
    if (state['isPlaying']) {
      await _player.pausePlayer();
      _progressTimer?.cancel();
      state = {...state, 'isPlaying': false, 'isPaused': true};
    } else if (state['isPaused']) {
      await _player.resumePlayer();
      _startProgressTracking();
      state = {...state, 'isPlaying': true, 'isPaused': false};
    } else {
      await _player.startPlayer(
        fromURI: url,
        whenFinished: () {
          _progressTimer?.cancel();
          state = {
            'isPlaying': false,
            'isPaused': false,
            'progress': 0.0,
            'position': Duration.zero,
          };
        },
      );
      _startProgressTracking();
      state = {...state, 'isPlaying': true, 'isPaused': false};
    }
  }

  void _startProgressTracking() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      if (_player.isPlaying) {
        final pos = await _player.getProgress();
        state = {
          'isPlaying': true,
          'isPaused': false,
          'position': pos['position'] ?? Duration.zero,
          'duration': pos['duration'] ?? Duration.zero,
          'progress': (pos['duration']?.inMilliseconds ?? 1) > 0
              ? (pos['position']?.inMilliseconds ?? 0) /
              (pos['duration']?.inMilliseconds ?? 1)
              : 0.0,
        };
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _player.closePlayer();
    _progressTimer?.cancel();
    super.dispose();
  }
}

final audioPlayerProvider = StateNotifierProvider<AudioPlayerNotifier, Map<String, dynamic>>(
      (ref) => AudioPlayerNotifier(),
);
