import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class Cagratulate extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _Cagratulate();
}

class _Cagratulate extends State<Cagratulate>{
  AudioPlayer player = AudioPlayer();
  
  @override
  Widget build(BuildContext context) {
    player.play(AssetSource("Music/success_sound.mp3"));
    
    return Scaffold(
      body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 350,
                child: const RiveAnimation.asset(
                  "assets/Rive/congratulations.riv",
                  fit: BoxFit.scaleDown,
                ),
              ),
              const Text("Congratulate !", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 35),),
              const Text("You have some word up memory"),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(padding: EdgeInsets.only(left: 50, right: 50),
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(0, 42, 160, 1.0), // button's color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50), // set border
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Come Back', style: TextStyle(color: Colors.white),),
                              SizedBox(width: 10,),
                              Icon(Icons.logout, color: Colors.white,)
                            ],
                          )
                      ),
                    )
                  ],
                ),
              )
            ],
          )
      )
    );
  }
}