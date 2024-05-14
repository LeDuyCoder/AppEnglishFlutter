import 'package:appenglish/Module/cardDataSet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:hive/hive.dart';

class CardVocabularyNull extends StatelessWidget {
  const CardVocabularyNull({super.key,required this.paddingLeft, required this.actionfunc, });

  final double paddingLeft;
  final VoidCallback actionfunc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: paddingLeft),
      child: GestureDetector(
        onTap: this.actionfunc,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1), // Màu của bóng đổ
                spreadRadius: 5, // Bán kính lan rộng của bóng đổ
                blurRadius: 10, // Độ mờ của bóng đổ
                offset: Offset(-4, 2), // Độ lệch của bóng đổ theo chiều dọc
              ),
            ],
          ),
          width: 160,
          height: 200,
          child: const Center(
            child: Icon(
              Icons.add,
              size: 80,
            ),
          ),
        ),
      ),
    );
  }
}


class CardVocabulary extends StatelessWidget {
  const CardVocabulary({super.key, required this.DataSet, required this.actionfunc});

  final cardDataSet DataSet;
  final VoidCallback actionfunc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10),
      child: GestureDetector(
        onTap: this.actionfunc,
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1), // Màu của bóng đổ
                  spreadRadius: 0, // Bán kính lan rộng của bóng đổ
                  blurRadius: 0, // Độ mờ của bóng đổ
                  offset: Offset(4, 2), // Độ lệch của bóng đổ theo chiều dọc
                ),
              ],
            ),
            width: 250,
            //height: 200,
            child: Stack(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      DataSet.linkImage,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover, // Điều chỉnh phù hợp với kích thước của hình ảnh
                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                        return Text('Không thể tải ảnh'); // Hiển thị tin nhắn nếu không thể tải ảnh
                      },
                    ),
                ),
                Container(
                  width: 250,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(0, 0, 0, 0.5),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DataSet.nameSet, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white), textAlign: TextAlign.center,),
                            Text("${DataSet.amoutWord} Words", style: TextStyle(fontSize: 15, color: Colors.white), textAlign: TextAlign.center,),
                            SizedBox(height: 10,),
                            Container(
                              width: 150, // Điều chỉnh chiều rộng của thanh tiến trình
                              child: Column(
                                children: <Widget>[
                                  LinearProgressIndicator(
                                    minHeight: 5,
                                    borderRadius: BorderRadius.circular(20),
                                    backgroundColor: Colors.grey[200], // Màu nền của thanh tiến trình
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green), // Màu của phần tiến trình
                                    value: DataSet.progress, // Giá trị phần trăm hoàn thành (ví dụ: 60%)
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10,),
                          ],
                        )
                      ),
                    ],
                  ),
                )
              ],
            ),
        ),
      ),
    );
  }
}