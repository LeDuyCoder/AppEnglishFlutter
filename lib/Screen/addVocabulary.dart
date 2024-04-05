import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:appenglish/Module/DataBaseHelper.dart';
import 'package:appenglish/Module/meanWord.dart';
import 'package:appenglish/Module/word.dart';
import 'package:appenglish/Widgets/tableSet.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;


enum statusAddVoca  {
  Waiting,
  Success,
  Error,
}

class addVocabulary extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _addVocabulary();

  final authentical = FirebaseAuth.instance;
  final db = DataBaseHelper();
  var localStorehive = null;

  var linkImages = null;
  var name_vocabulary = null;
  var StringListWord = "";
  List<Word> listWord = [];
  var wordNew = "";
  var isLoading = false;
  var amount = 0;
  var linkURLImages = "";
}

class _addVocabulary extends State<addVocabulary>{
  final _form = GlobalKey<FormState>();
  final storage = FirebaseStorage.instance;
  final dbStore = FirebaseFirestore.instance;

  Completer<bool> completer = Completer<bool>();

  @override

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

    var test = meanWord(definition: ((value[(value.keys).first] as List)[0] as Map)["definition"], example: "", type: value.keys.first);
    return test;
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


  Future<String> createExampleWord(String word) async {
    try {
      final response = await http.get(Uri.parse('https://api.urbandictionary.com/v0/define?term=${word}'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return ((data["list"] as List)[3] as Map)["example"];
      } else {
        return "";
      }
    } catch (error) {
      return "error";
    }
  }

  Future<void> addDataPhrasalPerb(data) async {
    widget.listWord.add(
        Word(
            word: ((data["list"] as List)[0] as Map)["word"],
            type: Typeword.phrasal_verb,
            linkUK: "",
            linkUS: "",
            phonicUK: "",
            phonicUS: "",
            means: ((data["list"] as List)[0] as Map)["definition"],
            example: ((data["list"] as List)[0] as Map)["example"]
        )
    );
  }

  void addData(data, String word) async {
    print(word);
    widget.listWord.add(
        ((data[0] as Map)["phonetics"] as List).length <= 2 ? Word(
            word: word,
            type: getEnumValue(
                hanldTypeword((data[0] as Map)["meaning"])!.type),
            linkUK: (data[0] as Map)["phonetics"][0]["audio"],
            linkUS: ((data[0] as Map)["phonetics"] as List).length == 2
                ? (data[0] as Map)["phonetics"][1]["audio"]
                : (data[0] as Map)["phonetics"][0]["audio"],
            phonicUK: (data[0] as Map)["phonetics"][0]["text"],
            phonicUS: ((data[0] as Map)["phonetics"] as List).length == 2
                ? (data[0] as Map)["phonetics"][1]["text"]
                : (data[0] as Map)["phonetics"][0]["text"],
            means: hanldTypeword((data[0] as Map)["meaning"]) != null
                ? hanldTypeword((data[0] as Map)["meaning"])!.definition
                : "",
            example: hanldTypeword((data[0] as Map)["meaning"]) != null
                ? hanldTypeword((data[0] as Map)["meaning"])!.example
                : (await createExampleWord(word))
        ) : Word(
            word: word,
            type: getEnumValue(
                hanldTypeword((data[0] as Map)["meaning"])!.type),
            linkUK: (data[0] as Map)["phonetics"][1]["audio"],
            linkUS: (data[0] as Map)["phonetics"][2]["audio"],
            phonicUK: (data[0] as Map)["phonetics"][1]["text"],
            phonicUS: (data[0] as Map)["phonetics"][2]["text"],
            means: hanldTypeword((data[0] as Map)["meaning"]) != null
                ? hanldTypeword((data[0] as Map)["meaning"])!.definition
                : "",
            example: hanldTypeword((data[0] as Map)["meaning"]) != null
                ? hanldTypeword((data[0] as Map)["meaning"])!.example
                : (await createExampleWord(word))
        )
    );

  }

  void updateVocabularyToFirebase(){
    widget.listWord.forEach((element) {
      dbStore.collection("users").doc(widget.authentical.currentUser!.uid).collection("VocabularyData").doc(widget.name_vocabulary).collection("listVocabulary").doc(element.word).set(
          {
            "word": element.word,
            "type": element.type.name,
            "linkUS": element.linkUS,
            "linkUK": element.linkUK,
            "phonicUS": element.phonicUS,
            "phonicUK": element.phonicUK,
            "mean": element.means,
            "example": element.example,
            "level": 0,
          }
      );
      dbStore.collection("users").doc(widget.authentical.currentUser!.uid).collection("VocabularyData").doc(widget.name_vocabulary).set({
        "image": widget.linkURLImages
      });
    });
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

          if(widget.wordNew != ""){
            var recall = callAPI(widget.wordNew);
            if(await recall){
              completer.complete(statusAddVoca.Success);
            }else{
              completer.complete(statusAddVoca.Error);
            }
          }
        }
      },
    ).show();

    return completer.future;
  }

  int countNonSpaceWords(String input) {
    List<String> words = input.split(" ");
    int nonSpaceWordCount = 0;
    for (String word in words) {
      if (!word.contains(" ")) {
        nonSpaceWordCount++;
      }
    }

    return nonSpaceWordCount;
  }

  Future<bool> callAPI(String word) async {
    if(countNonSpaceWords(word) >= 2){
      try {
        final response = await http.get(
            Uri.parse('https://api.urbandictionary.com/v0/define?term=$word'));
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          var sizeData = (data["list"] as List).length;
          if(sizeData >= 1){
            addDataPhrasalPerb(data);
            return true;
          }else{
            final _formMini = GlobalKey<FormState>();
            var dataResult = await CallDialogError(_formMini, word);
            if (dataResult == statusAddVoca.Success) {
              return true;
            } else {
              return callAPI(widget.wordNew);
            }
          }
        } else {
          final _formMini = GlobalKey<FormState>();
          var dataResult = await CallDialogError(_formMini, word);
          if (dataResult == statusAddVoca.Success) {
            return true;
          } else {
            return callAPI(widget.wordNew);
          }
        }
      } catch (error) {
        print('Error: $error');
        return false;
      }
    }else{
      try {
        final response = await http.get(
            Uri.parse('https://api.dictionaryapi.dev/api/v1/entries/en/$word'));
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          addData(data, word);
          return true;
        } else {
          final _formMini = GlobalKey<FormState>();
          var dataResult = await CallDialogError(_formMini, word);
          if (dataResult == statusAddVoca.Success) {
            return true;
          } else {
            return callAPI(widget.wordNew);
          }
        }
      } catch (error) {
        print('Error: $error');
        return false;
      }
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
        continue;
      }
    }


    if (allCallsSuccessful) {
      //await widget.db.insetDataVocabulary(widget.listWord, widget.name_vocabulary);
      //updateVocabularyToFirebase();

      DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(widget.authentical.currentUser!.uid).collection("dataAccount").doc("data");
      DocumentSnapshot docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        dynamic fieldValue = docSnapshot.data()!;
        docRef.update({
          "amount_vocabulary_list": fieldValue["amount_vocabulary_list"] + 1
        });
      } else {
        print('Tài liệu không tồn tại.');
      }


      AwesomeDialog(
        context: context,
        dialogType: DialogType.noHeader,
        animType: AnimType.scale,
        dismissOnTouchOutside: false,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text("Data Your Set", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
            ),
            const Text("NOTE ⚠:\ncheck again before submit please\nif you want edit let to long press", style: TextStyle(color: Colors.grey),),
            SizedBox(height: 10,),
            tableSet(listData: (widget.listWord)!)
          ],
        ),
        btnOkOnPress: () async {
          await DataBaseHelper().insertSet(widget.name_vocabulary);
          await DataBaseHelper().addVocabulary(widget.listWord, widget.name_vocabulary);
          updateVocabularyToFirebase();
          Navigator.of(context).pop();
        },
      ).show();



      // AwesomeDialog(
      //   dismissOnTouchOutside: false,
      //   context: context,
      //   dialogType: DialogType.success,
      //   animType: AnimType.scale,
      //   title: 'Success',
      //   btnOkOnPress: () {
      //     setState(() {
      //       widget.isLoading = false;
      //     });
      //     Navigator.of(context).pop();
      //   },
      // ).show();
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

                                        widget.name_vocabulary = value.replaceAll(" ", "_");
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
                                  widget.StringListWord = value;
                                },
                              ),
                            ),
                            SizedBox(height: 50,),
                            ElevatedButton(
                              onPressed: () async {
                                final isValid = _form.currentState!.validate();
                                if(isValid){
                                  _form.currentState!.save();
                                }

                                setState(() {
                                  widget.isLoading = true;
                                });

                                if(widget.linkImages != null){
                                  var images_background = storage.ref().child("VocabularyImage").child("${widget.name_vocabulary}_${widget.authentical.currentUser!.uid}.jpg");
                                  await images_background.putFile(File(widget.linkImages));
                                  widget.linkURLImages = await images_background.getDownloadURL();
                                }

                                if((await widget.db.hasSet("VocabularyList", {"tokenUID": widget.authentical.currentUser!.uid, "nameSet": widget.name_vocabulary}))){
                                  AwesomeDialog(
                                      dismissOnTouchOutside: false,
                                      context: context,
                                      dialogType: DialogType.error,
                                      animType: AnimType.scale,
                                      title: 'Name set already exists',
                                      btnCancelOnPress: () {
                                        setState(() {
                                          widget.isLoading = false;
                                        });
                                      },
                                      btnCancelText: "Ok"
                                ).show();
                                }else{
                                  hanldWord(widget.StringListWord);
                                }
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