import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:appenglish/Module/readHive.dart';
import 'package:appenglish/Screen/dasboardScreen.dart';
import 'package:appenglish/Screen/mainScreen.dart';
import 'package:appenglish/Screen/splatScreen.dart';
import 'package:appenglish/local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lifecycle/lifecycle.dart';
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
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration());
}

void myTask(ServiceInstance service) async {
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );


  FirebaseAuth Authential = FirebaseAuth.instance;

  bool isWithinSpecificTime(DateTime time) {
    // Đặt thời gian bắt đầu và kết thúc của khoảng thời gian quy định
    DateTime startTime = DateTime(time.year, time.month, time.day, 17, 0, 0); // 0 giờ
    DateTime endTime = DateTime(time.year, time.month, time.day, 18, 0, 0); // 3 giờ 52 phút

    return time.isAfter(startTime) && time.isBefore(endTime);
  }

  Timer.periodic(Duration(seconds: 1), (timer) async {
    DateTime now = DateTime.now();
    if (Authential.currentUser != null && isWithinSpecificTime(now)) {
      if (now.minute == 44 && now.second == 0) {
        print("fuck lỗi kìa");
        print(dasboardScreen.time_online);
        if (dasboardScreen.time_online != 0) {
          print("check");
          // await FirebaseFirestore.instance.collection("users").doc(
          //     Authential.currentUser!.uid).collection("dataAccount")
          //     .doc("data")
          //     .update({'time_online': dasboardScreen.time_online});
        }
      }
    }
  });

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
      navigatorObservers: [defaultLifecycleObserver],
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