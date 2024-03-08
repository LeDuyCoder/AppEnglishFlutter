import 'package:appenglish/Screen/addVocabulary.dart';
import 'package:appenglish/Widgets/CardVocabulary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class YourVocabulary extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _YourVocabulary();

}

class _YourVocabulary extends State<YourVocabulary> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('yourVocabularry').snapshots(),
        builder: (ctx, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if(!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return CardVocabularyNull(actionfunc: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => addVocabulary())
              );
            },);
          }

          if(snapshot.hasError){
            return const Center(child: Text("Something went wrong..."),);
          }

          return Center();
        }
    );
  }

}