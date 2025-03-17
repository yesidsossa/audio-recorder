import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadNotifier extends StateNotifier<double> {
  UploadNotifier() : super(0.0);

  Future<String?> uploadToFirebase(File file) async {
    try {
      // 🚀 Verificar si Firebase está inicializado antes de usarlo
      if (Firebase.apps.isEmpty) {
        print("🔥 Firebase no estaba inicializado. Inicializando...");
        await Firebase.initializeApp();
      }

      String fileName = 'audios/${DateTime.now().millisecondsSinceEpoch}.aac';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(file);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        state = snapshot.bytesTransferred / snapshot.totalBytes;
        print("📤 Subiendo: ${state * 100}% completado");
      });

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("✅ Archivo subido a Firebase: $downloadUrl");

      return downloadUrl;
    } catch (e) {
      print("🚨 Error subiendo a Firebase: $e");
      return null;
    }
  }
}

final uploadProvider = StateNotifierProvider<UploadNotifier, double>(
      (ref) => UploadNotifier(),
);
