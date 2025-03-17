import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telepatia_app/presentation/providers/audio_provider.dart';

void main() {
  group('Recording State Provider Tests', () {
    test('Given the initial state, when checking recordingStateProvider, then it should be false', () {
      final container = ProviderContainer();
      expect(container.read(recordingStateProvider), false);
    });

    test('Given the recording state is false, when start() is called, then it should change to true', () {
      final container = ProviderContainer();
      final notifier = container.read(recordingStateProvider.notifier);

      notifier.start();
      expect(container.read(recordingStateProvider), true);
    });

    test('Given the recording state is true, when stop() is called, then it should change to false', () {
      final container = ProviderContainer();
      final notifier = container.read(recordingStateProvider.notifier);

      notifier.start();
      expect(container.read(recordingStateProvider), true);

      notifier.stop();
      expect(container.read(recordingStateProvider), false);
    });
  });
}