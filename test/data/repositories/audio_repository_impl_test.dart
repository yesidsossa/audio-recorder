import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:telepatia_app/data/repositories/audio_repository_impl.dart';
import 'package:telepatia_app/data/sources/firebase_audio_data_source.dart';

class MockFirebaseAudioDataSource extends Mock implements FirebaseAudioDataSource {}
class MockFlutterSoundRecorder extends Mock implements FlutterSoundRecorder {}

void main() {
  late AudioRepositoryImpl repository;
  late MockFirebaseAudioDataSource mockDataSource;
  late MockFlutterSoundRecorder mockRecorder;

  setUpAll(() {
    registerFallbackValue(Codec.aacADTS);
  });

  setUp(() {
    mockDataSource = MockFirebaseAudioDataSource();
    mockRecorder = MockFlutterSoundRecorder();
    repository = AudioRepositoryImpl(mockDataSource, mockRecorder);
  });

  group('Audio Recording Tests', () {
    test('Given the recorder is not recording, when recordAudio is called, then it should start recording', () async {
      when(() => mockRecorder.isRecording).thenReturn(false);
      when(() => mockRecorder.openRecorder()).thenAnswer((_) async {});
      when(() => mockRecorder.startRecorder(
        toFile: any(named: 'toFile'),
        codec: any(named: 'codec'),
      )).thenAnswer((_) async => null);

      final result = await repository.recordAudio();
      expect(result, isNotNull);
      verify(() => mockRecorder.startRecorder(
        toFile: any(named: 'toFile'),
        codec: any(named: 'codec'),
      )).called(1);
    });

    test('Given an ongoing recording, when stopRecording is called, then it should stop and return null', () async {
      when(() => mockRecorder.stopRecorder()).thenAnswer((_) async => null);
      final result = await repository.stopRecording();
      expect(result, isNull);
    });

    test('Given a valid file path, when uploadAudio is called, then it should return the uploaded file URL', () async {
      when(() => mockDataSource.uploadAudio(any())).thenAnswer((_) async => 'http://test.com/audio.mp3');

      final result = await repository.uploadAudio('test_file.aac');
      expect(result, 'http://test.com/audio.mp3');
    });
  });
}
