import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../providers/audio_recorder_provider.dart';
import '../providers/upload_provider.dart';
import '../widgets/audio_item_widget.dart';

class AudioRecorderScreen extends ConsumerStatefulWidget {
  const AudioRecorderScreen({super.key});

  @override
  _AudioRecorderScreenState createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends ConsumerState<AudioRecorderScreen> {
  List<Map<String, String>> _recordings = [];

  @override
  void initState() {
    super.initState();
    _fetchRecordings();
  }

  Future<void> _fetchRecordings() async {
    List<Map<String, String>> recordings = [];
    try {
      ListResult result = await FirebaseStorage.instance.ref('audios').listAll();
      for (var item in result.items) {
        String url = await item.getDownloadURL();
        recordings.add({"name": item.name, "url": url});
      }
    } catch (e) {
      print('🚨 Error obteniendo grabaciones: $e');
    }

    setState(() {
      _recordings = recordings;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = ref.watch(audioRecorderProvider);
    final uploadProgress = ref.watch(uploadProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Audio Recorder')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              if (isRecording) {
                String? path = await ref.read(audioRecorderProvider.notifier).stopRecording();
                if (path != null) {
                  String? downloadUrl = await ref.read(uploadProvider.notifier).uploadToFirebase(File(path));
                  if (downloadUrl != null) {
                    _fetchRecordings(); // 🔥 ACTUALIZAR LISTA DE AUDIOS DESPUÉS DE SUBIR
                  }
                }
              } else {
                await ref.read(audioRecorderProvider.notifier).startRecording();
              }
            },
            child: Text(isRecording ? 'Detener' : 'Grabar'),
          ),
          if (uploadProgress > 0 && uploadProgress < 1)
            LinearProgressIndicator(value: uploadProgress),
          const SizedBox(height: 20),
          Expanded(
            child: _recordings.isEmpty
                ? const Center(child: Text('No hay grabaciones disponibles'))
                : ListView.builder(
              itemCount: _recordings.length,
              itemBuilder: (context, index) {
                return AudioItemWidget(
                  name: _recordings[index]["name"]!,
                  url: _recordings[index]["url"]!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
