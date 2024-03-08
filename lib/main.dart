import 'package:appenglish/Screen/mainScreen.dart';
import 'package:appenglish/Screen/splatScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleSignIn googleSignIn = GoogleSignIn();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: splatScreen(),
      routes: {
        '/home': (context) => splatScreen(), // Đường dẫn đến màn hình chính
      },
    );
  }
}