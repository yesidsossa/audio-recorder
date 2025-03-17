import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_provider.dart';
import '../widgets/audio_item_widget.dart';

class AudioRecorderScreen extends ConsumerWidget {
  const AudioRecorderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRecording = ref.watch(recordingStateProvider);
    final uploadProgress = ref.watch(uploadProgressProvider);
    final audioList = ref.watch(audioListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Audio Recorder')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (isRecording) {
                await ref.read(stopAudioProvider)();
                ref.read(recordingStateProvider.notifier).state = false;
              } else {
                await ref.read(recordAudioProvider)();
                ref.read(recordingStateProvider.notifier).state = true;
              }
            },
            child: Text(isRecording ? 'Detener' : 'Grabar'),
          ),
          if (uploadProgress > 0 && uploadProgress < 1)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: LinearProgressIndicator(value: uploadProgress),
            ),
          const SizedBox(height: 20),
          Expanded(
            child: audioList.when(
              data: (audios) => ListView.builder(
                itemCount: audios.length,
                itemBuilder: (context, index) {
                  return AudioItemWidget(
                    name: audios[index].name,
                    url: audios[index].url,
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
