import 'package:appenglish/Module/word.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class alertWrong extends StatefulWidget{
  const alertWrong({super.key, required this.anwser, required this.word});

  @override
  State<StatefulWidget> createState() => _alertWrong();

  final String anwser;
  final Word word;

}

class _alertWrong extends State<alertWrong>{
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("😰 Wrong !", textAlign: TextAlign.left, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),),
          const SizedBox(height: 10,),
          const Text("Your answer", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20),),
          Text(widget.anwser, style: const TextStyle(fontSize: 18),),
          const SizedBox(height: 10,),
          const Text("Answer", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 20),),
          Container(
            height: 160,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.word.word, textAlign: TextAlign.left, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),),
                  Text(widget.word.type.name),
                  Row(
                    children: [
                      const Text("UK", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            //await player.play(UrlSource(((widget.ListDataWord[index] as Map)["word"] as Word).linkUS), volume: 1.0);
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
                      const Text("US", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            //await player.play(UrlSource(((widget.ListDataWord[index] as Map)["word"] as Word).linkUS), volume: 1.0);
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
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

}