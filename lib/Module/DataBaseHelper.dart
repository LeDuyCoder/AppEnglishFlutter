import 'package:appenglish/Module/word.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataBaseHelper {
  final databaseName = "DataAppEnglish.db";
  final noteTableAccount = "CREATE TABLE 'AccountUSer' ( 'mail'	TEXT NOT NULL, 'tokenUID'	TEXT NOT NULL, PRIMARY KEY('tokenUID'))";
  final noteTableVocabularyList = "CREATE TABLE 'VocabularyList' ('tokenUID'	TEXT NOT NULL, 'nameSet'	TEXT NOT NULL, 'word' TEXT NOT NULL, 'type'	TEXT NOT NULL, 'linkUS'	TEXT NOT NULL, 'linkUK'	TEXT NOT NULL, 'phonicUS'	TEXT NOT NULL, 'phonicUK'	TEXT NOT NULL, 'means'	TEXT NOT NULL, 'example'	TEXT NOT NULL, FOREIGN KEY ('tokenUID') REFERENCES 'AccountUser' ('tokenUID'))";
  final AuthenticanUser = FirebaseAuth.instance;

  Future<Database> initDB() async{
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);
    return openDatabase(path, version: 1, onCreate: (db, version) async{
      await db.execute(noteTableAccount);
      await db.execute(noteTableVocabularyList);
    });
  }


  Future<void> insetDataVocabulary(List<Word> data, String nameSet) async{
    final db = await initDB();

    await db.transaction((txn) async {
      Batch batch = txn.batch();
      data.forEach((word) {
        batch.rawInsert(
            'INSERT INTO VocabularyList (tokenUID, nameSet, word, type, linkUS, linkUK, phonicUS, phonicUK, means, example) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
              AuthenticanUser.currentUser!.uid,
              nameSet,
              word.word,
              word.type.name,
              word.linkUS,
              word.linkUK,
              word.phonicUS,
              word.phonicUK,
              word.means,
              word.example]);
      });

      // Thực hiện thêm dữ liệu bằng batch
      await batch.commit();
    });

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