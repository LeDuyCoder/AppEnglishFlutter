import 'package:appenglish/Screen/dasboardScreen.dart';
import 'package:appenglish/Screen/loginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class mainScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _mainScreen();

}

class _mainScreen extends State<mainScreen>{
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, snapshot) {
        if(snapshot.hasData){
          return dasboardScreen();
        }

        return loginScreen();
      },
    );
  }

}