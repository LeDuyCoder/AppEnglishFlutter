import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Module/word.dart';

class searchWordAlert extends StatefulWidget {
  const searchWordAlert({super.key, required this.word});

  @override
  State<StatefulWidget> createState() => _searchWordAlert();

  final Word word;

}

class _searchWordAlert extends State<searchWordAlert>{

  AudioPlayer player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(widget.word.word, textAlign: TextAlign.left, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),),
                        SizedBox(width: 10,),
                        Text('[ ${widget.word.type.name} ]', style: TextStyle(fontSize: 15),),
                      ],
                    ),
                    Row(
                      children: [
                        const Text("UK", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              await player.play(UrlSource(widget.word.linkUK), volume: 1.0);
                            },
                            borderRadius: BorderRadius.circular(20), // Điều chỉnh độ cong của góc
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20), // Điều chỉnh độ cong của góc
                                color: Colors.white.withOpacity(0.1), // Màu nền khi nhấn
                              ),
                              child: const Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Icon(Icons.volume_up, color: Colors.black54),
                              ),
                            ),
                          ),
                        ),
                        Text(widget.word.phonicUK, style: const TextStyle(color: Colors.grey),)
                      ],
                    ),
                    Row(
                      children: [
                        const Text("US", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              await player.play(UrlSource(widget.word.linkUS), volume: 1.0);
                            },
                            borderRadius: BorderRadius.circular(20), // Điều chỉnh độ cong của góc
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20), // Điều chỉnh độ cong của góc
                                color: Colors.white.withOpacity(0.1), // Màu nền khi nhấn
                              ),
                              child: const Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Icon(Icons.volume_up, color: Colors.black54),
                              ),
                            ),
                          ),
                        ),
                        Text(widget.word.phonicUS, style: const TextStyle(color: Colors.grey),)
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Text(widget.word.means),
                    const SizedBox(height: 5,),
                    Text(widget.word.example)
                  ]
                ),
              ),
            ),
          ]
        ),
    );
  }

}