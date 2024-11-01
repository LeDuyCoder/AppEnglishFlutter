import 'dart:async';
import 'dart:math';

import 'package:appenglish/Module/readHive.dart';
import 'package:appenglish/Screen/splatScreen.dart';
import 'package:appenglish/local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

import 'package:flutter_background_service/flutter_background_service.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleSignIn googleSignIn = GoogleSignIn();

  await initializeService();
  await LocalNotifications.init();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );

  runApp(const MyApp());
}


Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: myTask,
        autoStart: true,
        isForegroundMode: false,
      ),
      iosConfiguration: IosConfiguration()
  );

}

void myTask(ServiceInstance service) async {
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );

  FirebaseAuth Authential = FirebaseAuth.instance;

  Timer.periodic(const Duration(seconds: 60), (timer) async {
    // get SharedPreferences to check time
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();

    for (String key in keys) {
      if (key.startsWith('${FirebaseAuth.instance.currentUser!.uid}.time.')) {
        int? value = prefs.getInt(key);

        // check time store in SharedPreferences
        if (value != null && (Timestamp.now().seconds - value >= 60)) {
          print(key);
          // get data vocabulary from Hive
          dynamic dataListVocabularyTopic = await ReadHive().readDataLearnedTopic(
            await ReadHive().getHivePath(),
            "havevocabulary",
            FirebaseAuth.instance,
            key.split(".")[2], // get topic from key
          );

          int amount = dataListVocabularyTopic.length;
          LocalNotifications.showSimpleNotification(
            title: "Learn Vocabulary",
            body: "You have $amount vocabulary need to learn in topic ${key.split(".")[2]}",
            payload: "exam-${key.split(".")[2]}",
            Id: Timestamp.now().seconds + Random().nextInt(99), // Sử dụng thời gian hiện tại làm ID
          );
          // if(amount >= 1) {
          //   //show notification
          //
          // }
        }
      }
    }
  });

}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: splatScreen(),
      routes: {
        '/home': (context) => splatScreen(), // Đường dẫn đến màn hình chính
      },
    );
  }
}