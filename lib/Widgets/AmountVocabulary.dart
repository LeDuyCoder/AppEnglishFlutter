import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AmountVocabulary{
   Widget getAmountVocabulary(TextStyle txtStyle){
     return StreamBuilder(
         stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection("dataAccount").doc("data").snapshots(),
         builder: (ctx, snapshot){
           if(snapshot.connectionState == ConnectionState.waiting){
             return Text("Your Vocabulary -/-", style: txtStyle); // Bọc chuỗi trong widget Text và trả về
           }
           if(snapshot.hasError){
             return Text("Error: ${snapshot.error}", style: txtStyle,); // Bọc chuỗi trong widget Text và trả về
           }

           DocumentSnapshot docSnapshot = snapshot.data!;

           final data = docSnapshot["amount_vocabulary_list"];
           bool vip = docSnapshot["vip"];

           if(vip){
             return Text("Your Vocabulary ${data}/50", style: txtStyle);
           }else{
             return Text("Your Vocabulary ${data}/1", style: txtStyle);
           }
         }
     );
  }

}