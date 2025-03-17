import '../../domain/repositories/audio_repository.dart';
import '../../domain/entities/audio.dart';
import '../sources/firebase_audio_data_source.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRepositoryImpl implements AudioRepository {
  final FirebaseAudioDataSource remoteDataSource;
  late FlutterSoundRecorder _recorder;
  String? _currentFilePath;

  AudioRepositoryImpl(this.remoteDataSource) {
    _recorder = FlutterSoundRecorder();
  }

  @override
  Future<List<Audio>> getAudios() => remoteDataSource.getAudios();

  @override
  Future<String?> uploadAudio(String filePath) => remoteDataSource.uploadAudio(filePath);

  @override
  Future<String?> recordAudio() async {
    PermissionStatus status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw Exception('❌ Permiso de micrófono denegado.');
    }

    Directory tempDir = await getTemporaryDirectory();
    _currentFilePath = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder.openRecorder();
    await _recorder.startRecorder(
      toFile: _currentFilePath!,
      codec: Codec.aacADTS,
    );

    print("🎙️ Grabando en: $_currentFilePath");
    return _currentFilePath;
  }

  @override
  Future<String?> stopRecording() async {
    await _recorder.stopRecorder();

    // 🔥 Esperar 500ms para asegurar que el archivo se guarde
    await Future.delayed(const Duration(milliseconds: 500));

    if (_currentFilePath == null || !File(_currentFilePath!).existsSync()) {
      throw Exception("❌ La grabación no se guardó correctamente.");
    }

    print("✅ Grabación finalizada: $_currentFilePath");
    return _currentFilePath;
  }
}
