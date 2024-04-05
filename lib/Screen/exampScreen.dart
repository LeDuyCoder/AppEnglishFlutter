import 'dart:math';

import 'package:appenglish/Module/DataBaseHelper.dart';
import 'package:appenglish/Module/readHive.dart';
import 'package:appenglish/Module/word.dart';
import 'package:appenglish/Screen/Cagratulate.dart';
import 'package:appenglish/Widgets/SpeachToText.dart';
import 'package:appenglish/Widgets/WidgetsAlertExamText/alertWrong.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';

import '../Widgets/WidgetsAlertExamText/alertRight.dart';

class exampScreen extends StatefulWidget{
  exampScreen({super.key, required this.topic, required this.statuse});

  @override
  State<StatefulWidget> createState() => _exampScreen();

  bool statuse;
  List<String> listVocaubularyLearn = [];
  Map<String, Word> listVocaubalryData = {};
  List<String> learnTime2 = [];
  List<String> success = [];
  int timeCheck = 0;
  final String topic;
  String txt = "";
  int amountQuestion = 0;
  Word? word;
  bool _isDataLoaded = true;
  double progress = 0.0;
}

class _exampScreen extends State<exampScreen>{
  final TextEditingController _textEditingController = TextEditingController();

  Future<void> updateData() async {
    await DataBaseHelper().updateData(widget.success, FirebaseAuth.instance, "family");
  }


  @override
  void initState() {
    super.initState();
    LoadData();
  }

  void hanldAnwser(String txtWord){
    if(txtWord == widget.word!.word){
      alearRightText(txtWord, widget.word!);
    }else{
      alertWrongText(txtWord, widget.word!);
    }
  }

  void alearRightText(String wordAnswer, Word word){
    AwesomeDialog(
        dismissOnTouchOutside: false,
        headerAnimationLoop: false,
        context: context,
        dialogType: DialogType.noHeader,
        animType: AnimType.scale,
        body: alertRight(anwser: wordAnswer, word: word),
        btnOkOnPress: (){
          setState((){

            if(widget.listVocaubularyLearn.contains(wordAnswer)){
              widget.listVocaubularyLearn.remove(wordAnswer);
              widget.learnTime2.add(wordAnswer);
            }else if(widget.learnTime2.contains(wordAnswer)){
              widget.learnTime2.remove(wordAnswer);
              widget.success.add(wordAnswer);
            }

            widget.progress = widget.success.length / (widget.listVocaubularyLearn.length + widget.learnTime2.length + widget.success.length);

            widget.timeCheck -= 1;

            print(widget.timeCheck);
            widget.word = randomWordCheck();
            _textEditingController.clear();
          });
        },
        btnOkText: "Continues",
        btnOkColor: Colors.green
    ).show();
  }

  void alertWrongText(String wordAnwser, Word word){
    AwesomeDialog(
        dismissOnTouchOutside: false,
        headerAnimationLoop: false,
        context: context,
        dialogType: DialogType.noHeader,
        animType: AnimType.scale,
        body: alertWrong(anwser: wordAnwser, word: word),
        btnOkOnPress: (){
          setState(() {
            widget.timeCheck -= 1;
            widget.word = randomWordCheck();
            _textEditingController.clear();
          });
        },
        btnOkText: "Continues",
        btnOkColor: Colors.red

    ).show();
  }

  Future<void> hanldUpdateData() async{
    if(widget.statuse) {
      await updateData();
    }
    await ReadHive().writeTime((await ReadHive().getHivePath()), "haveVocabulary", FirebaseAuth.instance, widget.topic);
    Navigator.pop(context);
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => Cagratulate()));
  }


  Word? randomWordCheck() {
    if(widget.timeCheck >= 1){
      List<String> _dataWordRandom = [];
      _dataWordRandom.addAll(widget.listVocaubularyLearn);
      _dataWordRandom.addAll(widget.learnTime2);

      return widget.listVocaubalryData[_dataWordRandom[Random()
          .nextInt(_dataWordRandom.length)]];
    }else{
      hanldUpdateData();
    }
    return widget.word;
  }

  Future<void> LoadData() async {
    widget.listVocaubularyLearn.addAll(await ReadHive().readDataLearnedTopic((await ReadHive().getHivePath()), "havevocabulary", FirebaseAuth.instance, widget.topic));
    dynamic _datas = await DataBaseHelper().getAllData("LisVoc", {
        "tokenUID": FirebaseAuth.instance.currentUser!.uid,
        "nameSet": widget.topic
      }
    );
    for (Map<String, dynamic> _data in _datas){
      if(widget.listVocaubularyLearn.contains(_data["word"])) {
        widget.listVocaubalryData[_data["word"]] = Word(
            word: _data["word"],
            type: convertStringToEnum(_data["type"]),
            linkUK: _data["linkUK"],
            linkUS: _data["linkUS"],
            phonicUK: _data["phonicUK"],
            phonicUS: _data["phonicUS"],
            means: _data["mean"],
            example: _data["example"]
        );
      }
    }

    widget.amountQuestion = widget.listVocaubularyLearn.length * 2;
    print(widget.listVocaubularyLearn);
    print(widget.listVocaubalryData);

    setState((){
      widget.timeCheck = widget.listVocaubularyLearn.length * 2;
      widget._isDataLoaded = false;
      widget.word = randomWordCheck();
    });
  }

  final _From = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.white,
        elevation: 2.5,
        iconTheme: Theme.of(context).iconTheme.copyWith(
            color: Colors.black
        ),
        title: LinearProgressIndicator(
          value: widget.progress,
          borderRadius: BorderRadius.circular(20),
          minHeight: 8,
        ),
      ),
      body: widget._isDataLoaded ? const Center(
              child: CircularProgressIndicator(), // Hiển thị tiến trình loading
            ) : Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, top: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text("[${widget.word!.type.name}] ${widget.word!.means}", textAlign: TextAlign.start, style: TextStyle(fontSize: 18),),
                          Text(widget.word!.example.replaceAll(widget.word!.word, "____"), textAlign: TextAlign.start,)
                        ],
                      ),
                    ),
                  ),
                )
            ),
            Form(
              key: _From,
              child: Padding(
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: TextFormField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    prefixIcon: IconButton(
                      icon: Icon(Icons.mic, color: Colors.blueAccent,),
                      onPressed: () async {
                        PermissionStatus status = await Permission.microphone.status;
                        if (!status.isGranted) {
                          status = await Permission.microphone.request();
                        }
                        if (status.isGranted) {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.noHeader,
                            animType: AnimType.scale,
                            body: SpeechToTextButton( callBackData: (String value) {
                              setState(() {
                                _textEditingController.text = value;
                              });
                            },),
                          ).show();
                        } else {

                        }
                      },
                    ),
                    suffixIcon: IconButton(onPressed: (){
                      hanldAnwser(_textEditingController.text);
                    }, icon: Icon(Icons.send, color: Colors.blue,)
                    ),
                    hintText: "enter your anwsers",
                    border: OutlineInputBorder( // Border cho TextFormField
                      borderRadius: BorderRadius.circular(20.0), // Điều chỉnh độ cong của border
                      borderSide: BorderSide(color: Colors.grey), // Màu và độ rộng của border
                    ),
                    contentPadding: EdgeInsets.only(left: 10, bottom: 10), // Padding bên trong TextFormField
                  ),
                  validator: (value){
                    if(value!.trim().isEmpty){
                      return "answer not null";
                    }
                  },
                ),
              ),
            )
          ],
        ),
      )
    );
  }

}