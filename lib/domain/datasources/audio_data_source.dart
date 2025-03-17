import '../../domain/entities/audio.dart';

abstract class AudioDataSource {
  Future<List<Audio>> getAudios();
  Future<String?> uploadAudio(String filePath);
}
