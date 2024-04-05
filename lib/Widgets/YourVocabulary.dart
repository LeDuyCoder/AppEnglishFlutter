import 'package:appenglish/Module/cardDataSet.dart';
import 'package:appenglish/Screen/addVocabulary.dart';
import 'package:appenglish/Widgets/CardVocabulary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'KeepAliveListViewItem.dart';

class YourVocabulary extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _YourVocabulary();

  final firebasefirestore = FirebaseFirestore.instance;

}

class _YourVocabulary extends State<YourVocabulary> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.firebasefirestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('VocabularyData')
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return CardVocabularyNull(
            paddingLeft: 10,
            actionfunc: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => addVocabulary()),
              );
            },
          );
        } else {
          return KeepAliveListViewItem(snapshot: snapshot);
        }
      },
    );
  }

}