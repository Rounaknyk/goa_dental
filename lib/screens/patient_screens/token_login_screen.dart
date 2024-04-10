import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/classes/alert.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/nav_screen.dart';

import '../../custom_widgets/icon_textfield.dart';

class TokenLoginScreen extends StatefulWidget {
  const TokenLoginScreen({Key? key}) : super(key: key);

  @override
  State<TokenLoginScreen> createState() => _TokenLoginScreenState();
}

class _TokenLoginScreenState extends State<TokenLoginScreen> {

  String token = '';
  FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: InkWell(onTap: (){
        Navigator.pop(context);
      },child: Icon(Icons.arrow_back_ios_new_outlined, color: kGrey,)), title: Text('Login with access token', style: TextStyle(color: Colors.black),), centerTitle: false,),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset('assets/logo.png'),
                IconTextField(
                  icon: Icons.text_fields,
                  hintText: 'Access token',
                  onChanged: (newValue) {
                    setState(() {
                      token = newValue;
                    });
                  },
                ),
                SizedBox(height: 32,),
                CustomButton(text: 'LOGIN', backgroundColor: kPrimaryColor, onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  try {
                    await auth.signInWithEmailAndPassword(
                        email: '$token@gmail.com', password: '$token');
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> NavScreen()));
                  }catch(e){
                    Alert(context, e);
                  }
                  setState(() {
                    isLoading = false;
                  });
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
