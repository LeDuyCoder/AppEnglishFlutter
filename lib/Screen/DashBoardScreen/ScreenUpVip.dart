import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ScreenUpVip extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScreenUpVip();

}

class _ScreenUpVip extends State<ScreenUpVip>{

  Widget Screen2(BuildContext context){
    var Data = {
      ["📱 multi-device synchronization", true, true, true],
      ["✍️ Limit your set 50", false, true, false],
      ["📚 Set vocabulary of app", false, true, true],
      ["💳 Card NFC share information", false, true, false]
    };

    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 250,
          child: RiveAnimation.asset("assets/Rive/background_vip_up.riv", fit: BoxFit.cover,),
        ),
        Container(
          height: MediaQuery.of(context).size.height - 80,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50,),
                const Padding(
                  padding: EdgeInsets.only(top: 10, left: 30),
                  child: Text("Upgrade Accoun PRO!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                ),
                const SizedBox(height: 10,),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3), // Màu của đường viền
                        width: 1, // Độ dày của đường viền
                      ),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    width: MediaQuery.of(context).size.width - 40,
                    height: 250,
                    child: DataTable(
                        columns: const <DataColumn>[
                          DataColumn(label: Text('')),
                          DataColumn(label: Text("Free")),
                          DataColumn(label: Text("Pro")),
                        ],
                        rows: Data.map((data) {
                          return DataRow(
                            color: MaterialStateColor.resolveWith((states) => data[3] == true ? const Color.fromRGBO(0, 0, 0, 0.1) : Color.fromRGBO(255, 255, 255, 0.5),),
                            cells: <DataCell>[
                              DataCell(Text("${data[0]}")),
                              DataCell(
                                  data[1] == true ? Container(
                                    height: 25,
                                    width: 25,
                                    child: Image.asset("assets/images/right.png"),
                                  ) : Container(
                                    height: 20,
                                    width: 20,
                                    child: Image.asset("assets/images/wrong.png"),
                                  )
                              ),
                              DataCell(
                                  data[2] == true ? Container(
                                    height: 25,
                                    width: 25,
                                    child: Image.asset("assets/images/right.png"),
                                  ) : Container(
                                    height: 20,
                                    width: 20,
                                    child: Image.asset("assets/images/wrong.png"),
                                  )
                              ),
                            ],
                          );
                        }).toList()
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10, left: 30),
                  child: Text("Pro packages", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                ),
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 10,),
                      Container(
                          width: MediaQuery.of(context).size.width - 40,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color.fromRGBO(255, 235, 178, 1.0),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 20, top: 10),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("3 Tháng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                                    Row(
                                      children: [
                                        Text("100.000 đ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                        Text(" (đ33,333/tháng)", style: TextStyle(fontSize: 15),)
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                  child: Container(
                                    height: 70,
                                    width: 40,
                                    child: Align(
                                      alignment: AlignmentDirectional.centerEnd,
                                      child: Icon(Icons.navigate_next, size: 40,),
                                    ),
                                  )
                              )
                            ],
                          )
                      ),
                      SizedBox(height: 10,),
                      Container(
                          width: MediaQuery.of(context).size.width - 40,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color.fromRGBO(255, 235, 178, 1.0),
                          ),
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 20, top: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Hàng năm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                                    Row(
                                      children: [
                                        Text("500.000 đ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                        Text(" (đ41.666/tháng)", style: TextStyle(fontSize: 15),)
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                  child: Container(
                                    height: 70,
                                    width: 40,
                                    child: Align(
                                      alignment: AlignmentDirectional.centerEnd,
                                      child: Icon(Icons.navigate_next, size: 40,),
                                    ),
                                  )
                              )
                            ],
                          )
                      ),
                      SizedBox(height: 10,),
                      Container(
                          width: MediaQuery.of(context).size.width - 40,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color.fromRGBO(255, 201, 74, 1.0), // Màu của đường viền
                              width: 2, // Độ dày của đường viền
                            ),
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 30,
                                child: Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(left: 10, top: 5),
                                      child: Text("Vĩnh Viễn", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomLeft: Radius.circular(20)),
                                              color: Color.fromRGBO(255, 201, 74, 1.0),
                                            ),
                                            width: 150,
                                            height: 30,
                                            child: const Center(
                                              child: Text("sales 42%", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 10, top: 10),
                                    child: Column(
                                      children: [
                                        const Row(
                                          children: [
                                            Text("1.900.000 đ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough, color: Colors.grey),),
                                            Text(" 999.000 đ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),)
                                          ],
                                        ),
                                        SizedBox(height: 5,),
                                        Container(
                                            width: 150,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                              color: Colors.red,
                                            ),
                                            child: timeWait()
                                        )
                                      ],
                                    ),
                                  ),
                                  const Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Icon(Icons.navigate_next, size: 35,),
                                    ),
                                  )
                                ],
                              )
                            ],
                          )
                      ),
                      SizedBox(height: 10,),
                      Text("Do You want buy Pro packages", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15,)),
                      SizedBox(height: 10,),
                      GestureDetector(
                        onTap: (){
                          _launchUrl('https://www.facebook.com/le.huuduy.752/');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.blue,
                          ),
                          width: MediaQuery.of(context).size.width - 120,
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.facebook, color: Colors.white,),
                              SizedBox(width: 10,),
                              Text("Connect to facebook admin", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),)
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 50,),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget timeWait() {
    return FutureBuilder(
      future: getDataTimeSale(),
      builder: (ctx, dataRs) {
        if (dataRs.connectionState == ConnectionState.waiting) {
          return Text("...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center);
        }

        if (dataRs.hasData) {
          return StreamBuilder(
            stream: timeStream(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center);
              }

              if (snapshot.hasData) {
                if (snapshot.data!.seconds - dataRs.data! >= 108000) {
                  setTimeAgains();
                }

                return Text("Time: ${formatSeconds((10800 - (snapshot.data!.seconds - dataRs.data!)))}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center);
              } else { // Trường hợp không có dữ liệu hoặc lỗi
                return Text("Unknown error ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center);
              }
            },
          );
        }  else { // Trường hợp không có dữ liệu hoặc lỗi
          return Text("Unknown error ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center);
        }
      },
    );
  }

  Future<void> _launchUrl(String _url) async {
    if (!await launchUrl(Uri.parse(_url))) {
      throw Exception('Could not launch $_url');
    }
  }

  String formatSeconds(int seconds) {
    // Tính toán số giờ, phút và giây từ số giây đầu vào
    int hours = seconds ~/ 3600;
    int remainingSeconds = seconds % 3600;
    int minutes = remainingSeconds ~/ 60;
    int remainingMinutes = remainingSeconds % 60;

    // Tạo chuỗi định dạng xxh:xxm:xxs
    String formattedTime = '${hours.toString().padLeft(2, '0')}h:'
        '${minutes.toString().padLeft(2, '0')}m:'
        '${remainingMinutes.toString().padLeft(2, '0')}s';

    return formattedTime;
  }

  Stream<Timestamp> timeStream(){
    return Stream.periodic(Duration(seconds: 1), (_) => Timestamp.now());
  }

  Future<int> getDataTimeSale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey("setting_system_time")){
      int? dataCall = prefs.getInt("setting_system_time");
      return dataCall ?? 0;
    }else{
      int second = Timestamp.now().seconds;
      prefs.setInt('setting_system_time', second);
      return second;
    }
  }

  Future<void> setTimeAgains() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int second = Timestamp.now().seconds;
    prefs.setInt('setting_system_time', second);
  }

  @override
  Widget build(BuildContext context) {
    return Screen2(context);
  }

}