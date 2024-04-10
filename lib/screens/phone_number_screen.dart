import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goa_dental_clinic/classes/alert.dart';
import 'package:goa_dental_clinic/classes/pref.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/nav_screen.dart';
import 'package:pinput/pinput.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../custom_widgets/custom_button.dart';

class PhoneNumberScreen extends StatefulWidget {
  
  PhoneNumberScreen({required this.phoneNumber,  required this.verId, required this.name, required this.email, required this.role});
  String phoneNumber, verId, name, email, role;

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  bool isVerified = true, isVerifyButtonVisible = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  bool codeSent = false;
  TextEditingController otpController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> resendCode(BuildContext context) async {

    await auth.verifyPhoneNumber(
      phoneNumber: '${widget.phoneNumber}',
      verificationCompleted: (PhoneAuthCredential credential) async {
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            '$e',
            style: TextStyle(fontFamily: 'Gilroy',fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),);
      },
      codeSent: (String verificationId, int? resendToken) {
        setState((){
          codeSent = true;
          widget.verId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> verifyCode() async {
    print(widget.verId + otpController.text);
    try{
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: widget.verId, smsCode: otpController.text);
      await auth.signInWithCredential(credential);

      uploadData();
      storeLocally();
      
      Navigator.push(context, MaterialPageRoute(builder: (context) => NavScreen()));

    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          '$e',
          style: TextStyle(fontFamily: 'Gilroy',fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),);    }
  }

  storeLocally() async {
    try {
      // Pref('token', 'token').storeString();
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString('name', widget.name);
      pref.setString('token', 'token');
      pref.setString('role', widget.role);
      pref.setString('email', widget.email);
    }
    catch(e){
      Alert(context, 'Error: $e');
    }
    // SharedPreferences pref = await SharedPreferences.getInstance();
    // print(pref.get('token'));
  }

  uploadData() async {
    Map<String, dynamic> doctor = {
      'name' : widget.name,
      'email' : widget.email,
      'phoneNumber' : widget.phoneNumber,
      'token' : 'token',
      'role' : widget.role,
      'uid' : auth.currentUser!.uid,
    };

    try {
      await firestore.collection('Doctors').doc(auth.currentUser!.uid).set(doctor);
    }
    catch(e){
      Alert(context, 'Error: $e');
    }

  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: GestureDetector(onTap: (){Navigator.pop(context);}, child: Icon(Icons.arrow_back_ios, color: kGrey,)), toolbarHeight: 40,),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Container(
                    child: Center(child: SvgPicture.asset('svgs/phone_login.svg', height: size.height * 0.3,)),
                  ),
                SizedBox(height: 24,),
                Text('Enter OTP', style: kBigText,),
                SizedBox(height: 16,),
                Text('Otp has been sent !', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),),
                SizedBox(height: 16,),
                Text('A 6 digit code has been sent to the number ${widget.phoneNumber}', style: TextStyle(fontSize: 16),),
                SizedBox(height: 24,),
                Pinput(
                  keyboardType: TextInputType.phone,
                  length: 6,
                  controller: otpController,
                  onChanged: (value){
                    if(value.length == 6){
                      setState(() {
                        isVerifyButtonVisible = true;
                      });
                    }
                  },
                ),
                SizedBox(height: 24,),
                Center(child: InkWell(onTap: (){
                  resendCode(context);
                }, child: Text('Resend code', style: TextStyle(color: kButtonBlue, fontWeight: FontWeight.bold),))),
                SizedBox(height: 24,),
                Visibility(
                  visible: isVerifyButtonVisible,
                  child: CustomButton(text: 'Verify', backgroundColor: kButtonBlue, onPressed: (){
                      setState(() {
                        isVerified = false;
                      });
                      verifyCode();
                  }, isLoading: (!isVerified && isVerifyButtonVisible), loadingWidget: Center(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: Colors.white,),
                  ),),),
                ),
                Visibility(child: SizedBox(height: 24,), visible: isVerifyButtonVisible,),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'In case the number entered is wrong ? ',
                      style: TextStyle(color: kGrey, fontSize: 15),
                    ),
                    TextSpan(
                        text: 'Edit number',
                        style: TextStyle(
                          color: kButtonBlue,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,),
                        recognizer: TapGestureRecognizer()..onTap = (){
                          Navigator.pop(context);
                        }
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
