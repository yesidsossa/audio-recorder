import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:telepatia_app/domain/entities/audio.dart';
import 'package:telepatia_app/domain/repositories/audio_repository.dart';
import 'package:telepatia_app/domain/usecases/get_audios.dart';

class MockAudioRepository extends Mock implements AudioRepository {}

void main() {
  late GetAudios getAudios;
  late MockAudioRepository mockRepository;

  setUp(() {
    mockRepository = MockAudioRepository();
    getAudios = GetAudios(mockRepository);
  });

  group('GetAudios Use Case Tests', () {
    test('Given a list of audios in the repository, when getAudios is called, then it should return the correct list', () async {
      final mockAudioList = [
        Audio(id: '1', name: 'Test 1', url: 'http://test.com/audio1.mp3'),
        Audio(id: '2', name: 'Test 2', url: 'http://test.com/audio2.mp3'),
      ];

      when(() => mockRepository.getAudios()).thenAnswer((_) async => mockAudioList);

      final result = await getAudios();

      expect(result, equals(mockAudioList));
      verify(() => mockRepository.getAudios()).called(1);
    });
  });
}