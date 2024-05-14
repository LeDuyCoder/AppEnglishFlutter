import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:appenglish/Screen/DashBoardScreen/ScreenProfile.dart';
import 'package:appenglish/Screen/DashBoardScreen/ScreenUpVip.dart';
import 'package:appenglish/Widgets/AmountVocabulary.dart';
import 'package:appenglish/Widgets/YourVocabulary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive/hive.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:http/http.dart' as http;
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';


class dasboardScreen extends StatefulWidget{
  static int time_online = 1295000;

  int currentSlect = 0;
  Map<String, dynamic> dataUser = {};
  bool isLoadingData = true;

  Map<String, dynamic> dataUserCloud = {};

  @override
  State<StatefulWidget> createState() => _dasboardScreen();
}


class _dasboardScreen extends State<dasboardScreen> {

  Future<void> getDataUser(String TokenUID) async{
    FirebaseFirestore dataFiresStore = FirebaseFirestore.instance;
    DocumentSnapshot<Map<String, dynamic>> data = await dataFiresStore.collection("users").doc(TokenUID).collection("dataAccount").doc("data").get();
    Map<String, dynamic>? dataUser = data.data();
    widget.dataUserCloud = dataUser!;

    isolateFunction();
  }


  Future<void> isolateFunction() async {

    try {
      final response = await http.get(Uri.parse('https://www.landernetwork.io.vn/backend_api/data_api.php?type=getTime&UID=${FirebaseAuth.instance.currentUser!.uid}'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body)[0][0];
        dasboardScreen.time_online = int.parse(data["timeOnline"]);
      }
    } catch (error) {}

    Timer.periodic(Duration(seconds: 1), (timer) {
      // Cộng giá trị cho biến mỗi giây
      dasboardScreen.time_online += 1;
    });
  }

  @override
  void initState() {
    super.initState();


    getDataUser(FirebaseAuth.instance.currentUser!.uid);

  }


  Future<bool> checkDataLocal() async {
    final appDocumentDir = await path_provider.getApplicationCacheDirectory();

    // Khởi tạo Hive với đường dẫn được cung cấp
    Hive.init(appDocumentDir.path);

    var dataUserLocal = await Hive.openBox("data_vocabulary_box");

    //var dataUserLocal = await Hive.box("data_vocabulary_box");
    if(dataUserLocal.get("haveVocabulary") == false || !dataUserLocal.containsKey("haveVocabulary")){
      await dataUserLocal.put("amount_vocabulary", 0);
      return false;
    }else if(dataUserLocal.get("haveVocabulary") == 0){
      return false;
    } else{
      return true;
    }
  }

  void updateUserData() async {
    var dataz = await FirebaseFirestore.instance.collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("dataAccount")
        .doc('data')
        .get();

    if(mounted) {
      setState(() {
        widget.dataUser = dataz.data()!;
        widget.isLoadingData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.isLoadingData) {
      updateUserData();
    }

    return LifecycleWrapper(
      onLifecycleEvent: (LifecycleEvent event) async {
        var sendData = true;

        if (event == LifecycleEvent.inactive) {
          String UID_user = FirebaseAuth.instance.currentUser!.uid;
          int timeOnline = dasboardScreen.time_online; // Hàm này bạn cần tự định nghĩa để lấy giá trị time_online
          if(sendData){
            http.get(Uri.parse('https://landernetwork.io.vn/backend_api/setData.php?UID=$UID_user&time_online=$timeOnline'));
            sendData = false;
          }
        }else if(event == LifecycleEvent.visible && event == LifecycleEvent.active){
          sendData = true;
        }
      },
      child: Scaffold(
        backgroundColor: widget.currentSlect == 0 ? Colors.white : Colors.grey[200],
        bottomNavigationBar: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5), // Màu của bóng đổ
                  spreadRadius: 5, // Bán kính lan rộng của bóng đổ
                  blurRadius: 7, // Độ mờ của bóng đổ
                  offset: const Offset(0, 3), // Độ lệch của bóng đổ theo chiều dọc
                ),
              ],
            ),
            height: 80,
            child: Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: GNav(// navigation bar padding
                  backgroundColor: Colors.white,
                  tabBackgroundColor: const Color.fromRGBO(123, 191, 253, 1.0),
                  gap: 8,
                  padding: const EdgeInsets.all(10),
                  onTabChange: (index){
                    setState(() {
                      widget.currentSlect = index;
                    });
                  },
                  activeColor: Colors.white,
                  color: Color.fromRGBO(123, 191, 253, 1.0),
                  tabs: const [
                    GButton(
                      icon: Icons.home,
                      text: 'Home',
                    ),
                    GButton(
                      icon: Icons.star,
                      text: 'Vip',
                    ),
                    GButton(
                      icon: Icons.account_circle_outlined,
                      text: 'Profile',
                    )
                  ]
              ),
            )
        ),
        body: bodyDashBoard(),
      ),
    );
  }

  bodyDashBoard(){
    if(widget.currentSlect == 0){
      return Screen1();
      //return ScreenProfile(dataClound: widget.dataUserCloud,);
    } else if(widget.currentSlect == 1){
      return ScreenUpVip();
    } else if(widget.currentSlect == 2){
      return ScreenProfile(dataClound: widget.dataUserCloud,);
    }
  }

  Widget Screen1(){
    return Container(
      color: Colors.grey[200],
      child: Column(
        children: [
          Container(
            height: 100,
            child: Padding(
              padding: EdgeInsets.only(left: 10, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(

                      width: MediaQuery.of(context).size.width/2,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("hello,", style: TextStyle(fontSize: 20),),
                            Text(widget.dataUser["name"] == null ? "Nah" : widget.dataUser["name"], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),)
                          ],
                        ),
                      )
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width/2 - 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 60, // Kích thước chiều rộng của hình tròn
                            height: 60, // Kích thước chiều cao của hình tròn
                            child: widget.dataUser["urlImage"] == null ? Image.asset("assets/images/user.jpg") : Image.network(widget.dataUser!["urlImage"], fit: BoxFit.cover),
                          ),
                        )
                      ],

                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 15, right: 15, top: 20),
                  height: 50,
                  width: MediaQuery.of(context).size.width - 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Màu của bóng đổ
                        spreadRadius: 5, // Bán kính lan rộng của bóng đổ
                        blurRadius: 7, // Độ mờ của bóng đổ
                        offset: Offset(0, 3), // Độ lệch của bóng đổ theo chiều dọc
                      ),
                    ],
                  ),
                  child: const Center(
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.translate, color: Colors.blue,),
                        hintText: 'search...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){},
                  child: Container(
                    margin: EdgeInsets.only(top: 20, right: 15),
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Color.fromRGBO(81, 126, 255, 1.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(81, 126, 255, 0.3), // Màu của bóng đổ
                          spreadRadius: 5, // Bán kính lan rộng của bóng đổ
                          blurRadius: 7, // Độ mờ của bóng đổ
                          offset: Offset(0, 3), // Độ lệch của bóng đổ theo chiều dọc
                        ),
                      ],
                    ),
                    child: Icon(Icons.search, color: Colors.white),
                  ),

                )
              ],
            ),
          ),
          SizedBox(height: 10,),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - (180 + 80),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20,),
                  Center(
                    child: GestureDetector(
                      onTap: (){},
                      child: Container(
                        height: 150,
                        width: MediaQuery.of(context).size.width - 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Color.fromRGBO(255, 220, 168, 1.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.3), // Màu của bóng đổ
                              spreadRadius: 5, // Bán kính lan rộng của bóng đổ
                              blurRadius: 7, // Độ mờ của bóng đổ
                              offset: Offset(0, 3), // Độ lệch của bóng đổ theo chiều dọc
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: (MediaQuery.of(context).size.width - MediaQuery.of(context).size.width*0.3) - 80,
                              child: const Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 30, left: 10),
                                    child: Text("GET 40% OFF", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color.fromRGBO(141, 93, 0, 1.0)),),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 0, left: 10),
                                    child: Text("On your 1st year Membershop", style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Color.fromRGBO(141, 93, 0, 1.0)),),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              width: (MediaQuery.of(context).size.width - MediaQuery.of(context).size.width*0.6),
                              child: Image.asset("assets/images/baner_ads_account.png"),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Padding(padding: const EdgeInsets.only(left: 10),
                      child: AmountVocabulary().getAmountVocabulary(const TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold))),
                  YourVocabulary(),
                  Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          const Text("App Vocabulary", style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),),
                          SizedBox(width: 5,),
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Image.asset("assets/images/vip_account.png", fit: BoxFit.cover,),
                          )
                        ],
                      )
                  ),
                  Container(
                    height: 180,
                    width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Đặt hướng cuộn là ngang
                      child: FutureBuilder(
                        future: getDataApi(),
                        builder: (ctx, dataResult) {
                          if (dataResult.connectionState == ConnectionState.waiting) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (dataResult.hasData) {
                            return Row(
                              children: List.generate(dataResult.data.length, (index) {
                                return GestureDetector(
                                  onTap: (){

                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(left: 10),
                                    height: 150,
                                    width: 320,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 7,
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.zero,
                                          child: SizedBox(
                                            width: (320 - 320 * 0.6) - 10,
                                            child: dataResult.data[index]["Image"] == 'null' ? Image.asset("assets/images/baner_ads_account.png") : Image.network(dataResult.data[index]["Image"]),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 10),
                                          width: 320 - 320 * 0.4,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 10),
                                              Text(dataResult.data[index]["Topic"], style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                                              SizedBox(
                                                height: 55,
                                                child: SingleChildScrollView(
                                                  scrollDirection: Axis.vertical,
                                                  child: Text(dataResult.data[index]["Description"], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 30,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(5.0),
                                                      color: Color.fromRGBO(108, 140, 254, 1.0),
                                                      boxShadow: const [
                                                        BoxShadow(
                                                          color: Color.fromRGBO(108, 140, 254, 0.3),
                                                          spreadRadius: 5,
                                                          blurRadius: 7,
                                                          offset: Offset(0, 3),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Padding(
                                                      padding: EdgeInsets.all(5),
                                                      child: Container(
                                                        child: Image.asset("assets/images/lesson.png"),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Row(
                                                    children: [
                                                      FutureBuilder(future: getDataApiWord(dataResult.data[index]["Topic"]), builder: (ctx2, dataWords){
                                                        if(dataWords.connectionState == ConnectionState.waiting){
                                                          return CircularProgressIndicator();
                                                        }

                                                        if(dataWords.hasData){
                                                          return Text("${dataWords.data.length}");
                                                        }else{
                                                          return Text("Nah");
                                                        }
                                                      }),
                                                      Text(" Words")
                                                    ],
                                                  )

                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            );
                          } else {
                            return const Center(
                              child: Text("App don't have vocabulary now"),
                            );
                          }
                        },
                      ),
                    ),
                  ),



                  SizedBox(height: 250,),
                  // FutureBuilder(future: getDataApi(), builder: (ctx, dataResult){
                  //   if(dataResult.connectionState == ConnectionState.waiting){
                  //     return const Center(
                  //       child: CircularProgressIndicator(),
                  //     );
                  //   }
                  //
                  //   if(dataResult.hasData){
                  //
                  //     return Container(
                  //       height: 50,
                  //       width: 250,
                  //     );
                  //   }else{
                  //     return Center(
                  //       child: Text("App don't have vocabulary now"),
                  //     );
                  //   }
                  // }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }





  Future<dynamic> getDataApi() async{
    try {
      final response = await http.get(Uri.parse('https://landernetwork.io.vn/backend_api/data_api.php?type=listopic'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data[0];
      } else {
        return {};
      }
    } catch (error) {
      return {};
    }
  }

  Future<dynamic> getDataApiWord(String topic) async{
    try{
      final response = await http.get(Uri.parse('https://www.landernetwork.io.vn/backend_api/data_api.php?type=listvocabulary&topic=$topic'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data[0];
      } else {
        return {};
      }
    } catch (error){
      return {};
    }
  }
}