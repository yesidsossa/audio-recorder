import '../repositories/audio_repository.dart';
import '../entities/audio.dart';

class GetAudios {
  final AudioRepository repository;

  GetAudios(this.repository);

  Future<List<Audio>> call() async {
    return await repository.getAudios();
  }
}
