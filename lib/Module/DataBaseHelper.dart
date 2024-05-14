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

  Future<bool> isData(String TokenUID) async {
    final db = await initDB();

    // Thực hiện truy vấn SQL để kiểm tra xem có bản ghi nào trong cơ sở dữ liệu có cột UUID như TokenUID đã cung cấp hay không
    var result = await db.query(
      'AccountUSer', // Tên bảng
      where: 'tokenUID = ?', // Điều kiện: cột UUID bằng TokenUID được cung cấp
      whereArgs: [TokenUID], // Giá trị của đối số ? trong điều kiện where
    );

    // Nếu kết quả truy vấn trả về ít nhất một dòng, tức là đã tìm thấy dữ liệu cho UUID đã cung cấp
    return result.isNotEmpty;
  }

  Future<void> addVocabulary(List<Word> data, String nameSet) async {
    final db = await initDB();
    try {
      for (var element in data) {
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
          "level": 0,
        });
      }
    } finally {
      db.close();
    }
  }

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
      return result[0];
    }
  }

  Future<void> insertFirends(Map<String, String> dataFirends) async{
    final db = await initDB();

    await db.insert(
      'ListFriends',
      {
        'tokenUID': dataFirends['tokenUID'],
        'title': dataFirends['title'],
        'linkImag': dataFirends['linkImag']
      },
    );

    db.close();
  }
  
  Future<void> removeFriend(String UUID_Friend) async {
    final db = await initDB();
    await db.delete(
      'ListFriends',
      where: 'tokenUID = $UUID_Friend',
    );
  }



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

    // Đóng cơ sở dữ liệu sau khi tất cả các thao tác hoàn thành
    await db.close();

    await Future.forEach(dataHandles.entries, (entry) async {
      String word = entry.key;
      int level = entry.value;

      await FirebaseFirestore.instance.collection("users").doc(tokenUID).collection("VocabularyData").doc(topic).collection("listVocabulary").doc(word).update({"level": level < 6 ? level + 1 : level});
    });
  }

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


  // Future<void> insetListBook(List<Book> books) async {
  //   final db = await initDB();
  //   // Get a reference to the database.
  //
  //   for (var book in books) {
  //
  //     List<Map<String, dynamic>> result = await db.query(
  //       'Books',
  //       where: 'ID = ?',
  //       whereArgs: [book.ID],
  //     );
  //
  //     if (result.isNotEmpty) {
  //       // Nếu sách đã tồn tại, thực hiện cập nhật thông tin sách
  //       await db.update(
  //         'Books',
  //         book.toMap(),
  //         where: 'ID = ?',
  //         whereArgs: [book.ID],
  //       );
  //     } else {
  //       // Nếu sách chưa tồn tại, thực hiện thêm mới
  //       await db.insert('Books', book.toMap());
  //     }
  //   }
  // }

  // Future<void> removeItem(Book book) async {
  //   final db = await initDB();
  //   await db.delete(
  //     "Books",
  //     where: 'ID = ?',
  //     whereArgs: [book.ID],
  //   );
  // }

  // Future<List<Book>> GetAllData() async {
  //   final db = await initDB();
  //   List<Map<String, dynamic>> result = await db.query('Books');
  //
  //   // Chuyển đổi danh sách Map sang danh sách Book
  //   List<Book> books = [];
  //   for (var item in result) {
  //     books.add(Book(
  //       ID: item['ID'],
  //       Name: item['Name'],
  //       Decription: item['Decription'],
  //       imageData: item['imageData'],
  //     ));
  //   }
  //
  //   return books;
  // }
}