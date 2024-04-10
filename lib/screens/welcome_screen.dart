import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/nav_screen.dart';
import 'package:goa_dental_clinic/screens/register_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    // restore();
    nextScreen();
  }

  restore() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signInWithEmailAndPassword(email: 'rounakpro18@gmail.com', password: '1689567476423');
    print(auth.currentUser);
  }

  nextScreen() async {
    // await auth.signOut();

    await Timer(Duration(seconds: 2), () {
      if(auth.currentUser == null)
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      else
      Navigator.push(context, MaterialPageRoute(builder: (context) => NavScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SvgPicture.asset('svgs/logo.svg', height: size.height * 0.5, width: size.width * 0.5,),
        ),
      ),
    );
  }
}


