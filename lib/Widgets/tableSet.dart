import 'dart:async';

import 'package:appenglish/Module/word.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Screen/ScreenEdit.dart';

class tableSet extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _tableSet();

  final List<Word> listData;

  const tableSet({super.key, required this.listData});

}

class _tableSet extends State<tableSet> {

  int timeLeft = 5;

  void startTimer() {
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pop();
    });
  }



  void DialogReFix(Word elementWorld){
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) =>
          ScreenEdit(
            elementWorld: elementWorld,
            updateWord: (oldWord, newWord){
              setState(() {
          var position = widget.listData.indexOf(oldWord);
          widget.listData.remove(oldWord);
          widget.listData.insert(position, newWord);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                "Update word success",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );

          startTimer();
        });
             },
            removeWord: (oldWord){
              setState(() {
                widget.listData.remove(oldWord);
              });
            },
          ))
    );
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem listData có khác null và không rỗng không
    if (widget.listData.isNotEmpty) {
      return Container(
        height: 350,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('Word')),
                DataColumn(label: Text("PhonicUS")),
                DataColumn(label: Text("PhonicUK")),
                DataColumn(label: Text('Means')),
                DataColumn(label: Text('Example')),
              ],
              rows: widget.listData.map((word) {
                return DataRow(
                  onLongPress: () {
                    DialogReFix(word);
                  },
                  cells: <DataCell>[
                    DataCell(Text(word.word)),
                    DataCell(Text(word.phonicUS)),
                    DataCell(Text(word.phonicUK)),
                    DataCell(Text(word.means)),
                    DataCell(Text(word.example)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      );
    } else {
      // Trường hợp listData là null hoặc rỗng
      return Center(
        child: Text('No data available'),
      );
    }
  }
}