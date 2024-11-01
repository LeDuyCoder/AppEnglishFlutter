import 'dart:math';

import 'package:appenglish/Module/readHive.dart';
import 'package:appenglish/Screen/exampScreen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Module/word.dart';
import '../Widgets/barChart.dart';

class vocabularyScreen extends StatefulWidget{
  vocabularyScreen({super.key, required this.nameSet, required this.ListDataWord, required this.Progress, required this.ListVocabularyhaveLearn});

  @override
  State<StatefulWidget> createState() => _vocabularyScreen();

  final String nameSet;
  final List<Map<String, dynamic>> ListDataWord;
  final double Progress;
  final List<String> ListVocabularyhaveLearn;
  final timeLoad = 3600;

}

class _vocabularyScreen extends State<vocabularyScreen>{

  AudioPlayer player = AudioPlayer();

  List<int> getAmoutLevel(){
    List<int> listAmoutlv = [0,0,0,0,0,0,0];

    for(var wordVoc in widget.ListDataWord){
      int lv = wordVoc["level"];
      listAmoutlv[lv] += 1;
    }

    return listAmoutlv;
  }

  int getAmountWordHaveLearn(){
    List<int> datas = getAmoutLevel();
    return (datas[1] + datas[2] + datas[3] + datas[4] + datas[5] + datas[6]);
  }

  Color SetColor(int Level){
    switch(Level){
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.greenAccent;
      case 4:
        return Colors.green;
      case 5:
        return Colors.blue;
      case 6:
        return Colors.blueAccent;
      default:
        return Colors.white;
    }
  }

  Stream<Timestamp> timeStream() {
    return Stream.periodic(Duration(seconds: 1), (_) => Timestamp.now());
  }
  
  List<Widget> getItem(){
    List<Widget> list = [];

    for(int index = 0; index < widget.ListDataWord.length; index++) {
      setState(() {
        list.add(
            Padding(padding: EdgeInsets.only(bottom: 10, left: 20, right: 20, top: 5),
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0, 
                      blurRadius: 1, 
                      offset: const Offset(2, 3), 
                    ),
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), 
                      spreadRadius: 0, 
                      blurRadius: 1, 
                      offset: const Offset(-2, -3), 
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(padding: EdgeInsets.only(left: 10),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 20),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [Container(
                                        height: 30,
                                        width: 30,
                                        child: CustomPaint(
                                            painter: ProgressBarPainter(
                                              percentage: (widget.ListDataWord[index] as Map)["level"]/6*100, // Phần trăm tiến trình
                                              strokeWidth: 5.0, // Độ rộng của đường viền
                                              color: SetColor((widget.ListDataWord[index] as Map)["level"]), // Màu sắc của tiến trình
                                            ),
                                            child: Center(
                                              child: Text("${(widget.ListDataWord[index] as Map)["level"]}", // Hiển thị phần trăm
                                                style: const TextStyle(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            )
                                        ),
                                      ),]
                                  ),
                                ),
                                Text(((widget.ListDataWord[index] as Map)["word"] as Word).word,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[300], fontSize: 25),
                                ),
                                Text(" - ${((widget.ListDataWord[index] as Map)["word"] as Word).type.name}",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: IconButton(
                                      icon: widget.ListVocabularyhaveLearn.contains(((widget.ListDataWord[index] as Map)["word"] as Word).word) ? const Icon(Icons.star, color: Colors.orange,) : const Icon(Icons.star_outline_outlined), onPressed: () async {
                                        setState(() {
                                          String _word = ((widget.ListDataWord[index] as Map)["word"] as Word).word;
                                          if(widget.ListVocabularyhaveLearn.contains(_word)){
                                            widget.ListVocabularyhaveLearn.remove(_word);
                                          }else{
                                            widget.ListVocabularyhaveLearn.add(_word);
                                          }
                                        });

                                        await ReadHive().writeHive((await ReadHive().getHivePath()), "haveVocabulary", FirebaseAuth.instance, widget.ListVocabularyhaveLearn, widget.nameSet);
                                      },
                                    ),
                                  )
                                ],
                              )
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                await player.play(UrlSource(((widget.ListDataWord[index] as Map)["word"] as Word).linkUK), volume: 1.0);
                              },
                              borderRadius: BorderRadius.circular(20), 
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20), 
                                  color: Colors.white.withOpacity(0.1), 
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Icon(Icons.volume_up, color: Colors.red),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 5,),
                          Text(((widget.ListDataWord[index] as Map)["word"] as Word).phonicUK, style: const TextStyle(
                              fontSize: 15
                          ),),
                        ],
                      ),
                      Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                await player.play(UrlSource(((widget.ListDataWord[index] as Map)["word"] as Word).linkUS), volume: 1.0);
                              },
                              borderRadius: BorderRadius.circular(20), 
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20), 
                                  color: Colors.white.withOpacity(0.1), 
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Icon(Icons.volume_up, color: Colors.blueAccent),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 5,),
                          Text(((widget.ListDataWord[index] as Map)["word"] as Word).phonicUS, style: const TextStyle(
                              fontSize: 15
                          ),),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
                        child: Text(((widget.ListDataWord[index] as Map)["word"] as Word).means),
                      ),
                      Padding(padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Example", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
                            Padding(padding: const EdgeInsets.only(top: 10),
                              child: Text(((widget.ListDataWord[index] as Map)["word"] as Word).example),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
        );
      });
    }

    return list;
  }

  Widget loadDataTime(dataWaiting){
    return dataWaiting.data! > 0 ? Text(formatDuration(dataWaiting.data!), style: const TextStyle(
        color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 20)) :
    const Text("It's time for revision", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),);
  }

  Future<int> getTimeSet() async {
    SharedPreferences storeData = await SharedPreferences.getInstance();
    int time = storeData.getInt('${FirebaseAuth.instance.currentUser!.uid}.time.${widget.nameSet}') ?? Timestamp.now().seconds;
    return time;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme.copyWith(
            color: Colors.white
        ),
        backgroundColor: const Color.fromRGBO(0, 42, 160, 1.0),
        title: Text(widget.nameSet, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: ScrollPhysics().parent,
            child: Container(
              child: Column(
                children: [
                  const SizedBox(height: 30,),
                  Container(
                    height: 350,
                    width: MediaQuery.of(context).size.width - 40,
                    decoration: BoxDecoration(
                      color: Colors.white, // Màu nền của button
                      borderRadius: BorderRadius.circular(10), // Đặt góc bo tròn
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), 
                          spreadRadius: 5, 
                          blurRadius: 7, 
                          offset: const Offset(0, 3), 
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 100,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20, bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Have Learned"),
                                    Row(
                                      children: [
                                        Text("${getAmountWordHaveLearn()}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                                        Text(" / ${widget.ListDataWord.length}")
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 20),
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [Container(
                                          height: 80,
                                          width: 80,
                                          child: CustomPaint(
                                              painter: ProgressBarPainter(
                                                percentage: widget.Progress*100, // Phần trăm tiến trình
                                                strokeWidth: 8.0, // Độ rộng của đường viền
                                                color: Colors.greenAccent, // Màu sắc của tiến trình
                                              ),
                                              child: Center(
                                                child: Text( '${widget.Progress * 100}%', // Hiển thị phần trăm
                                                  style: const TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              )
                                          ),
                                        ),]
                                    ),
                                  )
                              )
                            ],
                          ),
                        ),
                        BarChartSample8(listLevelVoca: getAmoutLevel()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Container(
                    height: 150,
                    width: MediaQuery.of(context).size.width - 40,
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[200], // Màu nền của button
                      borderRadius: BorderRadius.circular(10), // Đặt góc bo tròn
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), 
                          spreadRadius: 5, 
                          blurRadius: 7, 
                          offset: const Offset(0, 3), 
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 200,
                          child: Padding(
                              padding: EdgeInsets.only(left: 5, top: 10),
                              child: Column(
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.error_outline, color: Colors.grey,),
                                      SizedBox(width: 5,),
                                      Text("You should learn again", style: TextStyle(fontWeight: FontWeight.bold),),
                                    ],
                                  ),
                                  Padding(padding: const EdgeInsets.only(left: 5),
                                    child: Row(
                                      children: [
                                        const Text("after  ", style: TextStyle(fontWeight: FontWeight.bold),),

                                        FutureBuilder(future: getTimeSet(), builder: (context, dataTimeSet){
                                          SharedPreferences? storeData;
                                          return StreamBuilder(stream: timeStream(), builder: (ctx, data) {
                                            Future<int> calculateMillitime() async {
                                              int TimeAgain = data.data!.seconds - dataTimeSet.data!;
                                              int time = widget.timeLoad -(TimeAgain);

                                              storeData ??= await SharedPreferences
                                                    .getInstance();

                                              if(!storeData!.containsKey("${FirebaseAuth.instance.currentUser!.uid}.time.${widget.nameSet}")) {
                                                storeData!.setInt('${FirebaseAuth.instance.currentUser!.uid}.time.${widget.nameSet}', dataTimeSet.data!);
                                              }

                                              return time;
                                            }

                                            if(data.hasData){
                                              return FutureBuilder(future: calculateMillitime(), builder: (ctx, dataWaiting){
                                                if(dataWaiting.hasData){
                                                  return loadDataTime(dataWaiting);
                                                }else{
                                                  return const Text("error");
                                                }
                                              });
                                            }else {
                                              return const Text("0h:0m:0s", style: TextStyle(
                                                  color: CupertinoColors.activeBlue),);
                                            }
                                          });
                                        })
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20,),
                                  FutureBuilder(future: getTimeSet(), builder: (context, dataTimeSet){
                                    return StreamBuilder(stream: timeStream(), builder: (ctx, data) {
                                      Future<int?> calculateMillitime() async {
                                        return widget.timeLoad - (data.data!.seconds - dataTimeSet.data!);
                                      }

                                      if(data.hasData){
                                        return FutureBuilder(future: calculateMillitime(), builder: (ctx, dataWaiting){
                                          if(dataWaiting.hasData){
                                            return Container(
                                              height: 67,
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.vertical,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    //SharedPreferences dataStore = await SharedPreferences.getInstance();
                                                    //dataStore.setInt('${FirebaseAuth.instance.currentUser!.uid}.time.${widget.nameSet}', Timestamp.now().seconds);
                                                    bool reivew = (dataWaiting.data??0)<=0;
                                                    print(reivew);
                                                    if(widget.ListVocabularyhaveLearn.length >= 1) {
                                                      Navigator.of(context)
                                                          .push(
                                                          MaterialPageRoute(
                                                              builder: (ctx) =>
                                                                  exampScreen(
                                                                      topic: widget
                                                                          .nameSet,
                                                                      statuse: reivew)));
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color.fromRGBO(0, 42, 160, 1.0), // Màu nền của nút
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10), // Đặt góc bo tròn
                                                    ),
                                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                                                  ),
                                                  child: Text(dataWaiting.data! <= 0 ? 'Review' : 'Learn New Word', style: TextStyle(color: Colors.white),),
                                                ),
                                              ),
                                            );
                                          }else{
                                            return Container(
                                              width: 63,
                                              height: 63,
                                              child: const RiveAnimation.asset(
                                                "assets/Rive/loading.riv",
                                                fit: BoxFit.fill,
                                              ),
                                            );
                                          }
                                        });
                                      }else {
                                        return Container(
                                          width: 63,
                                          height: 63,
                                          child: const RiveAnimation.asset(
                                            "assets/Rive/loading.riv",
                                            fit: BoxFit.scaleDown,
                                          ),
                                        );
                                      }
                                    });
                                  })

                                ],
                              ),
                          )
                        ),
                        const SizedBox(width: 10,),
                        SizedBox(
                          width: 120,
                          child: Image.asset("assets/images/note.png"),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Column(
                    children: getItem(),
                  )
                ],
              ),
            ),
          ),
        ),
      )
    );
  }


  String formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds ~/ 60) % 60;
    int remainingSeconds = seconds % 60;

    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');

    return '${hoursStr}h:${minutesStr}m:${secondsStr}s';
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await ReadHive().writeHive((await ReadHive().getHivePath()), "haveVocabulary", FirebaseAuth.instance, widget.ListVocabularyhaveLearn, widget.nameSet);
    //await ReadHive().getAllTime((await ReadHive().getHivePath()), "haveVocabulary", FirebaseAuth.instance);
    //print(ReadHive().getAllTime((await ReadHive().getHivePath()), "haveVocabulary", FirebaseAuth.instance));
  }
}

class ProgressBarPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color color;

  ProgressBarPainter({required this.percentage, required this.strokeWidth, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint trackPaint = Paint()
      ..color = Colors.grey[300]! // Màu sắc của đường viền
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Paint progressPaint = Paint()
      ..color = color // Màu sắc của tiến trình
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2) - strokeWidth / 2;

    canvas.drawCircle(center, radius, trackPaint);

    double arcAngle = 2 * pi * (percentage / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      arcAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}