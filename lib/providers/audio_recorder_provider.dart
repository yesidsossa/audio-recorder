import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorderNotifier extends StateNotifier<bool> {
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String? _filePath;

  AudioRecorderNotifier() : super(false) {
    _init();
  }

  Future<void> _init() async {
    await _recorder.openRecorder();
  }

  Future<void> startRecording() async {
    // 🚀 PEDIR PERMISO ANTES DE GRABAR
    if (await Permission.microphone.request().isDenied) {
      print("🚨 Permiso de micrófono DENEGADO.");
      return;
    }

    Directory tempDir = await getTemporaryDirectory();
    _filePath = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder.startRecorder(toFile: _filePath!, codec: Codec.aacADTS);
    state = true;
    print("🎙️ Grabando en: $_filePath");
  }

  Future<String?> stopRecording() async {
    await _recorder.stopRecorder();
    state = false;
    print("✅ Grabación finalizada: $_filePath");
    return _filePath;
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }
}

final audioRecorderProvider = StateNotifierProvider<AudioRecorderNotifier, bool>(
      (ref) => AudioRecorderNotifier(),
);
