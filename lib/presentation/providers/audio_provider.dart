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

/// **Fuente de datos Firebase**
final firebaseAudioSourceProvider = Provider(
        (ref) => FirebaseAudioDataSource(FirebaseStorage.instance));

/// **Repositorio de audios**
final audioRepositoryProvider = Provider(
        (ref) => AudioRepositoryImpl(ref.read(firebaseAudioSourceProvider)));

/// **Casos de uso**
final getAudiosProvider =
Provider((ref) => GetAudios(ref.read(audioRepositoryProvider)));
final recordAudioProvider =
Provider((ref) => RecordAudio(ref.read(audioRepositoryProvider)));
final stopAudioProvider =
Provider((ref) => StopAudio(ref.read(uploadAudioProvider)));
final uploadAudioProvider =
Provider((ref) => UploadAudio(ref.read(audioRepositoryProvider)));

/// **Lista de audios obtenidos desde Firebase**
final audioListProvider = FutureProvider<List<Audio>>((ref) async {
  return await ref.read(getAudiosProvider)();
});

/// **Estado de grabación (si estamos grabando o no)**
final recordingStateProvider = StateProvider<bool>((ref) => false);

/// **Estado de progreso de carga a Firebase**
final uploadProgressProvider = StateProvider<double>((ref) => 0.0);

/// **Variable para almacenar la ruta del archivo actual**
final currentFilePathProvider = StateProvider<String?>((ref) => null);

/// **Grabador de audio (para mantener el estado del grabador)**
final audioRecorderProvider = Provider((ref) {
  final recorder = FlutterSoundRecorder();
  recorder.openRecorder();
  return recorder;
});
