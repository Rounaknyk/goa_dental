import 'package:age_calculator/age_calculator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/providers/add_patient_provider.dart';
import 'package:goa_dental_clinic/providers/pd_provider.dart';
import 'package:googleapis/connectors/v1.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../../custom_widgets/patient_dropdown.dart';
import '../../custom_widgets/patient_text_field.dart';
import 'package:provider/provider.dart' as pro;

class AddPatientScreen1 extends StatefulWidget {
  AddPatientScreen1({required this.updateData, this.status = 'normal', this.patientId = ''});
  String status;
  String patientId;
  Function updateData;

  @override
  State<AddPatientScreen1> createState() => _AddPatientScreen1State();
}

class _AddPatientScreen1State extends State<AddPatientScreen1> {
  String gender = '';
  String patientName = '',
      patientId = '',
      dob = '';
  Map<String, String>? data;
  DateTime? pickedDate;
  TextEditingController dobController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String uid = '';
  bool isLoading = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  String phone1 = '', streetAddress = '', email = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.status == 'normal'){
      uid = auth.currentUser!.uid;
    }
    if(widget.patientId.isNotEmpty){
      uid = widget.patientId;
    }
    getName();
    getDetails();
    WidgetsBinding.instance.addPostFrameCallback((_) => updateData());

  }

  getDetails() async {
    // print("eraasf");
    // patientName = pro.Provider.of<PdProvider>(context, listen: false).name;
    // print("address: ${patientName}");
    // emailController.text = pro.Provider.of<PdProvider>(context, listen: false).email;
    // dobController.text = pro.Provider.of<PdProvider>(context, listen: false).dob;
    // phoneController.text = pro.Provider.of<PdProvider>(context, listen: false).phone;
    // gender = pro.Provider.of<PdProvider>(context, listen: false).gender;
    // addressController.text = pro.Provider.of<PdProvider>(context, listen: false).address;
    // print("address: ${addressController.text}");
    // print("address: ${patientName}");
    // print("asda");

    try {
      setState(() {
        isLoading = true;
      });
      final data = await firestore.collection('Patients').doc(uid).get();
        gender = data['gender'];
        dobController.text = data['dob'];
        dob = dobController.text;
        phone1 = data['phoneNumber'];
        phoneController.text = phone1;
        email = data['email'];
        emailController.text = email;
        streetAddress = data['streetAddress'];
        addressController.text = streetAddress;
      // print('ada');
      //Rounak is a really good boy ? Isn't he?
      // print(email);
      // print(phone1);
      updateData();
      setState(() {
        isLoading = false;
      });
    }
    catch(e){
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  getName() async {

    try {
      setState(() {
        isLoading = true;
      });
      final data = await firestore.collection('Users').doc(uid.isEmpty ? "sadasd" : uid).get();

      // SharedPreferences pref = await SharedPreferences.getInstance();
      setState(() {
        // patientName = pref.getString('name');
        patientName = data['name'];
        email = data['email'] ?? '';
        phone1 = auth.currentUser!.phoneNumber!;
        isLoading = false;
      });
    }catch(e){

      setState(() {
        isLoading = false;
      });

      print(e);
    }
    updateData();

    // print(patientName);
  }

  updateData() {
    print('sdada');
    setState(() {
      data = {
        'patientName': patientName,
        'gender': gender,
        'dob': dobController.text,
        'phoneNumber' : phoneController.text,
        'email' : emailController.text,
        'streetAddress' : addressController.text,
      };
      // print(data['dob']);
      widget.updateData(data);
    });

    try {
      pro.Provider.of<PdProvider>(context, listen: false).setFirstPage(
          patientName ?? '', gender ?? '', phoneController.text ?? '',
          dobController.text ?? '', emailController.text ?? '',
          addressController.text ?? '');
    }catch(e){

    }
  }

  @override
  Widget build(BuildContext context) {
    var pm = pro.Provider.of<AddPatientProvider>(context).pm;
    if(widget.status != 'normal') {
      patientName = pm.patientName;
      gender = pm.gender;
      dobController.text = pm.dob;
      emailController.text = pm.email;
      phoneController.text = pm.phoneNumber1;
      addressController.text = pm.streetAddress;
    }

    return Container(
      child: isLoading ? Center(child: CircularProgressIndicator(color: kPrimaryColor,),) : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Fields marked with * are mandatory to be filled", style: TextStyle(color: kGrey),),
            SizedBox(height: 16,),
            PatientTextField(
                title: 'Patient Name*: ',
                onChanged: (value) {
                  setState(() {
                    patientName = value;
                    updateData();
                  });
                }, inputValue: patientName.toString(), readOnly: (widget.status == 'normal'),),
            SizedBox(
              height: 32,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Gender*: ',
                    style: TextStyle(color: kGrey, fontSize: 16),
                  ),
                ),
                Expanded(
                  child: RadioMenuButton(
                    value: 'male',
                    groupValue: gender,
                    onChanged: (newValue) {
                      setState(() {
                        gender = newValue.toString();
                        updateData();
                      });
                    },
                    child: Text('Male'),
                  ),
                ),
                Expanded(
                  child: RadioMenuButton(
                    value: 'female',
                    groupValue: gender,
                    onChanged: (newValue) {
                      setState(() {
                        gender = newValue.toString();
                        updateData();
                      });
                    },
                    child: Text('Female'),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 32,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Phone no.*: ',
                    style: TextStyle(color: kGrey, fontSize: 16),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    child: TextField(
                      onChanged: (value){
                        setState(() {
                          phone1 = value;
                          updateData();
                        });
                      },
                      keyboardType: TextInputType.number,
                      controller: phoneController,
                      decoration: InputDecoration(
                        hintText: 'Enter phone number',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Date of birth: ',
                    style: TextStyle(color: kGrey, fontSize: 16),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    child: TextField(
                      controller: dobController,
                      onTap: () async {

                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(), //get today's date
                            firstDate:DateTime(1900), //DateTime.now() - not to allow to choose before today.
                            lastDate: DateTime(2101)
                        );

                        if (pickedDate != null) {
                          setState(() {
                            //t(pickedDate);
                            dob = DateFormat('yyyy-MM-dd').format(pickedDate!);
                            // DateTime dateTime = DateTime(pickedDate!.year,
                            //     pickedDate!.month, pickedDate!.day);
                            // ageController.text = AgeCalculator
                            //     .age(dateTime)
                            //     .years
                            //     .toString();
                            dobController.text = dob!;
                          });

                        }
                        updateData();
                      },
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Tap to select',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32,),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Email Address: ',
                    style: TextStyle(color: kGrey, fontSize: 16),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    child: TextField(
                      controller: emailController,
                      onChanged: (value){
                        setState(() {
                          email = value;
                          updateData();
                        });
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter Email Address',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32,),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Enter Address: ',
                    style: TextStyle(color: kGrey, fontSize: 16),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    child: TextField(
                      controller: addressController,
                      onChanged: (value){
                          setState(() {
                            streetAddress = value;
                            updateData();
                          });
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter Address',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32,),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Expanded(
            //       child: Text(
            //         'Age: ',
            //         style: TextStyle(color: kGrey, fontSize: 16),
            //       ),
            //     ),
            //     SizedBox(width: 16,),
            //     // Expanded(
            //     //   flex: 2,
            //     //   child: TextField(
            //     //     onChanged: (value) {
            //     //       // widget.onChanged(value);
            //     //     },
            //     //     controller: ageController,
            //     //     readOnly: true,
            //     //     decoration: InputDecoration(
            //     //       hintText: 'Age',
            //     //       border: OutlineInputBorder(
            //     //         borderSide: BorderSide(color: Colors.black),
            //     //       ),
            //     //     ),
            //     //   ),
            //     // ),
            //   ],
            // ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}
