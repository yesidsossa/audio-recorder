import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/audio.dart';
import '../../domain/datasources/audio_data_source.dart';

class FirebaseAudioDataSource implements AudioDataSource {
  final FirebaseStorage storage;

  FirebaseAudioDataSource(this.storage);

  @override
  Future<List<Audio>> getAudios() async {
    List<Audio> audioList = [];
    ListResult result = await storage.ref('audios').listAll();

    for (var item in result.items) {
      String url = await item.getDownloadURL();
      audioList.add(Audio(id: item.name, name: item.name, url: url));
    }
    return audioList;
  }

  @override
  Future<String?> uploadAudio(String filePath) async {
    try {
      File file = File(filePath);

      if (!file.existsSync()) {
        print("🚨 Error: El archivo no existe en la ruta: $filePath");
        return null;
      }

      String fileName = 'audios/${DateTime.now().millisecondsSinceEpoch}.aac';
      Reference ref = storage.ref().child(fileName);

      // ✅ Agregar metadatos explícitos para evitar el error en Firebase
      SettableMetadata metadata = SettableMetadata(
        contentType: "audio/aac", // Especifica el tipo MIME
      );

      UploadTask uploadTask = ref.putFile(file, metadata);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("✅ Archivo subido correctamente: $downloadUrl");
      return downloadUrl;
    } catch (e, stacktrace) {
      print("🚨 Error al subir el archivo: $e");
      print("🛠️ Stacktrace: $stacktrace");
      return null;
    }
  }
}
