import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/custom_widgets/search_box.dart';

import '../../custom_widgets/patient_card.dart';
import '../../models/patient_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  String searchTxt = '';
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<PatientModel> searchResults = [];

  void searchPatient() async {
    // firestore.collection('Patients').where('patientName', isEqualTo: searchTxt).get().then((QuerySnapshot snapshot) {
    //   if (snapshot.docs.isNotEmpty) {
    //     setState(() {
    //       searchResults = snapshot.docs.map((doc) => doc['patientName']).toList();
    //     });
    //   } else {
    //     setState(() {
    //       searchResults.clear();
    //     });
    //   }
    // });

    final data = await firestore.collection('Patients').get();

    print(searchTxt);
    searchResults.clear();
    for(var patient in data.docs){
      if(patient['patientName'].toString().toLowerCase().trim().contains(searchTxt.toLowerCase().trim()) || searchTxt == ''){
        try {
          searchResults.add(PatientModel(patientUid: patient['patientUid'],
              patientName: patient['patientName'],
              email: patient['email'],
              dob: patient['dob'],
              gender: patient['gender'],
              phoneNumber1: patient['phoneNumber'],
              streetAddress: patient['streetAddress'],
              profileUrl: patient['profileUrl']));
        }catch(e){
          continue;
        }
      }
    }

    setState(() {

    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchPatient();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
    appBar: AppBar(title: SearchBox(onChanged: (value){
      setState(() {
        searchTxt = value;
        searchPatient();
      },);},), backgroundColor: Colors.white, elevation: 0, centerTitle: false, automaticallyImplyLeading: false,),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: searchResults.map((e){

                return PatientCard(pm: e);
              }).toList(),
            ),
          ),

        ),
      ),
    );
  }
}
