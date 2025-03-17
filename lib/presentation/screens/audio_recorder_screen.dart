import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_provider.dart';
import '../widgets/audio_item_widget.dart';
import 'dart:async';

class AudioRecorderScreen extends ConsumerStatefulWidget {
  const AudioRecorderScreen({super.key});

  @override
  _AudioRecorderScreenState createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends ConsumerState<AudioRecorderScreen> {
  int _recordingDuration = 0;
  Timer? _timer;

  void _startTimer() {
    _recordingDuration = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordingDuration++;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = ref.watch(recordingStateProvider);
    final uploadProgress = ref.watch(uploadProgressProvider);
    final audioList = ref.watch(audioListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Audio Recorder')),
      body: Column(
        children: [
          const SizedBox(height: 20),

          if (isRecording)
            Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Grabando...",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 5),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _formatDuration(_recordingDuration),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () async {
              if (isRecording) {
                String? result = await ref.read(stopAudioProvider)();
                if (result != null) {
                  ref.read(recordingStateProvider.notifier).stop();
                  _stopTimer();
                }
              } else {
                String? result = await ref.read(recordAudioProvider)();
                if (result != null) {
                  ref.read(recordingStateProvider.notifier).start();
                  _startTimer();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isRecording ? Colors.red : Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isRecording ? Icons.stop : Icons.mic, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  isRecording ? 'Detener' : 'Grabar',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),

          if (uploadProgress > 0 && uploadProgress < 1)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const Text("Subiendo audio...", style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 5),
                  CircularProgressIndicator(value: uploadProgress),
                ],
              ),
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
