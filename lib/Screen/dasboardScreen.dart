import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:appenglish/Module/handleDataWord.dart';
import 'package:appenglish/Screen/DashBoardScreen/ScreenProfile.dart';
import 'package:appenglish/Screen/DashBoardScreen/ScreenUpVip.dart';
import 'package:appenglish/Widgets/AmountVocabulary.dart';
import 'package:appenglish/Widgets/YourVocabulary.dart';
import 'package:appenglish/Widgets/searchWordAlert.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:http/http.dart' as http;
import '../Module/word.dart';

class dasboardScreen extends StatefulWidget {
  static int time_online = 0;
  int currentSlect = 0;
  Map<String, dynamic> dataUser = {};
  bool isLoadingData = true;
  Map<String, dynamic> dataUserCloud = {};

  @override
  State<StatefulWidget> createState() => _dasboardScreen();
}

class _dasboardScreen extends State<dasboardScreen> {

  TextEditingController searchWordText = TextEditingController();

  Isolate? _isolate;
  ReceivePort _receivePort = ReceivePort();


  @override
  void initState() {
    super.initState();

    getDataUser(FirebaseAuth.instance.currentUser!.uid);
  }

  void _startIsolate() async {
    // Create Isolate and transfer sendPort to communicate to main thread
    _isolate = await Isolate.spawn(_increaseTime, _receivePort.sendPort);

    // Listen message from Isolate and update time_online
    _receivePort.listen((message) {
      dasboardScreen.time_online = message;
    });
  }

  static void _increaseTime(SendPort sendPort) {
    int time = 0;
    // Create Timer in Isolate to increase time per second
    Timer.periodic(const Duration(seconds: 1), (timer) {
      time += 1;
      sendPort.send(time);  // Transfer time has updated to main thread
    });
  }



  Future<void> getDataUser(String TokenUID) async {
    FirebaseFirestore dataFiresStore = FirebaseFirestore.instance;
    DocumentSnapshot<Map<String, dynamic>> data = await dataFiresStore
        .collection("users")
        .doc(TokenUID)
        .collection("dataAccount")
        .doc("data")
        .get();
    Map<String, dynamic>? dataUser = data.data();
    setState(() {
      widget.dataUserCloud = dataUser!;
      dasboardScreen.time_online = dataUser["time"];
    });

    _startIsolate();
  }



  void showSearchWordAleart(Word word){
    AwesomeDialog(
        dismissOnTouchOutside: false,
        headerAnimationLoop: false,
        context: context,
        dialogType: DialogType.noHeader,
        animType: AnimType.scale,
        body: searchWordAlert(word: word),
        btnOkOnPress: (){

        },
        btnOkText: "Close",
        btnOkColor: Colors.redAccent
    ).show();
  }

  Future<bool> checkDataLocal() async {
    final appDocumentDir = await path_provider.getApplicationCacheDirectory();

    // Create hive with path
    Hive.init(appDocumentDir.path);

    var dataUserLocal = await Hive.openBox("data_vocabulary_box");
    if (dataUserLocal.get("haveVocabulary") == false ||
        !dataUserLocal.containsKey("haveVocabulary")) {
      await dataUserLocal.put("amount_vocabulary", 0);
      return false;
    } else if (dataUserLocal.get("haveVocabulary") == 0) {
      return false;
    } else {
      return true;
    }
  }

  void updateUserData() async {
    var dataz = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("dataAccount")
        .doc('data')
        .get();

    if (mounted) {
      setState(() {
        widget.dataUser = dataz.data()!;
        widget.isLoadingData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoadingData) {
      updateUserData();
    }

    return Scaffold(
      backgroundColor:
      widget.currentSlect == 0 ? Colors.white : Colors.grey[200],
      bottomNavigationBar: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          height: 80,
          child: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: GNav(
              // navigation bar padding
                backgroundColor: Colors.white,
                tabBackgroundColor: const Color.fromRGBO(123, 191, 253, 1.0),
                gap: 8,
                padding: const EdgeInsets.all(10),
                onTabChange: (index) {
                  setState(() {
                    widget.currentSlect = index;
                  });
                },
                activeColor: Colors.white,
                color: const Color.fromRGBO(123, 191, 253, 1.0),
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
                ]),
          )),
      body: RefreshIndicator(
        child: ListView(
          children: [
            bodyDashBoard(),
          ],
        ),
        onRefresh: () async {
          await getDataUser(FirebaseAuth.instance.currentUser!.uid);
          setState(() {});
        },
      )

    );
  }

  bodyDashBoard() {
    if (widget.currentSlect == 0) {
      return Screen1(widget.dataUserCloud);
      //return ScreenProfile(dataClound: widget.dataUserCloud,);
    } else if (widget.currentSlect == 1) {
      return ScreenUpVip();
    } else if (widget.currentSlect == 2) {
      return ScreenProfile(
        dataClound: widget.dataUserCloud,
      );
    }
  }

  Widget Screen1(Map<String, dynamic> dataClound) {
    return Container(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      color: Colors.grey[200],
      child: SingleChildScrollView(
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
                        width: MediaQuery.of(context).size.width / 2,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "hello,",
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                dataClound["name"] ?? "Nah",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 30),
                              )
                            ],
                          ),
                        )),
                    Container(
                      width: MediaQuery.of(context).size.width / 2 - 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ClipOval(
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: Image.asset("assets/images/avata.png", fit: BoxFit.cover,)
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
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset:
                          Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: TextField(
                        controller: searchWordText,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.translate,
                            color: Colors.blue,
                          ),
                          hintText: 'search...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      String searchWord = searchWordText.text;

                      if(searchWord != ""){
                        try {
                          final response = await http.get(
                              Uri.parse('https://api.dictionaryapi.dev/api/v1/entries/en/$searchWord'));
                          if (response.statusCode == 200) {
                            var data = json.decode(response.body);
                            Word word = await handleDataWord().getWord (data, searchWord);
                            showSearchWordAleart(word);
                          }
                        } catch (error) {
                          print('Error: $error');
                        }
                      }

                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 20, right: 15),
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: const Color.fromRGBO(81, 126, 255, 1.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(81, 126, 255, 0.3),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.search, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - (180 + 80),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 150,
                          width: MediaQuery.of(context).size.width - 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Color.fromRGBO(255, 220, 168, 1.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: (MediaQuery.of(context).size.width -
                                    MediaQuery.of(context).size.width * 0.3) -
                                    80,
                                child: const Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 30, left: 10),
                                      child: Text(
                                        "GET 40% OFF",
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            color:
                                            Color.fromRGBO(141, 93, 0, 1.0)),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 0, left: 10),
                                      child: Text(
                                        "On your 1st year Membershop",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal,
                                            color:
                                            Color.fromRGBO(141, 93, 0, 1.0)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: (MediaQuery.of(context).size.width -
                                    MediaQuery.of(context).size.width * 0.6),
                                child: Image.asset(
                                    "assets/images/baner_ads_account.png"),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: AmountVocabulary().getAmountVocabulary(
                            const TextStyle(
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.bold))),
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 20),
                      child: YourVocabulary(),
                    ),
                    const SizedBox(
                      height: 250,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
