import 'dart:convert';

import 'package:appenglish/Module/DataBaseHelper.dart';
import 'package:appenglish/Screen/loginScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;

import 'DashBoardScreen/QrScreen.dart';

class InfomationFriendScreen extends StatefulWidget{
  InfomationFriendScreen({super.key, required this.TokenUID, required this.Friend, required this.loadListFriend});

  @override
  State<StatefulWidget> createState() => _InfomationFriendScreen();

  String TokenUID;
  bool Friend;
  void Function() loadListFriend;
  String imageDataFriend = "";

}

class _InfomationFriendScreen extends State<InfomationFriendScreen>{



  Future<Map<String, dynamic>> getDataFriend(TokenUID) async {
    FirebaseFirestore dataFiresStore = FirebaseFirestore.instance;
    DocumentSnapshot<Map<String, dynamic>> data = await dataFiresStore.collection("users").doc(TokenUID).collection("dataAccount").doc("data").get();
    Map<String, dynamic>? dataUser = data.data();

    return dataUser ?? {};
  }

  List<List<int>> hanldeBackgroundCard(int time){
    if(time >= 0 && time < 1296000){
      return [[255, 255, 255], [148, 244, 73]];
    }else if(time >= 1296000 && time < 2592000){
      return [[255, 238, 204], [236, 123, 60]];
    }else if(time >= 2592000 && time < 3888000){
      return [[255, 255, 255], [169, 169, 169]];
    }else if(time >= 3888000 && time < 7776000){
      return [[255, 238, 223], [255, 138, 0]];
    }else if(time >= 7776000 && time < 12960000){
      return [[229, 229, 229], [118, 118, 118]];
    }else if(time >= 12960000 && time < 18144000){
      return [[255, 255, 255], [225, 225, 225]];
    }else if(time >= 18144000 && time < 23328000){
      return [[164, 164, 164], [255, 255, 255]];
    }else if(time >= 23328000 && time < 31536000){
      return [[254, 241, 173], [255, 214, 0]];
    }else if(time >= 31536000 && time < 37584000){
      return [[255, 255, 255], [117, 101, 69]];
    }else if(time >= 37584000 && time < 43920000){
      return [[164, 250, 255], [44, 182, 226]];
    }else{
      return [[255, 142, 142], [185, 32, 32]];
    }
  }

  Future<List<List<int>>> hanldCardFriend(String UUID) async {
    try {
      final response = await http.get(Uri.parse('https://www.landernetwork.io.vn/backend_api/data_api.php?type=getTime&UID=${FirebaseAuth.instance.currentUser!.uid}'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body)[0][0];
        var _dataBackground = hanldeBackgroundCard(int.parse(data["timeOnline"]));
        return _dataBackground;
      }else{
        return [[0, 0, 0], [0, 0, 0]];
      }
    } catch (error) {
      return [[0, 0, 0], [0, 0, 0]];
    }
  }



  @override
  Widget build(BuildContext context) {

    var _dataBackground = hanldeBackgroundCard(100);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 246, 200, 1.0),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 246, 200, 1.0),
        iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.black),
      ),
      body: FutureBuilder(future: getDataFriend(widget.TokenUID), builder: (ctx, data){

        if(data.connectionState == ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue,),
          );
        }

        if(data.hasData){

          widget.imageDataFriend = data.data!["urlImage"];

          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.grey[200],
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 250,
                  color: Color.fromRGBO(255, 246, 200, 1.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        //data["urlImage"]
                          child: widget.imageDataFriend == "" ? Image.asset(
                            "assets/images/avata.png",
                            height: 250,
                            width: 250,
                            fit: BoxFit.scaleDown,
                            scale: 4,
                          ) : Image.network(
                            widget.imageDataFriend,
                            height: 250,
                            width: 250,
                            fit: BoxFit.scaleDown,
                            scale: 4,
                          )
                        //     : Image.network(
                        //   data["urlImage"],
                        //   height: 250,
                        //   width: 250,
                        //   fit: BoxFit.cover,
                        // ),
                      ),
                    ],
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(top: 170),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), // Màu của bóng đổ
                          spreadRadius: 0, // Bán kính lan rộng của bóng đổ
                          blurRadius: 7, // Độ mờ của bóng đổ
                          offset: Offset(0, -4), // Độ lệch của bóng đổ theo chiều dọc
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5), // Màu của bóng đổ
                                  spreadRadius: 0, // Bán kính lan rộng của bóng đổ
                                  blurRadius: 7, // Độ mờ của bóng đổ
                                  offset: Offset(0, 4), // Độ lệch của bóng đổ theo chiều dọc
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(data.data!["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                                            Text(data.data!["title"], style:  const TextStyle(fontSize: 15),),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Row(
                                      children: [
                                        Text("Friends: ${data.data!["list_friend"].length}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 209, 255, 1.0)),),
                                        SizedBox(width: 10,),
                                        Text("Collection: ${data.data!["amount_vocabulary_list"]}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 209, 255, 1.0)),),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10,),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10, right: 10),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            setState(() {
                                              widget.Friend = !widget.Friend;
                                            });
                                            //Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => listFriendScreen(dataCound: widget.dataClound)));
                                            //await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).collection("dataAccount").doc("data").update({"list_friend": FieldValue.arrayRemove([])});
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color: Colors.grey.withOpacity(0.6), // Màu của đường viền
                                                width: 0.5, // Độ dày của đường viền
                                              ),
                                              borderRadius: BorderRadius.circular(15.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.6), // Màu của bóng đổ
                                                  spreadRadius: 2, // Bán kính lan rộng của bóng đổ
                                                  blurRadius: 2, // Độ mờ của bóng đổ
                                                  offset: Offset(-1, 1), // Độ lệch của bóng đổ theo chiều dọc
                                                ),
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(1), // Màu của bóng đổ
                                                  spreadRadius: 2, // Bán kính lan rộng của bóng đổ
                                                  blurRadius: 1, // Độ mờ của bóng đổ
                                                  offset: Offset(-2, 3), // Độ lệch của bóng đổ theo chiều dọc
                                                ),
                                              ],
                                            ),
                                            height: 60,
                                            width: MediaQuery.of(context).size.width - 20,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                widget.Friend == false ? const Icon(Icons.people_alt, color: Color.fromRGBO(0, 209, 255, 1.0),) : const Icon(Icons.person_off, color: Colors.redAccent,),
                                                const SizedBox(width: 10,),
                                                widget.Friend == false ? const Text("Friends", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 209, 255, 1.0)),) : const Text("UnFriends", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 50,),
                          FutureBuilder(future: hanldCardFriend(widget.TokenUID), builder: (ctx, dataCard){
                            if(dataCard.connectionState == ConnectionState.waiting){
                              return CircularProgressIndicator(color: Colors.blue,);
                            }

                            if(dataCard.hasData){
                              return Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: Container(
                                      margin: const EdgeInsets.only(left: 40, right: 40, top: 15, bottom: 15),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color.fromRGBO(_dataBackground[0][0], _dataBackground[0][1], _dataBackground[0][2], 1.0),
                                            Color.fromRGBO(_dataBackground[1][0], _dataBackground[1][1], _dataBackground[1][2], 1.0),
                                          ],
                                          stops: [0.0, 1.0], // Điểm dừng của mỗi màu trong gradient (từ 0.0 đến 1.0)
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5), // Màu của bóng đổ
                                            spreadRadius: 0, // Bán kính lan rộng của bóng đổ
                                            blurRadius: 7, // Độ mờ của bóng đổ
                                            offset: const Offset(0, 4), // Độ lệch của bóng đổ theo chiều dọc
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          Container(
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 5),
                                                      child: Image.asset("assets/images/ranks/leave.png", scale: 2.0),
                                                    ),
                                                    Expanded(
                                                      child: Align(
                                                          alignment: Alignment.centerRight,
                                                          child: Stack(
                                                            alignment: Alignment.center,
                                                            children: [
                                                              Container(
                                                                height: 50,
                                                                width: 50,
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                              QrImageView(
                                                                data: FirebaseAuth.instance.currentUser!.uid,
                                                                version: QrVersions.auto,
                                                                size: 60.0,
                                                              ),
                                                            ],
                                                          )
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Expanded(
                                                  child: Align(
                                                      alignment: Alignment.bottomRight,
                                                      child: Padding(
                                                        padding: EdgeInsets.only(bottom: 5, right: 5),
                                                        child: Transform.rotate(
                                                          angle: 35 * (3.14 / 180), // Chuyển đổi độ sang radian
                                                          child: Image.asset("assets/images/ranks/leave.png", scale: 1.5),
                                                        ),
                                                      )
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                  width: (MediaQuery.of(context).size.width - 80)*0.3,
                                                  child: widget.imageDataFriend == "" ? Image.asset(
                                                    "assets/images/avata.png",
                                                    height: 200,
                                                    width: 200,
                                                    fit: BoxFit.scaleDown,
                                                    scale: 6,
                                                  ) : ClipRect(
                                                    child: Align(
                                                      alignment: Alignment.center,
                                                      child: OverflowBox(
                                                        maxWidth: double.infinity,
                                                        maxHeight: double.infinity,
                                                        child: Image.network(
                                                          widget.imageDataFriend,
                                                          width: 70,
                                                          height: 70,
                                                          fit: BoxFit.cover, // Sử dụng BoxFit.cover để crop ảnh
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: (MediaQuery.of(context).size.width - 80)*0.6,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(data.data!["name"], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                                                      Text("Collection: ${data.data!["amount_vocabulary_list"]}", style:  TextStyle(fontSize: 15),),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                  )
                              );
                            }else{
                              return Text("Error", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),);
                            }
                          }),
                        ],
                      ),
                    )

                )
              ],
            ),
          );
        }else{
          return const Center(
            child: Text("Something error!", style: TextStyle(fontWeight: FontWeight.bold),),
          );
        }
      })
    );
  }

  @override
  void dispose() async {
    super.dispose();

    if(widget.Friend == false){
      await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).collection("dataAccount").doc("data").update({"list_friend": FieldValue.arrayRemove(["apKat2N0nKWJfFfqfmzbFkFAXPz1"])});
      widget.loadListFriend;
    }


    if(widget.imageDataFriend != "") {
      await DataBaseHelper().updateImageFriend(
          widget.TokenUID, widget.imageDataFriend);
    }
  }
}