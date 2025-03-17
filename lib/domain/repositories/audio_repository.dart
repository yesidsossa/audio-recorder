import '../entities/audio.dart';

abstract class AudioRepository {
  Future<List<Audio>> getAudios();
  Future<String?> recordAudio();
  Future<String?> uploadAudio(String filePath);
}
