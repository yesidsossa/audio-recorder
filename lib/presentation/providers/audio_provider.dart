import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_sound/flutter_sound.dart';
import '../../domain/usecases/get_audios.dart';
import '../../domain/usecases/record_audio.dart';
import '../../domain/usecases/upload_audio.dart';
import '../../domain/usecases/stop_audio.dart';
import '../../domain/entities/audio.dart';
import '../../data/repositories/audio_repository_impl.dart';
import '../../data/sources/firebase_audio_data_source.dart';
import '../../domain/repositories/audio_repository.dart';
import '../../domain/datasources/audio_data_source.dart';

// Proveedor del DataSource (ahora tipado correctamente como FirebaseAudioDataSource)
final firebaseAudioSourceProvider = Provider<FirebaseAudioDataSource>((ref) =>
    FirebaseAudioDataSource(FirebaseStorage.instance));

// Proveedor del grabador de audio (facilitando pruebas)
final audioRecorderProvider = Provider<FlutterSoundRecorder>((ref) =>
    FlutterSoundRecorder());

// Proveedor del repositorio de audio con inyección de dependencias
final audioRepositoryProvider = Provider<AudioRepository>((ref) =>
    AudioRepositoryImpl(ref.read(firebaseAudioSourceProvider), ref.read(audioRecorderProvider)));

// Proveedores de casos de uso
final getAudiosProvider = Provider<GetAudios>((ref) => GetAudios(ref.read(audioRepositoryProvider)));
final recordAudioProvider = Provider<RecordAudio>((ref) => RecordAudio(ref.read(audioRepositoryProvider)));
final uploadAudioProvider = Provider<UploadAudio>((ref) => UploadAudio(ref.read(audioRepositoryProvider)));

final stopAudioProvider = Provider<StopAudio>((ref) => StopAudio(
  ref.read(audioRepositoryProvider),
  ref.read(uploadAudioProvider),
  ref,
));

// Proveedor para la lista de audios en Firebase
final audioListProvider = FutureProvider<List<Audio>>((ref) async {
  return await ref.read(getAudiosProvider)();
});

// Estado del grabador (optimizado con StateNotifier)
class RecordingStateNotifier extends StateNotifier<bool> {
  RecordingStateNotifier() : super(false);

  void start() => state = true;
  void stop() => state = false;
}

final recordingStateProvider = StateNotifierProvider<RecordingStateNotifier, bool>((ref) => RecordingStateNotifier());

// Estado de progreso de carga
final uploadProgressProvider = StateProvider<double>((ref) => 0.0);
