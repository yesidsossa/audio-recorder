import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:telepatia_app/domain/repositories/audio_repository.dart';
import 'package:telepatia_app/domain/usecases/stop_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telepatia_app/domain/usecases/upload_audio.dart';

class MockAudioRepository extends Mock implements AudioRepository {}
class MockUploadAudio extends Mock implements UploadAudio {}
class MockRef extends Mock implements Ref {}

void main() {
  late StopAudio stopAudio;
  late MockAudioRepository mockRepository;
  late MockUploadAudio mockUploadAudio;
  late MockRef mockRef;

  setUp(() {
    mockRepository = MockAudioRepository();
    mockUploadAudio = MockUploadAudio();
    mockRef = MockRef();
    stopAudio = StopAudio(mockRepository, mockUploadAudio, mockRef);
  });

  group('StopAudio Use Case Tests', () {
    test('Given an ongoing recording, when stopAudio is called, then it should stop recording and upload the file', () async {
      when(() => mockRepository.stopRecording()).thenAnswer((_) async => 'test_audio.aac');
      when(() => mockUploadAudio.call('test_audio.aac')).thenAnswer((_) async => 'http://test.com/audio.mp3');

      final result = await stopAudio();

      expect(result, equals('http://test.com/audio.mp3'));
      verify(() => mockRepository.stopRecording()).called(1);
      verify(() => mockUploadAudio.call('test_audio.aac')).called(1);
    });

    test('Given no active recording, when stopAudio is called, then it should return null', () async {
      when(() => mockRepository.stopRecording()).thenAnswer((_) async => null);

      final result = await stopAudio();

      expect(result, isNull);
      verify(() => mockRepository.stopRecording()).called(1);
      verifyNever(() => mockUploadAudio.call(any()));
    });
  });
}
