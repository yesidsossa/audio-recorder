import 'package:permission_handler/permission_handler.dart';

import '../../domain/repositories/audio_repository.dart';

class RecordAudio {
  final AudioRepository repository;

  RecordAudio(this.repository);

  Future<String?> call() async {
    final status = await Permission.microphone.request();
    if (status.isDenied) {
      print("🚨 Permiso de micrófono DENEGADO.");
      return null;
    }

    return await repository.recordAudio();
  }

}
