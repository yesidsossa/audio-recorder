import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/usecases/get_audios.dart';
import '../../domain/usecases/record_audio.dart';
import '../../domain/usecases/upload_audio.dart';
import '../../domain/usecases/stop_audio.dart';
import '../../domain/entities/audio.dart';
import '../../data/repositories/audio_repository_impl.dart';
import '../../data/sources/firebase_audio_data_source.dart';

final firebaseAudioSourceProvider = Provider((ref) => FirebaseAudioDataSource(FirebaseStorage.instance));
final audioRepositoryProvider = Provider((ref) => AudioRepositoryImpl(ref.read(firebaseAudioSourceProvider)));

final getAudiosProvider = Provider((ref) => GetAudios(ref.read(audioRepositoryProvider)));
final recordAudioProvider = Provider((ref) => RecordAudio(ref.read(audioRepositoryProvider)));
final stopAudioProvider = Provider((ref) => StopAudio(
  ref.read(audioRepositoryProvider),
  ref.read(uploadAudioProvider),
));final uploadAudioProvider = Provider((ref) => UploadAudio(ref.read(audioRepositoryProvider)));

final audioListProvider = FutureProvider<List<Audio>>((ref) async {
  return await ref.read(getAudiosProvider)();
});

final recordingStateProvider = StateProvider<bool>((ref) => false);
final uploadProgressProvider = StateProvider<double>((ref) => 0.0);
final currentFilePathProvider = StateProvider<String?>((ref) => null);

final audioRecorderProvider = StateNotifierProvider<AudioRecorderNotifier, FlutterSoundRecorder>(
      (ref) => AudioRecorderNotifier(),
);

class AudioRecorderNotifier extends StateNotifier<FlutterSoundRecorder> {
  AudioRecorderNotifier() : super(FlutterSoundRecorder()) {
    state.openRecorder();
  }
}
