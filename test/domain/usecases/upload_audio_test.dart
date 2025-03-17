import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:telepatia_app/domain/repositories/audio_repository.dart';
import 'package:telepatia_app/domain/usecases/upload_audio.dart';

class MockAudioRepository extends Mock implements AudioRepository {}

void main() {
  late UploadAudio uploadAudio;
  late MockAudioRepository mockRepository;

  setUp(() {
    mockRepository = MockAudioRepository();
    uploadAudio = UploadAudio(mockRepository);
  });

  group('UploadAudio Use Case Tests', () {
    test('Given a valid file path, when uploadAudio is called, then it should return the uploaded file URL', () async {
      when(() => mockRepository.uploadAudio('test_audio.aac')).thenAnswer((_) async => 'http://test.com/audio.mp3');

      final result = await uploadAudio('test_audio.aac');

      expect(result, equals('http://test.com/audio.mp3'));
      verify(() => mockRepository.uploadAudio('test_audio.aac')).called(1);
    });

    test('Given an invalid file path, when uploadAudio is called, then it should return null', () async {
      when(() => mockRepository.uploadAudio('invalid_file.aac')).thenAnswer((_) async => null);

      final result = await uploadAudio('invalid_file.aac');

      expect(result, isNull);
      verify(() => mockRepository.uploadAudio('invalid_file.aac')).called(1);
    });
  });
}
