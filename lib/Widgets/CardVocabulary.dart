import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class CardVocabularyNull extends StatelessWidget {
  const CardVocabularyNull({super.key, required this.actionfunc});

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
                color: Colors.grey.withOpacity(0.5), // Màu của bóng đổ
                spreadRadius: 5, // Bán kính lan rộng của bóng đổ
                blurRadius: 7, // Độ mờ của bóng đổ
                offset: Offset(0, 3), // Độ lệch của bóng đổ theo chiều dọc
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
