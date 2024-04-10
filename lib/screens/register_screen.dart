import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:goa_dental_clinic/classes/pref.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/nav_screen.dart';
import 'package:goa_dental_clinic/screens/patient_screens/add_patient_screen.dart';
import 'package:goa_dental_clinic/screens/phone_number_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants.dart';
import '../custom_widgets/custom_button.dart';
import '../custom_widgets/google_button.dart';
import '../custom_widgets/icon_textfield.dart';

class RegisterScreen extends StatefulWidget {

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String phoneNumber = '';
  String name = '', email = '';
  FirebaseAuth auth = FirebaseAuth.instance;
  late String role = 'doctor';
  bool isDoc = true;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late String uid;
  String userToken = '';
  bool isLoading = false, showError = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = auth.currentUser!.uid;
    phoneNumber = auth.currentUser!.phoneNumber!;
    getAndSetToken();
  }

  uploadUser() async {
    setState(() {
      isLoading = true;
    });

    String pass = '';
    if(role == 'doctor'){
      pass = DateTime.now().millisecondsSinceEpoch.toString();
      AuthCredential emailCredentials = EmailAuthProvider.credential(email: email, password: pass);
    await auth.currentUser?.linkWithCredential(emailCredentials);
  }
    await firestore.collection('Users').doc(uid).set(
      {
        'name' : name,
        'phoneNumber' : phoneNumber,
        'email' : email,
        'role' : role,
        'uid' : uid,
        'token' : userToken,
        'setup' : 1,
        'pass': pass,
        'accessToken': (role != 'doctor') ? 'No token' :  null,
      }
    );

    if(role == 'doctor'){
      await firestore.collection('Doctors').doc(uid).set(
        {
          'name' : name.trim(),
          'phoneNumber' : phoneNumber.trim(),
          'uid' : uid.trim(),
          'role' : role.trim(),
          'email' : email.trim(),
          'token' : userToken.trim(),
        }
      );
    }else{
      await firestore.collection('Patients').doc(uid).set(
          {
            'patientName' : name.trim(),
            'phoneNumber' : phoneNumber.trim(),
            'patientUid' : uid.trim(),
            'role' : role.trim(),
            'email' : email.trim(),
            'token' : userToken.trim(),
          }
      );
    }
    await storeLocally();
    setState(() {
      isLoading = true;
    });
    if(role == 'doctor')
      Navigator.push(context, MaterialPageRoute(builder: (context) => NavScreen()));
    else
      Navigator.push(context, MaterialPageRoute(builder: (context) => AddPatientScreen()));
  }

  bool isValid(){
    if(name.isEmpty || email.isEmpty)
      return false;
    if(!email.contains('@'))
      return false;
    return true;
  }

  storeLocally() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('role', role.trim());
    pref.setString('name', name.trim());
    pref.setString('email', email.trim());
  }

  Future<String> getAndSetToken() async {
    try {
      await FirebaseMessaging.instance.getToken().then((token) {
        setState(() {
          userToken = token!;
        });
      });
      return userToken;

    }
    catch (e) {
      print("COOOOOOL $e");
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 40,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Align(child: Text('Welcome $name!', style: TextStyle(color: Colors.black, fontSize: 24),), alignment: AlignmentDirectional.centerStart,),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'hero1',
                  child: Container(
                    height: size.height * 0.2,
                    child: SvgPicture.asset('svgs/logo.svg'),
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                Text(
                  'Register',
                  style: kBigText,
                ),
                SizedBox(
                  height: 24,
                ),
                IconTextField(
                  icon: Icons.person_outline,
                  hintText: 'Name',
                  errorText: (showError) ? ((name.isEmpty) ? 'Name cannot be empty' : null) : null,
                  onChanged: (newValue){
                    setState(() {
                      name = newValue;
                    });
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                IconTextField(
                  icon: Icons.alternate_email,
                  hintText: 'Email',
                  errorText: (showError) ? (email.isEmpty ? 'Email cannot be empty' : (!email.endsWith('@gmail.com') ? 'Enter a valid email' : null)) : null,
                  onChanged: (newValue){
                    setState(() {
                      email = newValue;
                    });
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                IconTextField(
                  icon: Icons.phone_outlined,
                  inputType: TextInputType.phone,
                  errorText: (phoneNumber.isEmpty) ? 'Phone number cannot be empty' : null,
                  hintText: 'Phone Number (Ex. +919320000000)',
                  onChanged: (newValue){
                    setState(() {
                      phoneNumber = newValue;
                    });
                  },
                  inputValue: phoneNumber,
                  readOnly: true,
                ),
                SizedBox(
                  height: 16,
                ),
                Text('Select your role', style: TextStyle(fontSize: 16),),
                SizedBox(height: 8,),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(value: 'doctor', groupValue: role, onChanged: (value){
                        if(value == 'doctor')
                          setState(() {
                            role = value.toString();
                            isDoc = true;
                          });
                      },
                        title: Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: size.height * 0.15,
                          width: size.height * 0.15,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: (role == 'doctor') ? Colors.blue : Colors.white),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Expanded(child: SvgPicture.asset('svgs/doctors.svg')),
                                SizedBox(height: 8,),
                                Text('Doctor', style: TextStyle(color: (role == 'doctor') ? Colors.white : Colors.black),)
                              ],
                            ),
                          ),
                        ),
                      ),),
                    ),
                    Expanded(
                      child: RadioListTile(value: 'patient', groupValue: role, onChanged: (value){
                        if(value == 'patient')
                          setState(() {
                            role = value.toString();
                            isDoc = false;
                          });
                      }, title:
                      Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: size.height * 0.15,
                          width: size.height * 0.15,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: (role == 'patient') ? Colors.blue : Colors.white),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Expanded(child: SvgPicture.asset('svgs/login.svg')),
                                SizedBox(height: 8,),
                                Text('Patient', style: TextStyle(color: (role == 'patient') ? Colors.white : Colors.black),)
                              ],
                            ),
                          ),
                        ),
                      ),),
                    ),
                  ],
                ),
                SizedBox(height: 16,),
                CustomButton(
                  text: 'Register',
                  isLoading: false,
                  loadingWidget: Center(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: Colors.white,),
                  ),),
                  backgroundColor: kButtonBlue,
                  onPressed: () {
                    if(isValid()) {
                      print('$role');
                      uploadUser();
                    }
                    else {
                      setState(() {
                        showError = true;
                      });
                    }
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => PhoneNumberScreen(phoneNumber: phoneNumber)));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
