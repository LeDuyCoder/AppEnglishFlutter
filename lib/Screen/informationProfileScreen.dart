import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class informationProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _informationProfileScreen();
}

class _informationProfileScreen extends State<informationProfileScreen>{

  TextEditingController nameUserText = TextEditingController();

  bool isLoading = false;

  Future<Map<String, dynamic>> getDataUser(String TokenUID) async {
    FirebaseFirestore dataFiresStore = FirebaseFirestore.instance;
    DocumentSnapshot<Map<String, dynamic>> data = await dataFiresStore
        .collection("users")
        .doc(TokenUID)
        .collection("dataAccount")
        .doc("data")
        .get();
    Map<String, dynamic>? dataUser = data.data();
    return dataUser??{};

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 246, 200, 1.0),
        centerTitle: true,
        title: Text("Setting", style: TextStyle(color: Colors.grey, fontFamily: "Mali", fontWeight: FontWeight.bold),),
      ),
      body: FutureBuilder(future: getDataUser(FirebaseAuth.instance.currentUser!.uid), builder: (context, data){
        nameUserText.text = data.data!["name"];

        return Container(
          color: Colors.white,
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
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
                        child: Image.asset(
                          "assets/images/avata.png",
                          height: 250,
                          width: 250,
                          fit: BoxFit.scaleDown,
                          scale: 4,
                        )
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
                    child: Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20,),
                          const Text("Name", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 20),),
                          const SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5), // Màu và độ mờ của shadow
                                  spreadRadius: 2, // Bán kính lan rộng của shadow
                                  blurRadius: 5, // Độ mờ của shadow
                                  offset: Offset(0, 3), // Độ lệch của shadow (x, y)
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10), // Cùng bán kính với TextField để đồng bộ
                            ),
                            child: TextField(
                              keyboardType: TextInputType.text,
                              controller: nameUserText,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none, // Loại bỏ viền để chỉ thấy shadow
                                ),
                                filled: true, // Thêm màu nền cho TextField để nổi bật với shadow
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 30,),
                          Center(
                            child: GestureDetector(
                              onTap: () async {
                                setState(() {
                                  isLoading = !isLoading;
                                });
                                FirebaseFirestore dataFiresStore = FirebaseFirestore.instance;
                                await dataFiresStore
                                    .collection("users")
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection("dataAccount")
                                    .doc("data")
                                    .update({
                                      "name": nameUserText.text,
                                    });
                                setState(() {
                                  isLoading = !isLoading;
                                });

                              },
                              child: Container(
                                  height: 70,
                                  width: 200,
                                  decoration:  BoxDecoration(
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
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.save, color: Colors.blue,),
                                      SizedBox(width: 10,),
                                      Text("Save", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20),),
                                    ],
                                  )
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )

              ),
              if(isLoading)
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height,
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.blue,),
                  ),
                )
            ],
          ),
        );
      })
    );
  }

}