import 'package:appenglish/Widgets/AmountVocabulary.dart';
import 'package:appenglish/Widgets/YourVocabulary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;


class dasboardScreen extends StatefulWidget{
  int currentSlect = 0;
  Map<String, dynamic> dataUser = {};
  bool isLoadingData = true;

  @override
  State<StatefulWidget> createState() => _dasboardScreen();
}


class _dasboardScreen extends State<dasboardScreen>{

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

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            widget.currentSlect = index;
          });
        },
        selectedIndex: widget.currentSlect,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.book),
            icon: Icon(Icons.book_outlined),
            label: 'Vocabulary',
          ),

          NavigationDestination(
            selectedIcon: Icon(Icons.account_circle),
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profile',
          ),

        ],

      ),
      // appBar: AppBar(
      //   actions: [
      //     IconButton(onPressed: (){
      //       FirebaseAuth.instance.signOut();
      //     }, icon: Icon(Icons.logout))
      //   ],
      // ),
      body: bodyDashBoard(),
    );
  }

  bodyDashBoard() {
    if(widget.currentSlect == 0){
      return Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            color: Colors.grey[200],
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  color: const Color.fromRGBO(0, 42, 160, 1.0),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipOval(
                                child: SizedBox(
                                  width: 80, // Kích thước chiều rộng của hình tròn
                                  height: 80, // Kích thước chiều cao của hình tròn
                                  child: widget.dataUser["urlImage"] == null ? Image.asset("assets/images/user.jpg") : Image.network(widget.dataUser!["urlImage"], fit: BoxFit.cover),
                                ),
                              ),
                              Column(
                                children: [
                                  SizedBox(height: 20),
                                  Padding(padding: EdgeInsets.only(left: 20),
                                    child: Text("Hey ${widget.dataUser["name"]}", style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                  )
                                ],
                              )
                            ],
                          )
                        ]
                    ),
                  ),
                ),
                const SizedBox(height: 100,),
                Container(
                  height: 350,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height - 420,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(padding: EdgeInsets.only(left: 10),
                                    child: AmountVocabulary().getAmountVocabulary(TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold))),
                                YourVocabulary(),

                                const SizedBox(height: 10,),
                                const Padding(padding: EdgeInsets.only(left: 10),
                                    child: Row(
                                      children: [
                                        Text("App Vocabulary", style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),),
                                        Icon(Icons.star, color: Colors.orange,)
                                      ],
                                    )
                                ),
                                // SingleChildScrollView(
                                //   scrollDirection: Axis.horizontal,
                                //   child: Row(
                                //     children: [
                                //       Container(
                                //         width: 150,
                                //         height: 250,
                                //         color: Colors.red,
                                //       ),
                                //       Container(
                                //         width: 150,
                                //         height: 250,
                                //         color: Colors.blue,
                                //       ),Container(
                                //         width: 150,
                                //         height: 250,
                                //         color: Colors.red,
                                //       ),
                                //       Container(
                                //         width: 150,
                                //         height: 250,
                                //         color: Colors.blue,
                                //       )
                                //     ],
                                //   ),
                                // ),
                                const Center(
                                  child: Text("App don't have vocabulary now"),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Column(
            children: [
              SizedBox(height: 130,),
              Container(
                height: 160,
                width: MediaQuery.of(context).size.width - 100,
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
                child: const Center(
                  child: Text("4 \n Collections", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                ),
              ),
            ],
          )
        ],
      );
    }else{
      return Container();
    }
  }

}