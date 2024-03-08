import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataBaseHelper {
  final databaseName = "DataBaseBook.db";
  final noteTable = "CREATE TABLE Books (ID INTEGER, Name TEXT NOT NULL, Decription TEXT not null, imageData BLOB not null)";

  Future<Database> initDB() async{
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);
    print(path);
    return openDatabase(path, version: 1, onCreate: (db, version) async{
      await db.execute(noteTable);
    });
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