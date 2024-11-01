import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadHive{

  /// Reads data from the specified Hive box located at the provided path.
  /// Prints each key-value pair in the box to the console.
  void read(path, box) async{
    Hive.init(path);
    var dataUserLocal = await Hive.openBox(box);

    for (var key in dataUserLocal.keys) {
      print('$key : ${dataUserLocal.get(key)}');
    }
  }

  /// Gets the path for the Hive database.
  /// Returns the application documents directory path as a string.
  Future<String> getHivePath() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String hivePath = appDocDir.path;
    return hivePath;
  }


  /// Reads learned vocabulary data for a specific topic from SharedPreferences.
  /// Returns a list of vocabulary words that have been learned for the specified topic.
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

    return ListVocabularyHaveLearn;
  }

  /// Writes learned vocabulary data for a specific topic to SharedPreferences.
  /// Updates existing vocabulary for the topic or creates a new entry if it doesn't exist.
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


        prefs.setString(UIDToken.currentUser!.uid, json.encode(DataUser));
      }else{
        DataUser["vocabularyList"][Topic] = ListVocabularyHaveLearn;
        print(DataUser);
        prefs.setString(UIDToken.currentUser!.uid, json.encode(DataUser));
      }
    }else{
      Map<dynamic, dynamic> Datas = {
        "vocabularyList": {
          Topic: ListVocabularyHaveLearn
        },
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

  /// Closes the Hive database and clears the specified box.
  Future<void> closeHive() async{
    Box box = await getBox(await getHivePath(), "havevocabulary");
    await box.clear();
    await box.close();
    Box box2 = await getBox(await getHivePath(), "havevocabulary");
    await box2.close();
  }
}

