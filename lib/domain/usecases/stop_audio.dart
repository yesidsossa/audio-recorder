import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/upload_audio.dart';
import '../../presentation/providers/audio_provider.dart';
import '../../data/repositories/audio_repository_impl.dart';

class StopAudio {
  final AudioRepositoryImpl repository;
  final UploadAudio uploadAudio;

  StopAudio(this.repository, this.uploadAudio);

  Future<void> call(WidgetRef ref) async {
    ref.read(recordingStateProvider.notifier).state = false;

    final filePath = await repository.stopRecording();
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
