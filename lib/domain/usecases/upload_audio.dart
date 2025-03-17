import '../repositories/audio_repository.dart';

class UploadAudio {
  final AudioRepository repository;

  UploadAudio(this.repository);

  Future<String?> call(String filePath) async {
    return await repository.uploadAudio(filePath);
  }
}
