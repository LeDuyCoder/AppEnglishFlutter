import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class bodyDialog extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _bodyDialog();

  String word;

  bodyDialog({super.key, required this.word});

}

class _bodyDialog extends State<bodyDialog>{
  final _formMini = GlobalKey<FormState>();

  bool containsSpecialCharacters(String input) {
    RegExp specialCharRegex = RegExp(r'[^\w\s]');
    return specialCharRegex.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {

    var _wordNew = "";

    return Column(
      children: [
        Text("Word don\'t found", style: TextStyle(fontSize: 25),),
        Center(
            child: Form(
              key: _formMini,
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: widget.word,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15), // Điều chỉnh khoảng cách giữa nội dung và viền
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                validator: (value){
                  if(value!.trim().isEmpty || containsSpecialCharacters(value)) {
                    return "vocabulary not valid";
                  }

                  setState(() {

                  });
                },
              ),
            )
        )
      ],
    );
  }

}