import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/audio_provider.dart';
import '../../data/repositories/audio_repository_impl.dart';

class RecordAudio {
  final AudioRepositoryImpl repository;
  RecordAudio(this.repository);

  Future<void> call(WidgetRef ref) async {
    final filePath = await repository.recordAudio();
    ref.read(currentFilePathProvider.notifier).state = filePath;
    ref.read(recordingStateProvider.notifier).state = true;
  }
}
