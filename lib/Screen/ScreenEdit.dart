import 'package:appenglish/Widgets/tableSet.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Module/word.dart';

class ScreenEdit extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _ScreenEdit();

  final Word elementWorld;
  final Function(Word oldWord, Word newWord) updateWord;
  final Function(Word oldWord) removeWord;

  const ScreenEdit({super.key, required this.elementWorld, required this.updateWord, required this.removeWord});



}

class _ScreenEdit extends State<ScreenEdit>{
  final _miniForm = GlobalKey<FormState>();
  var status = false;
  var _word = "";
  var _phonicUS = "";
  var _phonicUK = "";
  var _meas = "";
  var _example = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: Theme.of(context).iconTheme.copyWith(
              color: Colors.white
          ),
          backgroundColor: const Color.fromRGBO(0, 42, 160, 1.0),
          title: const Text("Edit Vocabuary", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        ),
        body: Column(
          children: [
            //const Text("Update data vocabulary", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
            SizedBox(height: 50,),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: const Border(
                    top: BorderSide(
                      color: Colors.blue,
                      width: 4.0,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 5,
                      offset: Offset(0, 5), // changes position of shadow
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.only(right: 20,left: 20, top: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Form(
                        key: _miniForm,
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: widget.elementWorld.word,
                              // Dữ liệu ban đầu của TextFormField
                              decoration: InputDecoration(
                                suffixIcon: Icon(Icons.text_fields),
                                hintText: "word",
                                border: OutlineInputBorder( // Border cho TextFormField
                                  borderRadius: BorderRadius.circular(8.0), // Điều chỉnh độ cong của border
                                  borderSide: BorderSide(color: Colors.grey), // Màu và độ rộng của border
                                ),
                                contentPadding: EdgeInsets.only(left: 10, bottom: 10), // Padding bên trong TextFormField
                              ),
                              validator: (value) {
                                if (value!.trim().isEmpty) {
                                  return "world not null";
                                }

                                if (widget.elementWorld.word != value) {
                                  _word = value;
                                }
                              },
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: [
                                Expanded(child: TextFormField(
                                  initialValue: widget.elementWorld.phonicUS,
                                  // Dữ liệu ban đầu của TextFormField
                                  decoration: InputDecoration(
                                    suffixIcon: Icon(Icons.volume_up),
                                    hintText: "phonicUS",
                                    border: OutlineInputBorder( // Border cho TextFormField
                                      borderRadius: BorderRadius.circular(8.0), // Điều chỉnh độ cong của border
                                      borderSide: BorderSide(color: Colors.grey), // Màu và độ rộng của border
                                    ),
                                    contentPadding: EdgeInsets.only(left: 10, bottom: 10), // Padding bên trong TextFormField
                                  ),
                                  validator: (value){
                                    if(value!.trim().isEmpty){
                                      return "phonicUS not null";
                                    }

                                    if(widget.elementWorld.phonicUS != value){
                                      _phonicUS = value;
                                    }
                                  },
                                ),),
                                const SizedBox(width: 10),
                                Expanded(child: TextFormField(
                                  initialValue: widget.elementWorld.phonicUK,
                                  // Dữ liệu ban đầu của TextFormField
                                  decoration: InputDecoration(
                                    suffixIcon: Icon(Icons.volume_up),
                                    hintText: "phonicUK",
                                    border: OutlineInputBorder( // Border cho TextFormField
                                      borderRadius: BorderRadius.circular(8.0), // Điều chỉnh độ cong của border
                                      borderSide: BorderSide(color: Colors.grey), // Màu và độ rộng của border
                                    ),
                                    contentPadding: EdgeInsets.only(left: 10, bottom: 10), // Padding bên trong TextFormField
                                  ),
                                  validator: (value){
                                    if(value!.trim().isEmpty){
                                      return "phonicUK not null";
                                    }

                                    if(widget.elementWorld.phonicUK != value){
                                      _phonicUK = value;
                                    }
                                  },
                                )),
                              ],
                            ),
                            SizedBox(height: 10,),
                            TextFormField(
                              initialValue: widget.elementWorld.means,
                              // Dữ liệu ban đầu của TextFormField
                              decoration: InputDecoration(
                                hintText: "means",
                                border: OutlineInputBorder( // Border cho TextFormField
                                  borderRadius: BorderRadius.circular(8.0), // Điều chỉnh độ cong của border
                                  borderSide: BorderSide(color: Colors.grey), // Màu và độ rộng của border
                                ),
                                contentPadding: EdgeInsets.only(left: 10, bottom: 10), // Padding bên trong TextFormField
                              ),
                              validator: (value){
                                if(value!.trim().isEmpty){
                                  return "Means not null";
                                }

                                if(widget.elementWorld.means != value){
                                  _meas = value;
                                }
                              },
                            ),
                            SizedBox(height: 10,),
                            TextFormField(
                              initialValue: widget.elementWorld.example,
                              // Dữ liệu ban đầu của TextFormField
                              decoration: InputDecoration(
                                hintText: "example",
                                border: OutlineInputBorder( // Border cho TextFormField
                                  borderRadius: BorderRadius.circular(8.0), // Điều chỉnh độ cong của border
                                  borderSide: BorderSide(color: Colors.grey), // Màu và độ rộng của border
                                ),
                                contentPadding: EdgeInsets.only(left: 10, bottom: 10), // Padding bên trong TextFormField
                              ),
                              validator: (value){
                                if(value!.trim().isEmpty){
                                  return "Example not null";
                                }

                                if(widget.elementWorld.example != value){
                                  _example = value;
                                }
                              },
                            ),
                          ],
                        )
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 50,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    AwesomeDialog(
                        context: context,
                        dialogType: DialogType.warning,
                        animType: AnimType.scale,
                        desc: "Once deleted, it cannot be recovered. Please reconsider before deleting.",
                        btnCancelOnPress: () {},
                        btnOkOnPress: () {
                          widget.removeWord(widget.elementWorld);
                          Navigator.of(context).pop();
                        },
                    ).show();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(178, 0, 0, 1.0), // Màu nền của nút
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      // Đặt góc bo tròn
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 12),
                  ),
                  child: const Text('Remove', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                ),
                SizedBox(width: 20,),
                ElevatedButton(
                  onPressed: () {
                    final isValid = _miniForm.currentState!.validate();
                    if(isValid){
                      _miniForm.currentState!.save();
                    }

                    if(_word != "" || _meas != "" || _phonicUS != "" || _phonicUK != "" || _example != ""){
                      widget.updateWord(widget.elementWorld, Word(
                          word: _word != "" ? _word : widget.elementWorld.word,
                          type: widget.elementWorld.type,
                          linkUK: widget.elementWorld.linkUK,
                          linkUS: widget.elementWorld.linkUS,
                          phonicUK: _phonicUK != "" ? _phonicUK : widget.elementWorld.phonicUK,
                          phonicUS: _phonicUS != "" ? _phonicUS : widget.elementWorld.phonicUS,
                          means: _meas != "" ? _meas : widget.elementWorld.means,
                          example: _example != "" ? _example : widget.elementWorld.example)
                      );
                    }

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 169, 53, 1.0), // Màu nền của nút
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Đặt góc bo tròn
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 12),
                  ),
                  child: const Text('Update', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                )
              ],
            )
          ],
        ),
    );
  }

}