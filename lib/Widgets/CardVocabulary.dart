import 'package:appenglish/Module/cardDataSet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

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
          width: 160,
          height: 200,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0), // Độ cong của góc trên bên trái
                  topRight: Radius.circular(20.0), // Độ cong của góc trên bên phải
                ),
                child: Image.network(
                  DataSet.linkImage,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover, // Điều chỉnh phù hợp với kích thước của hình ảnh
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                    return Text('Không thể tải ảnh'); // Hiển thị tin nhắn nếu không thể tải ảnh
                  },
                ),
              ),
              Text(DataSet.nameSet, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25), textAlign: TextAlign.center,),
              Text("${DataSet.amoutWord} Words", style: TextStyle(fontSize: 15), textAlign: TextAlign.center,),
              SizedBox(height: 10,),
              Container(
                width: 140.0, // Điều chỉnh chiều rộng của thanh tiến trình
                child: Column(
                  children: <Widget>[
                    LinearProgressIndicator(
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(20),
                      backgroundColor: Colors.grey[200], // Màu nền của thanh tiến trình
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green), // Màu của phần tiến trình
                      value: DataSet.progress, // Giá trị phần trăm hoàn thành (ví dụ: 60%)
                    ),

                    Center(
                      child: Text(
                        '${DataSet.progress * 100}%', // Phần trăm hoàn thành (ví dụ: 60%)
                        style: const TextStyle(
                          color: Colors.black, // Màu của chữ
                          fontWeight: FontWeight.bold, // Độ đậm của chữ
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}