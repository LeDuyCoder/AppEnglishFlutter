import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadHive{
  void read(path, box) async{
    // Khởi tạo Hive với đường dẫn được cung cấp
    Hive.init(path);
    var dataUserLocal = await Hive.openBox(box);

    for (var key in dataUserLocal.keys) {
      print('$key : ${dataUserLocal.get(key)}');
    }
  }

  Future<String> getHivePath() async {
    // Lấy thư mục lưu trữ của ứng dụng trên thiết bị
    Directory appDocDir = await getApplicationDocumentsDirectory();
    // Xác định đường dẫn đến thư mục Hive trong thư mục lưu trữ của ứng dụng
    String hivePath = appDocDir.path;
    return hivePath;
  }


  Future<List<String>> readDataLearnedTopic(String path, String box, FirebaseAuth UIDToken, String Topic) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> ListVocabularyHaveLearn = [];
    if(prefs.containsKey(UIDToken.currentUser!.uid)){
      String? dataJson = prefs.getString(UIDToken.currentUser!.uid);
      Map<dynamic, dynamic> DataVocabularyUser = json.decode(dataJson!);
      if(DataVocabularyUser["vocabularyList"].containsKey(Topic)){
        var DataVocabularyList = await DataVocabularyUser["vocabularyList"][Topic];
        for(var data in DataVocabularyList){
          ListVocabularyHaveLearn.add(data);
        }
      }
    }


    // Hive.init(path);
    //
    //
    //
    // var boxData = await Hive.openBox(box);
    //
    // if (!boxData.isOpen) {
    //   await Hive.openBox(box);
    // }
    //
    // if(boxData.containsKey(UIDToken.currentUser!.uid)){
    //   Map<dynamic, dynamic> DataVocabularyUser = boxData.get(UIDToken.currentUser!.uid);
    //   Map<dynamic, dynamic> DataVocabularyList = DataVocabularyUser["vocabularyList"];
    //   ListVocabularyHaveLearn.addAll(DataVocabularyList[Topic]);
    // }
    return ListVocabularyHaveLearn;

  }

  Future<void> writeHive(String path, String box, FirebaseAuth UIDToken, List<String> ListVocabularyHaveLearn, String Topic) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey(UIDToken.currentUser!.uid)){
      String? jsonData = prefs.getString(UIDToken.currentUser!.uid);
      Map<dynamic, dynamic> DataUser = json.decode(jsonData!);
      if(DataUser["vocabularyList"].containsKey(Topic)) {
        List<String> DataVocabularyTopic = List<String>.from(
            DataUser["vocabularyList"][Topic]);

        DataVocabularyTopic.removeWhere((element) =>
        !ListVocabularyHaveLearn.contains(element));

        ListVocabularyHaveLearn.forEach((element) {
          if (!DataVocabularyTopic.contains(element)) {
            DataVocabularyTopic.add(element);
          }
        });

        DataUser["vocabularyList"][Topic] = DataVocabularyTopic;

        if(DataUser["time"].containsKey(Topic)){
          DataUser["time"][Topic] = Timestamp.now().seconds;
        }

        prefs.setString(UIDToken.currentUser!.uid, json.encode(DataUser));
      }else{
        DataUser["vocabularyList"][Topic] = ListVocabularyHaveLearn;
        DataUser['time'][Topic] = Timestamp.now().seconds;
        print(DataUser);
        prefs.setString(UIDToken.currentUser!.uid, json.encode(DataUser));
      }
    }else{
      Map<dynamic, dynamic> Datas = {
        "vocabularyList": {
          Topic: ListVocabularyHaveLearn
        },
        "time": {
          Topic: Timestamp.now().seconds,
        }
      };

      prefs.setString(UIDToken.currentUser!.uid, jsonEncode(Datas));
    }
  }

  Future<Box> getBox(String path, String box) async {
    var boxData = await Hive.openBox(box);
    if (!boxData.isOpen) {
      await Hive.openBox(box);
    }

    return boxData;
  }

  Future<void> closeHive() async{
    Box box = await getBox(await getHivePath(), "havevocabulary");
    await box.clear();
    await box.close();
    Box box2 = await getBox(await getHivePath(), "havevocabulary");
    await box2.close();
  }

  Future<Map<String, dynamic>> getAllTime(String path, String box, FirebaseAuth UIDToken) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if(prefs.containsKey(UIDToken.currentUser!.uid)) {
      var datas = prefs.getString(UIDToken.currentUser!.uid);
      var dataUser = await json.decode(datas!);
      return Future<Map<String, dynamic>>.value(dataUser["time"]!);
    }else{
      return {};
    }

    Hive.init(path);
    var boxData = await Hive.openBox(box);

    if (!boxData.isOpen) {
      await Hive.openBox(box);
    }

    var data = await boxData.get(UIDToken.currentUser!.uid);
    var dataResult = data["time"];
    return Future<Map<String, int>>.value(dataResult);
  }

  Future<Map<dynamic, dynamic>> getAllTimeService(FirebaseAuth UIDToken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey(UIDToken.currentUser!.uid)) {
      var datas = prefs.getString(UIDToken.currentUser!.uid);
      Map<dynamic, dynamic> dataUser = json.decode(datas!);
      return dataUser["time"];
    }else{
      return {};
    }
  }

  Future<void> writeTime(String path, String box, FirebaseAuth UIDToken, String topic) async{
    String UUIDUser = UIDToken.currentUser!.uid;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dataJson = prefs.getString(UIDToken.currentUser!.uid);
    Map<dynamic, dynamic> DataUser = json.decode(dataJson!);
    DataUser["time"][topic] = Timestamp.now().seconds;
    print(DataUser);
    await prefs.setString(UUIDUser, json.encode(DataUser));
  }
}

