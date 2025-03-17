import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'presentation/screens/audio_recorder_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await _requestPermissions();

  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _requestPermissions() async {
  PermissionStatus status = await Permission.microphone.status;

  if (status.isDenied || status.isRestricted) {
    status = await Permission.microphone.request();

    if (status.isDenied) {
      print("❌ Permiso aún denegado, intentando de nuevo...");
      status = await Permission.microphone.request();
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Recorder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AudioRecorderScreen(),
    );
  }
}
