import 'dart:async';

import 'package:appenglish/Module/DataBaseHelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'InfomationFriendScreen.dart';

class listFriendScreen extends StatefulWidget{

  listFriendScreen({super.key, required this.dataCound});

  @override
  State<StatefulWidget> createState() => _listFriendScreen();

  Map<String, dynamic> dataCound;

}

class _listFriendScreen extends State<listFriendScreen>{

  Future<List<Map<String, dynamic>>> hanldeDataListFriend() async{
    var db = DataBaseHelper();
    List<Map<String, dynamic>> dataList = <Map<String, dynamic>>[];
    List<dynamic> listFriend = widget.dataCound["list_friend"];

    if(listFriend.isNotEmpty){
      for (var element in listFriend) {
        Map<String, dynamic> dataFriendinDatabase = await db.getDataFriend({"TokenUID": element});
        if(dataFriendinDatabase.isNotEmpty){
          dataList.add(dataFriendinDatabase);
        } else {
          DocumentSnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance.collection("users").doc(element).collection("dataAccount").doc("data").get();
          Map<String, dynamic> dataFriend = data.data()!;
          Map<String, String> dataToAdd = {
            'tokenUID': element,
            'title': '${dataFriend['title']} - ${dataFriend["name"]}',
            'linkImag': dataFriend['urlImage'] ?? 'null'
          };
          await db.insertFirends(dataToAdd);
          dataList.add(dataToAdd);
        }
      }
    }

    return dataList;
  }

  @override
  Widget build(BuildContext context) {

    hanldeDataListFriend();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Chiều cao của AppBar
        child: CustomAppBar(),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SizedBox(height: 20,),
              FutureBuilder(future: hanldeDataListFriend(), builder: (ctx, data){
                if(data.connectionState == ConnectionState.waiting){
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue,),
                  );
                }

                print(data.error);

                if(data.hasData){
                  if(data.data!.isNotEmpty){
                    return Container(
                      width: MediaQuery.of(context).size.width - 20,
                      height: MediaQuery.of(context).size.height,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: widget.dataCound["list_friend"].length,
                        itemBuilder: (ctx, index){
                          String dataFriendsUID = widget.dataCound["list_friend"][index];

                          return GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (ctx) => InfomationFriendScreen(TokenUID: dataFriendsUID)));
                            },
                            child: Container(
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 10.0, // Độ mờ của đổ bóng
                                    offset: Offset(0, 4), // Độ dịch chuyển của đổ bóng
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                      width: 100,
                                      height: 120,
                                      child: ClipRect(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                            "assets/images/avata.png",
                                            fit: BoxFit.cover, // You can use cover to make sure the image fills the area
                                            width: 70, // Set your desired width
                                            height: 70, // Set your desired height
                                          ),
                                        ),
                                      )
                                  ),
                                  SizedBox(
                                    height: 120,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(((data.data![index]['title']).split("-")[1]).substring(1), style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
                                        Text((data.data![index]['title']).split("-")[0], style: TextStyle(fontSize: 15),),
                                      ],
                                    ),
                                  ),
                                  const Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Icon(Icons.keyboard_arrow_right, size: 30,),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  else{
                    return const Text("No Friends", style: TextStyle(color: Colors.black),);
                  }
                }else{
                  return const Center(
                    child: Text("Error", style: TextStyle(color: Colors.red),),
                  );
                }
              }),
          ],
        ),
      ),
    ),
    );
  }

}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 10.0, // Độ mờ của đổ bóng
            offset: Offset(0, 4), // Độ dịch chuyển của đổ bóng
          ),
        ],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25.0), // Bo góc trái trên
          bottomRight: Radius.circular(25.0), // Bo góc phải trên
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text("List Friends"),// Loại bỏ đổ bóng mặc định của AppBar
      ),
    );
  }
}