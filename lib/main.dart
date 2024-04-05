import 'dart:async';

import 'package:appenglish/Module/readHive.dart';
import 'package:appenglish/Screen/mainScreen.dart';
import 'package:appenglish/Screen/splatScreen.dart';
import 'package:appenglish/local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration());
}

void myTask(ServiceInstance service) async {
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );

  FirebaseAuth Authential = FirebaseAuth.instance;
  Timer.periodic(const Duration(seconds: 60), (timer) async {
    Map<dynamic, dynamic> dataTimeUser = await ReadHive().getAllTimeService(FirebaseAuth.instance);

    dataTimeUser.forEach((key, value) async {
      if(Timestamp.now().seconds - value >= 6300){
         dynamic dataListVocabularyTopic = await ReadHive().readDataLearnedTopic((await ReadHive().getHivePath()), "havevocabulary", FirebaseAuth.instance, key);
         int amount = dataListVocabularyTopic.length;
         LocalNotifications.showSimpleNotification(title: "Learn Vocabulary",
             body: "You have $amount vocabulary need learn",
             payload: "examp-${key}", Id: Timestamp.now().seconds);
      }else{
        print("ok");
      }


    });
  });
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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