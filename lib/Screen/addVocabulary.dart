import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:appenglish/Module/DataBaseHelper.dart';
import 'package:appenglish/Module/meanWord.dart';
import 'package:appenglish/Module/word.dart';
import 'package:appenglish/Widgets/bodyDialog.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

enum statusAddVoca  {
  Waiting,
  Success,
  Error,
}

class addVocabulary extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _addVocabulary();

  var linkImages = null;
  var name_vocabulary = null;
  List<Word> listWord = [];
  var wordNew = "";
  var isLoading = false;
  var amount = 0;
}

class _addVocabulary extends State<addVocabulary>{
  final _form = GlobalKey<FormState>();
  Completer<bool> completer = Completer<bool>();

  void updateImages() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery, // Chọn từ thư viện ảnh của thiết bị
      );

      if (pickedFile != null) {
        final filePath = pickedFile.path;
        setState(() {
          widget.linkImages = filePath;
        });
        // Xử lý tệp hình ảnh đã chọn ở đây
      }
    } catch (e) {
      print('Lỗi: $e');
    }
  }

  meanWord? hanldTypeword(Map<String, dynamic> value){
    for(var type in value.keys){
      for(var time in value[type]){
        if((time as Map).containsKey("example")){
          return meanWord(definition: (time as Map)["definition"], example: (time as Map)["example"], type: type);
        }
      }
    }

    return null;
  }

  bool isInEnum(String value) {
    return Typeword.values.map((e) => e.toString().split('.').last).contains(value);
  }

  Typeword getEnumValue(String name) {
    for (var enumValue in Typeword.values) {
      if (enumValue.toString().split('.').last == name) {
        return enumValue;
      }
    }
    throw Exception("Không tìm thấy giá trị enum cho chuỗi '$name'");
  }

  void addData(data, word){

    print(word);
    widget.listWord.add(

        ((data[0] as Map)["phonetics"] as List).length <= 2 ? Word(
            word: word,
            type: hanldTypeword((data[0] as Map)["meaning"]) == null ? Typeword.undefined : getEnumValue(hanldTypeword((data[0] as Map)["meaning"])!.type),
            linkUK: (data[0] as Map)["phonetics"][0]["audio"],
            linkUS: ((data[0] as Map)["phonetics"] as List).length == 2 ? (data[0] as Map)["phonetics"][1]["audio"] : (data[0] as Map)["phonetics"][0]["audio"],
            phonicUK: (data[0] as Map)["phonetics"][0]["text"],
            phonicUS: ((data[0] as Map)["phonetics"] as List).length == 2 ? (data[0] as Map)["phonetics"][1]["text"] : (data[0] as Map)["phonetics"][0]["text"],
            means: hanldTypeword((data[0] as Map)["meaning"]) != null ? hanldTypeword((data[0] as Map)["meaning"])!.definition : "",
            example: hanldTypeword((data[0] as Map)["meaning"]) != null ? hanldTypeword((data[0] as Map)["meaning"])!.example : ""
        ):Word(
            word: word,
            type: hanldTypeword((data[0] as Map)["meaning"]) == null ? Typeword.undefined : getEnumValue(hanldTypeword((data[0] as Map)["meaning"])!.type),
            linkUK: (data[0] as Map)["phonetics"][1]["audio"],
            linkUS: (data[0] as Map)["phonetics"][2]["audio"],
            phonicUK: (data[0] as Map)["phonetics"][1]["text"],
            phonicUS: (data[0] as Map)["phonetics"][2]["text"],
        means: hanldTypeword((data[0] as Map)["meaning"]) != null ? hanldTypeword((data[0] as Map)["meaning"])!.definition : "",
        example: hanldTypeword((data[0] as Map)["meaning"]) != null ? hanldTypeword((data[0] as Map)["meaning"])!.example : ""
        )
    );

    print(widget.listWord.length);
  }

   Future<statusAddVoca> CallDialogError(_formMini, word) async {
     Completer<statusAddVoca> completer = Completer<statusAddVoca>();
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      body: Center(
        child: Column(
          children: [
            const Text("Word don\'t found", style: TextStyle(fontSize: 25),),
            Form(
                key: _formMini,
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: word,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15), // Điều chỉnh khoảng cách giữa nội dung và viền
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  validator: (value){
                    if(value!.trim().isEmpty || containsSpecialCharacters(value.trim())){
                      return "Vocabulary not valid";
                    }

                    setState(() {
                      widget.wordNew = value;
                    });
                  },
                )
            ),
          ],
        ),
      ),
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        final isValid = _formMini.currentState!.validate();
        if (isValid) {
          _formMini.currentState!.save();
          completer.complete(statusAddVoca.Success);
        }
      },
    ).show();

    return completer.future;
  }

  Future<bool> callAPI(String word) async {
    try {
      final response = await http.get(Uri.parse('https://api.dictionaryapi.dev/api/v1/entries/en/$word'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        addData(data, word);
        return true;
      } else {
        final _formMini = GlobalKey<FormState>();
        var dataResult = await CallDialogError(_formMini, word);
        if(dataResult == statusAddVoca.Success){
          return true;
        }else{
          return false;
        }
      }
    } catch (error) {
      // Xử lý lỗi
      print('Error: $error');
      return false;
    }
  }

  void onCallback(bool success) {
    completer.complete(success);
  }

  void hanldWord(String valueText) async {
    var listWord = valueText.split("\n");
    bool allCallsSuccessful = false;
    for (var word in listWord) {
      var success = await callAPI(word);
      if (success) {
        allCallsSuccessful = true;
      }
    }


    if (allCallsSuccessful) {
      print(widget.listWord.length);

      await DataBaseHelper().insetDataVocabulary(widget.listWord, widget.name_vocabulary);

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Success',
        btnOkOnPress: () {
          setState(() {
            widget.isLoading = false;
          });
        },
      ).show();
    }
  }

  bool containsSpecialCharacters(String input) {
    RegExp specialCharRegex = RegExp(r'[^\w\s]');
    return specialCharRegex.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme.copyWith(
          color: Colors.white
        ),
        backgroundColor: const Color.fromRGBO(0, 42, 160, 1.0),
        title: const Text("Create Box Word", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
      ),
      body: Stack(
        children: [
          Container(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                child: Form(
                  key: _form,
                  child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(left: 20, right: 20, top: 50),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    updateImages();
                                  },
                                  child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.white, // Màu nền của button
                                        borderRadius: BorderRadius.circular(10), // Đặt góc bo tròn
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5), // Màu của bóng đổ
                                            spreadRadius: 5, // Bán kính lan rộng của bóng đổ
                                            blurRadius: 7, // Độ mờ của bóng đổ
                                            offset: Offset(0, 3), // Độ lệch của bóng đổ theo chiều dọc
                                          ),
                                        ],
                                      ),
                                      child: widget.linkImages == null ? Image.asset("assets/images/image_vocabulary.png", scale: 0.9,) : ClipRRect(
                                        borderRadius: BorderRadius.circular(10), // Đặt góc bo tròn
                                        child: Image.file(
                                          File(widget.linkImages),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                  ),
                                ),
                                const SizedBox(width: 20,),
                                Expanded(
                                    child: TextFormField(
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        hintText: 'Name Set Vocabulary',
                                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15), // Điều chỉnh khoảng cách giữa nội dung và viền
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                      ),
                                      validator: (value){
                                        if(value!.trim().isEmpty || containsSpecialCharacters(value.trim())){
                                          return "Name set vocabulary not valid";
                                        }

                                        widget.name_vocabulary = value;
                                      },
                                    )
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: 250, // Độ cao của ô nhập liệu
                              decoration: BoxDecoration(
                                border: Border.all(width: 1), // Độ dày của viền
                                borderRadius: BorderRadius.circular(20), // Độ cong của góc
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.multiline,
                                maxLines: null, // Để cho phép nhập nhiều dòng
                                textAlignVertical: TextAlignVertical.top, // Căn chữ bắt đầu từ trên cùng
                                decoration: const InputDecoration(
                                  hintText: "Add word here. every word you only enter\nfor example\n\nmother\nfather\n\nNode:\nevery box min limit is 20 word",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none, // Ẩn viền bên trong của ô nhập liệu
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10), // Phần lề bên trong
                                ),
                                validator: (value){
                                  if(value!.trim().isEmpty){
                                    return "list word of set vocabulary not valid";
                                  }
                                  hanldWord(value);
                                },
                              ),
                            ),
                            SizedBox(height: 50,),
                            ElevatedButton(
                              onPressed: () {
                                final isValid = _form.currentState!.validate();
                                if(isValid){
                                  _form.currentState!.save();
                                }

                                setState(() {
                                  widget.isLoading = true;
                                });

                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue, // Màu nền của nút
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50), // Đặt góc bo tròn
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 12),
                              ),
                              child: const Text('Submit', style: TextStyle(color: Colors.white),),
                            )
                          ],
                        ),
                      )
                  ),
                ),
              )
          ),
          widget.isLoading == true ? Stack(
            children: [
              // Container full màn hình trong suốt
              Opacity(
                opacity: 0.5, // Độ đục của container, giá trị từ 0 đến 1
                child: Container(
                  color: Colors.black, // Màu của container
                ),
              ),
              // Vòng tròn loading chính giữa màn hình
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ) : Center()
        ],
      ),
    );
  }

}