import 'package:appenglish/Module/DataBaseHelper.dart';
import 'package:appenglish/Module/word.dart';
import 'package:appenglish/Screen/vocabularyScreen.dart';
import 'package:appenglish/Module/readHive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Module/cardDataSet.dart';
import '../Screen/addVocabulary.dart';
import 'CardVocabulary.dart';

class KeepAliveListViewItem extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _KeepAliveListViewItemState();

  final firebasefirestore = FirebaseFirestore.instance;
  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot;

  KeepAliveListViewItem({required this.snapshot});
}

class _KeepAliveListViewItemState extends State<KeepAliveListViewItem> with AutomaticKeepAliveClientMixin {

  Future<Map<String, dynamic>> _getLimitSet() async{
    var data = await widget.firebasefirestore.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("dataAccount")
        .doc("data").get();
    return {
      "ammount": data.data()!["amount_vocabulary_list"],
      "vip": data.data()!["vip"]
    };
  }

  Future<int> _fetchAmount(CollectionReference collectionRef) async {
    try {
      QuerySnapshot querySnapshot = await collectionRef.get();
      return querySnapshot.size;
    } catch (error) {
      print('Đã xảy ra lỗi khi lấy số lượng tài liệu: $error');
      return 0; // Trả về 0 trong trường hợp có lỗi
    }
  }

  Future<double> _ProgressLearn(CollectionReference collectionRef) async{
    double sum = 0;
    int sumAmountWord = 0;

    try{
      QuerySnapshot querySnapshot = await collectionRef.get();
      for(var lv in querySnapshot.docs){
        sum += (((lv["level"] / 6) as double).floorToDouble());
        sumAmountWord += 1;
      }
      return sum.round()/sumAmountWord;
    }catch (error){
      print('Đã xảy ra lỗi khi lấy số lượng tài liệu: $error');
      return 0; // Trả về 0 trong trường hợp có lỗi
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.snapshot.data!.size + 1,
        itemBuilder: (BuildContext context, int index) {

          return index < widget.snapshot.data!.size ? FutureBuilder<int>(
            future: _fetchAmount(widget.snapshot.data!.docs[index].reference.collection('listVocabulary')),
            builder: (BuildContext context, AsyncSnapshot<int> amountSnapshot) {
              if (amountSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (amountSnapshot.hasError) {
                return Text("Đã xảy ra lỗi: ${amountSnapshot.error}");
              }

              int amount = amountSnapshot.data ?? 0;

              return FutureBuilder(
                  future: _ProgressLearn(widget.snapshot.data!.docs[index].reference.collection('listVocabulary')),
                  builder: (BuildContext context, AsyncSnapshot<double> amountSnapshot2){

                    double progress = amountSnapshot2.data ?? 0;

                    return Container(
                        child:CardVocabulary(
                          DataSet: cardDataSet(
                            linkImage: (widget.snapshot.data!.docs[index]).data()["image"],
                            nameSet: widget.snapshot.data!.docs[index].id.replaceAll("_", " "),
                            amoutWord: amountSnapshot.data ?? 0,
                            progress: double.parse(progress.toStringAsFixed(2)),
                          ),
                          actionfunc: () async {
                            List<Map<String, dynamic>> datas = await DataBaseHelper().getAllData("LisVoc", {
                              "tokenUID": FirebaseAuth.instance.currentUser!.uid,
                              "nameSet": widget.snapshot.data!.docs[index].id,
                            });

                            List<Map<String, dynamic>> ListWordVocabulary = [];

                            for(Map<String, dynamic> data in datas){
                              ListWordVocabulary.add({
                                "word": Word(
                                    word: data["word"],
                                    type: convertStringToEnum(data["type"]),
                                    linkUK: data["linkUK"],
                                    linkUS: data["linkUS"],
                                    phonicUK: data["phonicUK"],
                                    phonicUS: data["phonicUS"],
                                    means: data["mean"],
                                    example: data["example"]
                                ),
                                "level": data["level"]
                              });
                            }

                            List<String> dataVocabularyhaveLearn = await ReadHive().readDataLearnedTopic((await ReadHive().getHivePath()), "haveVocabulary", FirebaseAuth.instance, widget.snapshot.data!.docs[index].id);
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => vocabularyScreen(nameSet: widget.snapshot.data!.docs[index].id.replaceAll("_", " "), ListDataWord: ListWordVocabulary, Progress: double.parse(progress.toStringAsFixed(2)), ListVocabularyhaveLearn: dataVocabularyhaveLearn,))
                            );
                          },
                        )
                    );
                  });
            },
          ) :  FutureBuilder(
              future: _getLimitSet(),
              builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> data){

                if (data.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (data.hasError) {
                  return Text("Đã xảy ra lỗi: ${data.error}");
                }

                return data.data!["vip"] == true && data.data!["ammount"] < 50 ? Padding(
                  padding: EdgeInsets.only(left: 10), // Điều chỉnh khoảng cách nếu cần thiết
                  child: CardVocabularyNull(
                    paddingLeft: 0.0,
                    actionfunc: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => addVocabulary()),
                      );
                    },
                  ),
                ) : Center();
              }
          );
        },
      ),
    );
  }

}