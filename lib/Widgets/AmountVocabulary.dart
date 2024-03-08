import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AmountVocabulary{
   Widget getAmountVocabulary(TextStyle txtStyle){
     return StreamBuilder(
         stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('yourVocabularry').snapshots(),
         builder: (ctx, snapshot){
           if(snapshot.connectionState == ConnectionState.waiting){
             return Text("Your Vocabulary -/1", style: txtStyle); // Bọc chuỗi trong widget Text và trả về
           }
           if(snapshot.hasError){
             return Text("Error: ${snapshot.error}", style: txtStyle,); // Bọc chuỗi trong widget Text và trả về
           }


           if(!snapshot.hasData || snapshot.data!.docs.isEmpty) {
             return Text("Your Vocabulary 0/1", style: txtStyle,);
           }

           // Xử lý dữ liệu snapshot ở đây (nếu cần)
           // Ví dụ:
           final data = snapshot.data;
           return Text(data as String); // Bọc chuỗi trong widget Text và trả về
         }
     );
  }

}