import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScreen extends StatefulWidget{

  QrScreen({super.key, required this.dataUser});

  @override
  State<StatefulWidget> createState() => _QrScreen();

  Map<String, dynamic> dataUser;


}

class _QrScreen extends State<QrScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(
            123, 191, 253, 1.0),
        iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.white),
        title: const Text("Your QrCode", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),)
      ),
      body: Container(
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
                fit: BoxFit.cover,
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
      )
    );
  }

}