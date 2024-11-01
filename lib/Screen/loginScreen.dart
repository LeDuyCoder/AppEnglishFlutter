import 'dart:ffi';

import 'package:appenglish/Module/DataBaseHelper.dart';
import 'package:appenglish/Module/word.dart';
import 'package:appenglish/Screen/registerScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sqflite/sqflite.dart';

import '../local_notifications.dart';

class loginScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _loginScreen();
  var isSeePass = true;
}

class _loginScreen extends State<loginScreen>{
  final _form = GlobalKey<FormState>();

  var _email = '';
  var _pass = '';

  void showSnackBarError(String msg){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(msg,
          style: const TextStyle(color: Colors.white),),
      ),
    );
  }

  Future<void> showGoogleSignInDialog(BuildContext context) async {
    const List<String> scopes = <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ];

    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: scopes,
    );

    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print('login failed: $error');

    }
  }

  void login() async {
    if(_email != '' && _pass != ''){
      try {
        final loginAccount = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _pass);
        if (loginAccount.user != null){
          print("login success");
          if(await DataBaseHelper().isData(loginAccount.user!.uid) == false){
            await DataBaseHelper().insertDataAuthentical(_email);
            await hanldUpdateDataWorld(loginAccount, true);
          }else{
            await hanldUpdateDataWorld(loginAccount, false);
          }
        }
        else{
          print("check error login failed");
        }
      }on FirebaseAuthException catch(e){
        print(e.code);
        if(e.code == "invalid-credential"){
          showSnackBarError("Invalid username or password");
        }
      }
    }
  }


  Future<void> hanldUpdateDataWorld(UserCredential loginAccount, bool firstLogin) async{
    try {
      CollectionReference vocabularyDataCollection = FirebaseFirestore.instance
          .collection("users")
          .doc(loginAccount.user!.uid)
          .collection("VocabularyData");

      QuerySnapshot querySnapshot = await vocabularyDataCollection.get();

      Map<String, dynamic> dataList = {};


      await Future.forEach(querySnapshot.docs, (doc) async {
        CollectionReference listVocabulary = vocabularyDataCollection.doc(doc.id).collection("listVocabulary");
        QuerySnapshot querySnapshot2 = await listVocabulary.get();
        Map<String, dynamic> listTopic = {};
        await Future.forEach(querySnapshot2.docs, (element) async {

          DocumentSnapshot<Object?> dataVocabulary = await listVocabulary.doc(element.id).get();
          listTopic[element.id] = dataVocabulary.data();
        });

        dataList[doc.id] = [(doc.data() as Map<String, dynamic>)["image"], listTopic];
        if(firstLogin) {
          await DataBaseHelper().insertSet(doc.id);
        }
      });

      for (var entry in dataList.entries) {
        var key = entry.key;
        var value = entry.value;

        Map<String, dynamic> wordMap = value[1] as Map<String, dynamic>;
        List<Word> dataListWord = []; // Create a new list for each key

        for (var wordEntry in wordMap.entries) {
          var keyWord = wordEntry.key;
          var valueWord = wordEntry.value as Map<String, dynamic>;

          dataListWord.add(Word(
              word: keyWord,
              type: convertStringToEnum(valueWord["type"]),
              linkUK: valueWord["linkUK"],
              linkUS: valueWord["linkUS"],
              phonicUK: valueWord["phonicUK"],
              phonicUS: valueWord["phonicUS"],
              means: valueWord["mean"],
              example: valueWord["example"],
              level: valueWord["level"]
          ));
        }

        print('Words for key $key: ${dataListWord.length}');
        await DataBaseHelper().addVocabulary(dataListWord, key);
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height/2.5,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(0, 42, 160, 1.0),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(50.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const Text("Wellcome", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 35),),
                  Form(
                      key: _form,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 350,
                            child: TextFormField(
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Colors.white),
                                prefixIcon: Icon(Icons.mail, color: Colors.white,),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              validator: (value){
                                if(value!.trim().isEmpty){
                                  return "Email cannot be empty";
                                } else if (!value.trim().contains("@")) {
                                  return 'Invalid email format';
                                }

                                _email = value;
                              },
                            ),
                          ),
                          SizedBox(
                            width: 350,
                            child: TextFormField(
                              obscureText: widget.isSeePass,
                              style:  const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: const TextStyle(color: Colors.white),
                                prefixIcon: const Icon(Icons.key, color: Colors.white,),
                                suffixIcon: IconButton(
                                  icon: Icon(widget.isSeePass == false ? Icons.visibility : Icons.visibility_off, color: Colors.white,), // Icon của nút bấm
                                  onPressed: (){
                                    setState(() {
                                      widget.isSeePass = !widget.isSeePass;
                                    });
                                  },
                                ),
                                border: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              validator: (value){
                                if(value!.trim().isEmpty){
                                  return "Password cannot be empty";
                                }
                                _pass = value;
                              },
                            ),
                          ),
                          SizedBox(height: 20,),
                          ElevatedButton(
                            onPressed: () {
                              final isValid = _form.currentState!.validate();
                              if(isValid){
                                _form.currentState!.save();
                              }
                              login();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 12),
                            ),
                            child: const Text('Login', style: TextStyle(color: Colors.white),),
                          )
                        ],
                      )
                  )

                ],
              ),
            ),
            const SizedBox(height: 50,),
            const Text("need an account ?", style: TextStyle(color: Colors.grey),),
            const SizedBox(height: 30,),
            GestureDetector(
              onTap: () {
                showSnackBarError("Poor don't have money to update");
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/googleicon.png',
                    width: 30,
                    height: 30,
                  ),
                ),
              ),
            ),
            SizedBox(height: 80,),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (ctx) => registerScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(0, 42, 160, 1.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 12),
              ),
              child: const Text('Sign Up', style: TextStyle(color: Colors.white),),
            )
          ],
        ),
      )
    );
  }

}