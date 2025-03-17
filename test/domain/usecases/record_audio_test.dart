import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:telepatia_app/domain/repositories/audio_repository.dart';
import 'package:telepatia_app/domain/usecases/record_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class MockAudioRepository extends Mock implements AudioRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RecordAudio recordAudio;
  late MockAudioRepository mockRepository;

  setUp(() {
    mockRepository = MockAudioRepository();
    recordAudio = RecordAudio(mockRepository);

    const MethodChannel channel = MethodChannel('flutter.baseflow.com/permissions/methods');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'requestPermissions') {
        return {
          Permission.microphone.value: 1,
        };
      }
      return null;
    });
  });

  group('RecordAudio Use Case Tests', () {
    test('Given the microphone permission is granted, when calling recordAudio, then it should start recording', () async {
      when(() => mockRepository.recordAudio()).thenAnswer((_) async => 'test_audio.aac');

      final result = await recordAudio();

      expect(result, equals('test_audio.aac'));
      verify(() => mockRepository.recordAudio()).called(1);
    });
  });
}
