import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/repositories/audio_repository_impl.dart';
import '../../presentation/providers/audio_provider.dart';

class RecordAudio {
  final AudioRepositoryImpl repository;
  RecordAudio(this.repository);

  Future<void> call(WidgetRef ref, FlutterSoundRecorder recorder) async {
    if (await Permission.microphone.request().isDenied) {
      print("🚨 Permiso de micrófono DENEGADO.");
      return;
    }

    if (!recorder.isRecording) {
      try {
        await recorder.openRecorder();
      } catch (e) {
        print("🚨 Error abriendo el grabador: $e");
        return;
      }
    }

    Directory tempDir = await getTemporaryDirectory();
    String filePath = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

    await recorder.startRecorder(
      toFile: filePath,
      codec: Codec.aacADTS,
    );

    ref.read(recordingStateProvider.notifier).state = true;
    ref.read(currentFilePathProvider.notifier).state = filePath;

    print("🎙️ Grabando en: $filePath");
  }
}
