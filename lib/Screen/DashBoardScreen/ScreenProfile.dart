import 'dart:ffi';

import 'package:appenglish/Screen/DashBoardScreen/QrScreen.dart';
import 'package:appenglish/Screen/dasboardScreen.dart';
import 'package:appenglish/Screen/listFriendScreen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ScreenProfile extends StatefulWidget{
  ScreenProfile({super.key, required this.dataClound});

  @override
  State<StatefulWidget> createState() => _ScreenProfile();

  Map<String, dynamic> dataClound;

}

class _ScreenProfile extends State<ScreenProfile>{
  
  Future<Map<String, dynamic>?> getDataUser(String TokenUID) async{
    FirebaseFirestore dataFiresStore = FirebaseFirestore.instance;
    DocumentSnapshot<Map<String, dynamic>> data = await dataFiresStore.collection("users").doc(TokenUID).collection("dataAccount").doc("data").get();
    Map<String, dynamic>? dataUser = data.data();
    return dataUser;
  }
  
  
  @override
  Widget build(BuildContext context) {

    print(widget.dataClound);

    return FutureBuilder(future: getDataUser(FirebaseAuth.instance.currentUser!.uid), builder: (ctx, dataresult){
      if(dataresult.connectionState == ConnectionState.waiting){
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.green,),
          ),
        );
      }

      String formatSeconds(int seconds) {
        if (seconds < 0) {
          return "Invalid input";
        }

        // Biến lưu trữ số giây, phút, giờ, ngày, tháng và năm
        int minute = 60;
        int hour = minute * 60;
        int day = hour * 24;
        int month = day * 30; // Giả sử một tháng có 30 ngày
        int year = day * 365; // Giả sử một năm có 365 ngày

        // Chuyển đổi số giây thành các phần thời gian
        int years = seconds ~/ year;
        seconds %= year;
        int months = seconds ~/ month;
        seconds %= month;
        int days = seconds ~/ day;
        seconds %= day;
        int hours = seconds ~/ hour;
        seconds %= hour;
        int minutes = seconds ~/ minute;
        seconds %= minute;

        // Xây dựng chuỗi định dạng thời gian
        String result = '';
        if (years > 0) {
          result += '${years}y ${months}m';
        }else if (months > 0) {
          result += '${months}m ${days}d';
        }else if (days > 0) {
          result += '${days}d ${hours}h';
        }else if (hours > 0) {
          result += '${hours}h ${minutes}m';
        }else if (minutes > 0) {
          result += '${minutes}h ${seconds}s';
        }else {
          result += '${seconds}s';
        }

        // Loại bỏ khoảng trắng dư thừa ở cuối
        result = result.trim();

        // Loại bỏ ký tự "s" nếu chỉ có phần giây
        if (result.endsWith('s')) {
          result = result.substring(0, result.length);
        }

        return result;
      }


      Stream<int> timeStream(){
        return Stream.periodic(Duration(seconds: 1), (_) => dasboardScreen.time_online);
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

      List<String> hanldeSecond(int time){
        if(time >= 0 && time < 1296000){
          return ["assets/images/ranks/leave.png", "Leave"];
        }else if(time >= 1296000 && time < 2592000){
          return ["assets/images/ranks/wood.png", "Wood"];
        }else if(time >= 2592000 && time < 3888000){
          return ["assets/images/ranks/stone.png", "Stone"];
        }else if(time >= 3888000 && time < 7776000){
          return ["assets/images/ranks/bronze.png", "Bronze"];
        }else if(time >= 7776000 && time < 12960000){
          return ["assets/images/ranks/thep.png", "Steel"];
        }else if(time >= 12960000 && time < 18144000){
          return ["assets/images/ranks/silver.png", "silver"];
        }else if(time >= 18144000 && time < 23328000){
          return ["assets/images/ranks/iron.png", "Iron"];
        }else if(time >= 23328000 && time < 31536000){
          return ["assets/images/ranks/gold.png", "Golden"];
        }else if(time >= 31536000 && time < 37584000){
          return ["assets/images/ranks/platinum.png", "Platinum"];
        }else if(time >= 37584000 && time < 43920000){
          return ["assets/images/ranks/diamond.png", "Diamond"];
        }else{
          return ["assets/images/ranks/ruby.png", "Ruby"];
        }
      }

      if(dataresult.hasData){
        Map<String, dynamic> data = dataresult.data!;
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.grey[200],
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 300,
                color: Color.fromRGBO(255, 246, 200, 1.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: data["urlImage"] == null ? Image.asset(
                        "assets/images/avata.png",
                        height: 250,
                        width: 250,
                        fit: BoxFit.scaleDown,
                        scale: 4,
                      ) : Image.network(
                          data["urlImage"],
                          height: 250,
                          width: 250,
                          fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  margin: EdgeInsets.only(top: 200),
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
                                          Text(data["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                                          Text(data["title"], style:  const TextStyle(fontSize: 15),),
                                        ],
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: AlignmentDirectional.topEnd,
                                          child: GestureDetector(
                                            onTap: (){
                                              Navigator.push(context, MaterialPageRoute(builder: (ctx) => QrScreen(dataUser: data)));
                                            },
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                QrImageView(
                                                  data: FirebaseAuth.instance.currentUser!.uid,
                                                  version: QrVersions.auto,
                                                  size: 60.0,
                                                ),

                                                Container(
                                                  height: 50,
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(5.0),
                                                      border: Border.all(
                                                          color: const Color.fromRGBO(
                                                              123, 191, 253, 1.0),
                                                          width: 1.5
                                                      )
                                                  ),
                                                ),
                                              ],
                                            )
                                          )
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Row(
                                    children: [
                                      Text("Friends: ${data["list_friend"].length}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 209, 255, 1.0)),),
                                      SizedBox(width: 10,),
                                      Text("Collection: ${data["amount_vocabulary_list"]}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 209, 255, 1.0)),),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10,),
                                Padding(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: (){
                                          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => listFriendScreen(dataCound: widget.dataClound)));
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
                                          width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width*0.25)) - 10,
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.people_alt, color: Color.fromRGBO(0, 209, 255, 1.0),),
                                              SizedBox(width: 10,),
                                              Text("List Friends", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 209, 255, 1.0)),),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10,),
                                      Container(
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
                                        width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width*0.85)),
                                        child: Icon(Icons.settings, color: Colors.grey, size: 35,),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 5,),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5), // Màu của bóng đổ
                                spreadRadius: 0, // Bán kính lan rộng của bóng đổ
                                blurRadius: 7, // Độ mờ của bóng đổ
                                offset: const Offset(0, 4), // Độ lệch của bóng đổ theo chiều dọc
                              ),
                            ],
                          ),
                          child: StreamBuilder(stream: timeStream(), builder: (ctx, dataStream){
                            if(dataStream.connectionState == ConnectionState.waiting){
                              return Center(
                                child: CircularProgressIndicator(color: Colors.blue,),
                              );
                            }

                            if(dataStream.hasData){
                              var _data = hanldeSecond(dataStream.data!);
                              List<List<int>> _dataBackground = hanldeBackgroundCard(dataStream.data!);

                              return  Container(
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
                                                  child: Image.asset(_data[0], scale: 2.0),
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
                                                      child: Image.asset(_data[0], scale: 1.5),
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
                                              child: data["urlImage"] == null ? Image.asset(
                                                "assets/images/avata.png",
                                                height: 200,
                                                width: 200,
                                                fit: BoxFit.scaleDown,
                                                scale: 6,
                                              ) : Image.network(
                                                data["urlImage"],
                                                height: 200,
                                                width: 200,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Container(
                                              width: (MediaQuery.of(context).size.width - 80)*0.6,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(data["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                                                  Text("Collection: ${data["amount_vocabulary_list"]}", style:  const TextStyle(fontSize: 15),),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                              );
                            }else{
                              return Center(
                                child: Text("Error", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20),),
                              );
                            }
                          })
                        ),
                        const SizedBox(height: 5,),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5), // Màu của bóng đổ
                                spreadRadius: 0, // Bán kính lan rộng của bóng đổ
                                blurRadius: 7, // Độ mờ của bóng đổ
                                offset: const Offset(0, 4), // Độ lệch của bóng đổ theo chiều dọc
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 10, top: 10),
                                child: Text("Statistical", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                              ),
                              const SizedBox(height: 20,),
                              Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 80,
                                      width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width*0.5)) - 15,
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
                                      child: Row(
                                        children: [
                                          SizedBox(width: 10,),
                                          Image.asset("assets/images/timmer.png", scale: 1.5,),
                                          SizedBox(width: 10,),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              StreamBuilder(stream: timeStream(), builder: (ctx, snapshot){
                                                if(snapshot.connectionState == ConnectionState.waiting){
                                                  return const Text("...",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),);
                                                }

                                                if(snapshot.hasData){
                                                  return Text(formatSeconds(snapshot.data!) ,style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),);
                                                }else{
                                                  return const Text("Error",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),);
                                                }
                                              }),
                                              const Text("Time",style: TextStyle(fontSize: 15),),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10,),
                                    Container(
                                      height: 80,
                                      width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width*0.5)) - 15,
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
                                      child: StreamBuilder(stream: timeStream(), builder: (ctx, datastream){
                                        if(datastream.connectionState == ConnectionState.waiting){
                                          return const Center(
                                            child: Text("...", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),),
                                          );
                                        }

                                        if(datastream.hasData){
                                          List<String> dataHanle = hanldeSecond(datastream.data!);
                                          return Row(
                                            children: [
                                              SizedBox(width: 10,),
                                              Image.asset(dataHanle[0], scale: 2.0),
                                              SizedBox(width: 10,),

                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(dataHanle[1],style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                                                  const Text("Rank",style: TextStyle(fontSize: 15),),
                                                ],
                                              )
                                            ],
                                          );
                                        }else{
                                          return const Center(
                                            child: Text("Error", style: TextStyle(color: Colors.red),),
                                          );
                                        }
                                      })
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5,),
                        Container(
                          color: Colors.white,
                          height: 120,
                          child: Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
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
                                  height: 50,
                                  width: 200,
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.logout, color: Colors.red,),
                                      SizedBox(width: 10,),
                                      Text("Log out", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )

              )
            ],
          ),
        );
      }else{
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: const Center(
              child: Text("Error data", style: TextStyle(color: Colors.red)),
            ),
          )
        );
      }
    });
  }

}