import 'dart:async';

import 'package:appenglish/Module/word.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class tableSet extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _tableSet();

  final List<Word> listData;

  const tableSet({super.key, required this.listData});

}

class _tableSet extends State<tableSet> {


  Future<void> DialogReFix(Word elementWorld) async{
    final _miniForm = GlobalKey<FormState>();
    var status = false;
    var _word = "";
    var _phonicUS = "";
    var _phonicUK = "";
    var _meas = "";
    var _example = "";


    AwesomeDialog(
        onDismissCallback: (type){
          if(type == DismissType.btnCancel){
            Navigator.of(context).pop(type);
          }else if(type == DismissType.btnOk){
            if(status == true){
              Navigator.of(context).pop(type);
            }
          }
        },
        autoDismiss: false,
        dismissOnTouchOutside: false,
        context: context,
        dialogType: DialogType.noHeader,
        animType: AnimType.scale,
        body: Container(
          height: 200,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text("Update data vocabulary", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
                Form(
                    key: _miniForm,
                    child: Column(
                      children: [
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey), // Border của container
                            borderRadius: BorderRadius.circular(8.0), // Điều chỉnh độ cong của border
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5), // Màu và độ trong suốt của đổ bóng
                                spreadRadius: 2,
                                blurRadius: 7,
                                offset: Offset(0, 3), // Điều chỉnh vị trí của đổ bóng
                              ),
                            ],
                          ),
                          child: TextFormField(
                            initialValue: elementWorld.word,
                            // Dữ liệu ban đầu của TextFormField
                            decoration: const InputDecoration(
                              hintText: "word",
                              border: InputBorder.none, // Xóa border của TextFormField
                              contentPadding: EdgeInsets.only(left: 10, bottom: 10), // Padding bên trong TextFormField
                            ),
                            validator: (value){
                              if(value!.trim().isEmpty){
                                return "world not null";
                              }

                              if(elementWorld.word != value){
                                _word = value;
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Expanded(child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey), // Border của container
                                borderRadius: BorderRadius.circular(8.0), // Điều chỉnh độ cong của border
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5), // Màu và độ trong suốt của đổ bóng
                                    spreadRadius: 2,
                                    blurRadius: 7,
                                    offset: Offset(0, 3), // Điều chỉnh vị trí của đổ bóng
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                initialValue: elementWorld.phonicUS,
                                // Dữ liệu ban đầu của TextFormField
                                decoration: const InputDecoration(
                                  hintText: "phonicUS",
                                  border: InputBorder.none, // Xóa border của TextFormField
                                  contentPadding: EdgeInsets.only(left: 10, bottom: 10), // Padding bên trong TextFormField
                                ),
                                validator: (value){
                                  if(value!.trim().isEmpty){
                                    return "phonicUS not null";
                                  }

                                  if(elementWorld.phonicUS != value){
                                    _phonicUS = value;
                                  }
                                },
                              ),
                            ),),
                            const SizedBox(width: 10),
                            Expanded(child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey), // Border của container
                                borderRadius: BorderRadius.circular(8.0), // Điều chỉnh độ cong của border
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5), // Màu và độ trong suốt của đổ bóng
                                    spreadRadius: 2,
                                    blurRadius: 7,
                                    offset: Offset(0, 3), // Điều chỉnh vị trí của đổ bóng
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                initialValue: elementWorld.phonicUK,
                                // Dữ liệu ban đầu của TextFormField
                                decoration: const InputDecoration(
                                  hintText: "phonicUK",
                                  border: InputBorder.none, // Xóa border của TextFormField
                                  contentPadding: EdgeInsets.only(left: 10, bottom: 10), // Padding bên trong TextFormField
                                ),
                                validator: (value){
                                  if(value!.trim().isEmpty){
                                    return "phonicUK not null";
                                  }

                                  if(elementWorld.phonicUK != value){
                                    _phonicUK = value;
                                  }
                                },
                              ),
                            ),),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey), // Border của container
                            borderRadius: BorderRadius.circular(8.0), // Điều chỉnh độ cong của border
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5), // Màu và độ trong suốt của đổ bóng
                                spreadRadius: 2,
                                blurRadius: 7,
                                offset: Offset(0, 3), // Điều chỉnh vị trí của đổ bóng
                              ),
                            ],
                          ),
                          child: TextFormField(
                            initialValue: elementWorld.means,
                            // Dữ liệu ban đầu của TextFormField
                            decoration: const InputDecoration(
                              hintText: "means",
                              border: InputBorder.none, // Xóa border của TextFormField
                              contentPadding: EdgeInsets.only(left: 10, bottom: 10), // Padding bên trong TextFormField
                            ),
                            validator: (value){
                              if(value!.trim().isEmpty){
                                return "Means not null";
                              }

                              if(elementWorld.means != value){
                                _meas = value;
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 10,),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey), // Border của container
                            borderRadius: BorderRadius.circular(8.0), // Điều chỉnh độ cong của border
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5), // Màu và độ trong suốt của đổ bóng
                                spreadRadius: 2,
                                blurRadius: 7,
                                offset: Offset(0, 3), // Điều chỉnh vị trí của đổ bóng
                              ),
                            ],
                          ),
                          child: TextFormField(
                            initialValue: elementWorld.example,
                            // Dữ liệu ban đầu của TextFormField
                            decoration: const InputDecoration(
                              hintText: "example",
                              border: InputBorder.none, // Xóa border của TextFormField
                              contentPadding: EdgeInsets.only(left: 10, bottom: 10), // Padding bên trong TextFormField
                            ),
                            validator: (value){
                              if(value!.trim().isEmpty){
                                return "Example not null";
                              }

                              if(elementWorld.example != value){
                                _example = value;
                              }
                            },
                          ),
                        ),
                      ],
                    )
                ),
              ],
            ),
          )
        ),
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          final isValid = _miniForm.currentState!.validate();
          if (isValid) {
            _miniForm.currentState!.save();

            if(_word != "" || _phonicUS != "" || _phonicUK != "" || _meas != "" || _example != ""){
              widget.listData.remove(elementWorld);
              widget.listData.add(
                  Word(
                      word: _word == "" ? elementWorld.word : _word,
                      type: elementWorld.type,
                      linkUK: elementWorld.linkUK,
                      linkUS: elementWorld.linkUS,
                      phonicUK: _phonicUK == "" ? elementWorld.phonicUK : _phonicUK,
                      phonicUS: _phonicUS == "" ? elementWorld.phonicUS : _phonicUS,
                      means: _meas == "" ? elementWorld.means : _meas,
                      example: _example == "" ? elementWorld.example : _example
                  )
              );
            }
            status = true;
          }
        },
    ).show();
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