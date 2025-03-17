import 'package:flutter_test/flutter_test.dart';
import 'package:telepatia_app/domain/entities/audio.dart';

void main() {
  group('Audio Entity Tests', () {
    test('Given valid parameters, when creating an Audio instance, then it should store the correct values', () {
      final audio = Audio(id: '123', name: 'Test Audio', url: 'http://test.com/audio.mp3');

      expect(audio.id, '123');
      expect(audio.name, 'Test Audio');
      expect(audio.url, 'http://test.com/audio.mp3');
    });
  });
}
