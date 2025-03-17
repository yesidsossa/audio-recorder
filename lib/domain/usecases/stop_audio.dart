import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import '../../domain/usecases/upload_audio.dart';
import '../../presentation/providers/audio_provider.dart';

class StopAudio {
  final UploadAudio uploadAudio;
  StopAudio(this.uploadAudio);

  Future<void> call(WidgetRef ref, FlutterSoundRecorder recorder) async {
    ref.read(recordingStateProvider.notifier).state = false;
    await recorder.stopRecorder();

    await Future.delayed(const Duration(milliseconds: 500));

    String? filePath = ref.read(currentFilePathProvider);
    if (filePath != null && File(filePath).existsSync() && File(filePath).lengthSync() > 1000) {
      print("✅ Grabación finalizada: $filePath");

      ref.read(uploadProgressProvider.notifier).state = 0.0;
      String? downloadUrl = await uploadAudio(filePath);

      if (downloadUrl != null) {
        ref.refresh(audioListProvider);
        print("📤 Archivo subido con éxito: $downloadUrl");
      } else {
        print("🚨 Error subiendo archivo.");
      }
    } else {
      print("🚨 Archivo de audio inválido. No se subirá.");
    }
  }
}
