import 'package:appenglish/Module/DataBaseHelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class registerScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _registerScreen();
  var isSeePass = true;
}

class _registerScreen extends State<registerScreen>{

  final _form = GlobalKey<FormState>();

  var _email = '';
  var _pass = '';
  var _repass = '';


  void showSnackBarError(String msg){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(msg,
          style: const TextStyle(color: Colors.white),),
      ),
    );
  }

  void regAccount() async{
    var db = FirebaseFirestore.instance;
    String createID(int number) {
      String formattedNumber = number.toString().padLeft(6, '0');
      return "#$formattedNumber";
    }


    if(_email != '' && _pass != '' && _repass != '') {
      if (_pass == _repass) {
        try {
          final UserCredential account = await _firebase.createUserWithEmailAndPassword(email: _email, password: _pass);

          QuerySnapshot users = await db.collection("users").get();
          var amountUser = users.docs.length;

          db.collection("users").doc(account.user!.uid).collection("dataAccount").doc("data").set(
            {
              "name": "User${createID(amountUser+1)}",
              "title": "newbie",
              "email": _email,
              "vip": false,
              "amount_vocabulary_list": 0,
              'limit_vocabulary': 100,
              'list_friend': <String>[],
              'time': 0
            }
          );

          DataBaseHelper().insertDataAuthentical(_email);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Create account success",
                style: TextStyle(color: Colors.white),),
            ),
          );

          Future.delayed(Duration(seconds: 5), () {
            Navigator.of(context).pop();
          });

        }on FirebaseAuthException catch (e){
            print(e.code);
            if(e.code == "email-already-in-use"){
              showSnackBarError("Email already in use");
            }
          }
        } else {
          showSnackBarError("Password and Re-Password are not the same.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.white),
        backgroundColor: const Color.fromRGBO(0, 42, 160, 1.0),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20,),
                const Text("SignUp", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),),
                const SizedBox(height: 50,),
                Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: TextFormField(
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15), // Điều chỉnh khoảng cách giữa nội dung và viền
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      validator: (value) {
                        if(value!.trim().isEmpty){
                          return "Email cannot be empty";
                        } else if (!value.trim().contains("@")) {
                          return 'Invalid email format';
                        }

                        _email = value;
                      },
                    ),
                ),
                const SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: TextFormField(
                    obscureText: widget.isSeePass,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        suffixIcon: IconButton(
                          icon: widget.isSeePass == false ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off),
                          onPressed: (){
                            setState(() {
                              widget.isSeePass = !widget.isSeePass;
                            });
                          },
                        )//
                    ),
                    validator: (value){
                      if(value!.trim().isEmpty){
                        return "Password cannot be empty";
                      }

                      _pass = value;
                    },
                  ),
                ),
                const SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: TextFormField(
                    obscureText: widget.isSeePass,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      labelText: 'Re-Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    validator: (value){
                      if(value!.trim().isEmpty){
                        return "Re-Password cannot be empty";
                      }

                      _repass = value;
                    },
                  ),
                ),
                const SizedBox(height: 50,),
                ElevatedButton(
                  onPressed: () {
                    final isValid = _form.currentState!.validate();
                    if(isValid){
                      _form.currentState!.save();
                    }
                    regAccount();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 42, 160, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 12),
                  ),
                  child: const Text('Register', style: TextStyle(color: Colors.white),),
                ),
                SizedBox(height: 30,),
                RichText(
                  text: TextSpan(
                    text: 'Aready have an account? ',
                    style: TextStyle(color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Login', // Từ cuối có thể nhấp vào
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline, // Gạch chân từ cuối
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).pop();
                          },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  
}