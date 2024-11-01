import 'package:appenglish/Module/word.dart';
import 'package:appenglish/Screen/addVocabulary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataBaseHelper {
  final databaseName = "DataAppEnglish.db";
  final noteTableAccount = "CREATE TABLE 'AccountUSer' ( 'mail'	TEXT NOT NULL, 'tokenUID'	TEXT NOT NULL, PRIMARY KEY('tokenUID'))";
  final noteTableVocabularyList = "CREATE TABLE 'VocabularyList' ('tokenUID'	TEXT NOT NULL, 'nameSet' TEXT NOT NULL)";
  final noteTableListVocabulary = "CREATE TABLE 'LisVoc' ('tokenUID'	TEXT NOT NULL, 'nameSet' TEXT NOT NULL, 'word' TEXT NOT NULL, 'type' TEXT NOT NULL, 'linkUS' TEXT NOT NULL, 'linkUK' TEXT NOT NULL, 'phonicUS' TEXT NOT NULL, 'phonicUK' TEXT NOT NULL, 'mean' TEXT NOT NULL, 'example' TEXT NOT NULL, 'level' INTEGER NOT NULL)";
  final noteTableListFriends = "CREATE TABLE 'ListFriends' ('tokenUID'	TEXT NOT NULL, 'title' TEXT NOT NULL, 'linkImag' TEXT NOT NULL)";
  final AuthenticanUser = FirebaseAuth.instance;

  /// Initializes the database and creates necessary tables if they do not already exist.
  Future<Database> initDB() async{
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);
    return openDatabase(path, version: 1, onCreate: (db, version) async{
      await db.execute(noteTableAccount);
      await db.execute(noteTableVocabularyList);
      await db.execute(noteTableListVocabulary);
      await db.execute(noteTableListFriends);
    });
  }

  /// Checks if a record with the specified `TokenUID` exists in the `AccountUSer` table.
  Future<bool> isData(String TokenUID) async {
    final db = await initDB();


    var result = await db.query(
      'AccountUSer',
      where: 'tokenUID = ?',
      whereArgs: [TokenUID],
    );

    return result.isNotEmpty;
  }

  /// Adds vocabulary to the `LisVoc` table. Updates the level if the word already exists.
  Future<void> addVocabulary(List<Word> data, String nameSet) async {
    final db = await initDB();
    try {
      for (var element in data) {
        // Kiểm tra xem từ đã tồn tại hay chưa
        List<Map<String, dynamic>> existingWords = await db.query(
          "LisVoc",
          where: "tokenUID = ? AND word = ?",
          whereArgs: [AuthenticanUser.currentUser!.uid, element.word],
        );

        if (existingWords.isNotEmpty) {
          // Từ đã tồn tại
          if (element.level != null) {
            // Cập nhật trường level nếu element.level khác null
            await db.update(
              "LisVoc",
              {"level": element.level},
              where: "tokenUID = ? AND word = ?",
              whereArgs: [AuthenticanUser.currentUser!.uid, element.word],
            );
          }
        } else {
          // Thêm từ mới vào cơ sở dữ liệu
          await db.insert("LisVoc", {
            "tokenUID": AuthenticanUser.currentUser!.uid,
            "nameSet": nameSet,
            "word": element.word,
            "type": element.type.name,
            "linkUS": element.linkUS,
            "linkUK": element.linkUK,
            "phonicUS": element.phonicUS,
            "phonicUK": element.phonicUK,
            "mean": element.means,
            "example": element.example,
            "level": element.level ?? 0,
          });
        }
      }
    } finally {
      await db.close();
    }
  }

  /// Retrieves a friend's data based on conditions provided in `arraycondition`.
  Future<Map<String, dynamic>> getDataFriend(Map<String, String> arraycondition) async{
    final db = await initDB();
    String conditions = '';
    var amount = 1;
    arraycondition.forEach((key, value) {
      if(amount == arraycondition.length){
        conditions += "$key = \'$value\' ";
      }else {
        conditions += '$key = \'$value\' AND ';
      }
      amount++;
    });
    List<Map<String, Object?>> result = await db.query("ListFriends", where: conditions);
    if(result.isEmpty){
      return {};
    }else {
      return Map<String, dynamic>.from(result[0]);
    }
  }

  /// Retrieves all data from a table based on conditions in `arraycondition`.
  Future<List<Map<String, dynamic>>> getAllData(tableName, Map<String, String> arraycondition) async{
    final db = await initDB();
    String conditions = '';
    var amount = 1;
    arraycondition.forEach((key, value) {
      if(amount == arraycondition.length){
        conditions += "$key = \'$value\' ";
      }else {
        conditions += '$key = \'$value\' AND ';
      }
      amount++;
    });
    List<Map<String, dynamic>> result = await db.query(tableName, where: conditions);
    return result;
  }

  /// Updates the level of words in `LisVoc` and synchronizes with Firebase Firestore.
  Future<void> updateData(List<String> datasWord, FirebaseAuth auth, String topic) async {
    final db = await initDB();
    String tokenUID = FirebaseAuth.instance.currentUser!.uid;
    Map<String, int> dataHandles = {};
    List<Map<String, dynamic>> datas = await getAllData("LisVoc", {"tokenUID": auth.currentUser!.uid, "nameSet": topic});

    for (var element in datas) {
      if(datasWord.contains(element["word"])){
        dataHandles[element["word"]] = element["level"];
      }
    }

    await Future.forEach(dataHandles.entries, (entry) async {
      String word = entry.key;
      int level = entry.value;

      await db.update("LisVoc", {"level": level < 6 ? level + 1 : level}, where: "tokenUID = ? AND word = ?", whereArgs: [auth.currentUser!.uid, word]);
      await FirebaseFirestore.instance.collection("users").doc(tokenUID).collection("VocabularyData").doc(topic).collection("listVocabulary").doc(word).update({"level": level < 6 ? level + 1 : level});
    });

    await db.close();

    await Future.forEach(dataHandles.entries, (entry) async {
      String word = entry.key;
      int level = entry.value;

      await FirebaseFirestore.instance.collection("users").doc(tokenUID).collection("VocabularyData").doc(topic).collection("listVocabulary").doc(word).update({"level": level < 6 ? level + 1 : level});
    });
  }

  /// Inserts a new vocabulary set in the `VocabularyList` table.
  Future<void> insertSet(String nameSet) async{
    final db = await initDB();

    await db.insert(
      'VocabularyList',
      {
        'tokenUID': AuthenticanUser.currentUser!.uid,
        'nameSet': nameSet
      },
    );

    db.close();
  }

  /// Inserts account authentication data into `AccountUSer` table.
  Future<void> insertDataAuthentical(String email) async {
    final db = await initDB();

    await db.insert(
      'AccountUSer',
      {
        'mail': email,
        'tokenUID': AuthenticanUser.currentUser!.uid,
      },
    );

    db.close();
  }

  /// Checks if a set exists in the specified `tableName` based on `arraycondition`.
  Future<bool> hasSet(tableName, Map<String, String> arraycondition) async {
    final db = await initDB();
    String conditions = '';
    var amount = 1;
    arraycondition.forEach((key, value) {
      if(amount == arraycondition.length){
        conditions += "$key = \'$value\' ";
      }else {
        conditions += '$key = \'$value\' AND ';
      }
      amount++;
    });
    List<Map<String, dynamic>> result = await db.query(tableName, where: conditions);
    if(result.isEmpty){
      return false;
    }else{
      return true;
    }
  }
}