import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/audio.dart';

class FirebaseAudioDataSource {
  final FirebaseStorage storage;

  FirebaseAudioDataSource(this.storage);

  Future<List<Audio>> getAudios() async {
    List<Audio> audioList = [];
    ListResult result = await storage.ref('audios').listAll();

    for (var item in result.items) {
      String url = await item.getDownloadURL();
      audioList.add(Audio(id: item.name, name: item.name, url: url));
    }
    return audioList;
  }

  Future<String?> uploadAudio(String filePath) async {
    String fileName = 'audios/${DateTime.now().millisecondsSinceEpoch}.aac';
    Reference ref = storage.ref().child(fileName);
    UploadTask uploadTask = ref.putFile(File(filePath));

    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}
