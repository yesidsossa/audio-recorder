import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/audio_repository.dart';
import '../../presentation/providers/audio_provider.dart';
import 'upload_audio.dart';

class StopAudio {
  final AudioRepository repository;
  final UploadAudio uploadAudio;
  final Ref ref;

  StopAudio(this.repository, this.uploadAudio, this.ref);

  Future<String?> call() async {
    String? filePath = await repository.stopRecording();

    if (filePath != null) {
      print("✅ Archivo de audio listo para subir: $filePath");

      String? downloadUrl = await uploadAudio(filePath);

      if (downloadUrl != null) {
        print("📤 Archivo subido correctamente: $downloadUrl");

        ref.invalidate(audioListProvider);

        return downloadUrl;
      } else {
        print("🚨 Error subiendo archivo.");
      }
    } else {
      print("🚨 No hay grabación válida para subir.");
    }
    return null;
  }
}
