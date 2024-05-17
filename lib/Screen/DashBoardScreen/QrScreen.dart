import 'package:appenglish/Screen/DashBoardScreen/ScreenScanQR.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScreen extends StatefulWidget{

  QrScreen({super.key, required this.dataUser});

  @override
  State<StatefulWidget> createState() => _QrScreen();

  Map<String, dynamic> dataUser;
  int screen = 0;


}

class _QrScreen extends State<QrScreen>{

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(
            123, 191, 253, 1.0),
        iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.white),
        title: const Text("Your QrCode", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),)
      ),
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
                      widget.screen = index;
                    });
                  },
                  activeColor: Colors.white,
                  color: Color.fromRGBO(123, 191, 253, 1.0),
                  tabs: const [
                    GButton(
                      icon: Icons.qr_code_2,
                      text: 'MyQr',
                    ),
                    GButton(
                      icon: Icons.qr_code_scanner,
                      text: 'Scan Qr',
                    ),
                  ]
              ),
            )
        ),
      body: widget.screen == 0 ? Screen1() : Screen2(),
    );

  }

  Widget Screen1(){
    return Container(
        color: const Color.fromRGBO(123, 191, 253, 1.0),
        child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [

                SizedBox(height: 50,),
                widget.dataUser["urlImage"] == null
                    ? Image.asset(
                  "assets/images/avata.png",
                  height: 120,
                  width: 250,
                  fit: BoxFit.scaleDown,
                )
                    : Image.network(
                  widget.dataUser["urlImage"],
                  height: 250,
                  width: 250,
                  fit: BoxFit.cover,
                ),// Khoảng cách giữa hình ảnh và văn bản
                // Widget văn bản
                Flexible(
                  child: Text(
                    widget.dataUser["name"],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                    overflow: TextOverflow.ellipsis, // Để tránh văn bản quá dài
                  ),
                ),
                SizedBox(height: 50,),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 250,
                      width: 250,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white
                      ),
                    ),
                    QrImageView(
                      data: FirebaseAuth.instance.currentUser!.uid,
                      version: QrVersions.auto,
                      size: 250.0,
                    ),
                  ],
                ),
              ],
            )
        )
    );
  }

  Widget Screen2(){
    return ScreenScanQR();
  }
}