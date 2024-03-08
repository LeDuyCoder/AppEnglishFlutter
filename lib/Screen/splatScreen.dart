import 'dart:async';
import 'dart:convert';

import 'package:appenglish/Screen/mainScreen.dart';
import 'package:appenglish/flutter_awesome_alert_box.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class splatScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _splatScreen();
  double process = 0;
  Timer? _timer;
  var _responseData;
  late BuildContext contextAll;
}


class _splatScreen extends State<splatScreen>{


  Future<void> fetchData() async {
    try {
      // Gọi API
      final response = await http.get(Uri.parse('https://api.npoint.io/e00f658fac808c7f708d'));

      // Kiểm tra mã trạng thái của response
      if (response.statusCode == 200) {
        // Chuyển đổi dữ liệu JSON thành Dart Map
        final data = json.decode(response.body);
        setState(() {
          // Cập nhật dữ liệu trả về từ API
          widget._responseData = data;
        });
        print(widget._responseData);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      // Xử lý lỗi
      print('Error: $error');
    }
  }

  void _startTimer() {
    // Tạo một Timer lặp lại mỗi 5 giây
    widget._timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if(widget.process < 1.0) {
        setState(() {
          widget.process += 0.1;
        });
      } else {
        final contextAll = widget.contextAll;
        if (widget._responseData != null && widget._responseData!['version'] != "1.0.0") {
          ShowBoxErrorVersion(widget._responseData!["noteWrongVersion"]);
        } else {
          Navigator.pushReplacement(
            contextAll,
            MaterialPageRoute(builder: (context) => mainScreen()),
          );
          }
      }
    });
  }

  @override
  void initState() {
    _startTimer();
    fetchData();
  }

  void ShowBoxErrorVersion(String content){
    WarningAlertBox(
        context: widget.contextAll,
        title: "Warming",
        messageText: content,
        buttonColor: Colors.white,
        buttonText: "OK",
        buttonTextColor: Colors.black,
        icon: Icons.warning_amber
    );
  }

  @override
  Widget build(BuildContext context) {
    widget.contextAll = context;
    return Scaffold(
      body: Stack(
        children: [
          Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/images/iconapp.png", scale: 0.8,),
              const Text("App English", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),),
              const SizedBox(height: 35,),

              const Text("Loading..."),
              SizedBox(
                width: 300,
                child: LinearProgressIndicator(
                  value: widget.process, // Giá trị của thanh loading, từ 0.0 đến 1.0
                  backgroundColor: Colors.grey[300], // Màu nền của thanh loading
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green), // Màu của phần đã hoàn thành
                ),
              )
            ],
            )
          ),
          const Positioned(
              bottom: 0,
              right: 10,
              child: Text("version 1.0.0")
          ),
        ],
      ),
    );
  }

}