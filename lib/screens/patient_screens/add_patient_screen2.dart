import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../custom_widgets/patient_dropdown.dart';
import '../../custom_widgets/patient_text_field.dart';

class AddPatientScreen2 extends StatefulWidget {
  AddPatientScreen2({required this.updateData, this.patientId = ''});
  Function updateData;
  String patientId;

  @override
  State<AddPatientScreen2> createState() => _AddPatientScreen2State();
}

class _AddPatientScreen2State extends State<AddPatientScreen2> {

  String phone1 = '', streetAddress = '', email = "";
  Map<String, String>? data;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String uid = '';
  FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading = true;

  updateData(){
    data = {
      'phoneNumber1' : phone1,
      'email' : email,
      'streetAddress' : streetAddress,
    };
    widget.updateData(data);
  }

  getDetails() async {
      final data = await firestore.collection('Patients').doc(uid).get();
      setState(() {
        try {
          phone1 = data['phoneNumber'];
          email = data['email'];
          streetAddress = data['streetAddress'];
        }
        catch(e){
          print(e);
          setState(() {
            isLoading = false;
          });
        }
        setState(() {
          isLoading = false;
        });
      });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.patientId.isNotEmpty){
      uid = widget.patientId;
    }
    else{
      uid = auth.currentUser!.uid;
    }
    getDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: isLoading ? Center(child: CircularProgressIndicator(color: kPrimaryColor,),) : SingleChildScrollView(
        child: Column(
          children: [
            PatientTextField(title: 'Phone no.: ', onChanged: (value){
              setState(() {
                phone1 = value;
                updateData();
              });
            }, inputType: TextInputType.number, inputValue: phone1,),
            SizedBox(height: 32,),
            PatientTextField(title: 'Email Address', inputType: TextInputType.emailAddress, onChanged: (value){
              setState(() {
                email = value;
                updateData();
              });
            }, inputValue: email,),
            SizedBox(height: 32,),
            PatientTextField(title: 'Address: ', onChanged: (value){
              setState(() {
                streetAddress = value;
                updateData();
              });
            }, inputValue: streetAddress,),
            SizedBox(height: 32,),
          ],
        ),
      ),
    );
  }
}
