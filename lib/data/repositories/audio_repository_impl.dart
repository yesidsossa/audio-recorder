import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import '../../domain/entities/audio.dart';
import '../../domain/repositories/audio_repository.dart';
import '../sources/firebase_audio_data_source.dart';

class AudioRepositoryImpl implements AudioRepository {
  final FirebaseAudioDataSource firebaseDataSource;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String? _currentFilePath;

  AudioRepositoryImpl(this.firebaseDataSource);

  @override
  Future<String?> recordAudio() async {
    try {
      if (!_recorder.isRecording) {
        await _recorder.openRecorder();
      }

      Directory tempDir = Directory.systemTemp;
      _currentFilePath = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _recorder.startRecorder(
        toFile: _currentFilePath!,
        codec: Codec.aacADTS,
      );

      print("🎙️ Grabando en: $_currentFilePath");
      return _currentFilePath;
    } catch (e) {
      print("🚨 Error al iniciar grabación: $e");
      return null;
    }
  }

  @override
  Future<String?> stopRecording() async {
    if (_currentFilePath == null) {
      print("⚠️ No hay grabación activa para detener.");
      return null;
    }

    await _recorder.stopRecorder();
    print("✅ Grabación detenida. Archivo guardado en: $_currentFilePath");

    return _currentFilePath;
  }

  @override
  Future<String?> uploadAudio(String filePath) async {
    return await firebaseDataSource.uploadAudio(filePath);
  }

  @override
  Future<List<Audio>> getAudios() async {
    return await firebaseDataSource.getAudios();
  }
}
