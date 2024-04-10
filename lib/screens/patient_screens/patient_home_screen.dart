import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/screens/patient_screens/add_patient_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../classes/alert.dart';
import '../../classes/get_initials.dart';
import '../../classes/get_patient_details.dart';
import '../../classes/pref.dart';
import '../../custom_widgets/appointment_card.dart';
import '../../custom_widgets/home_top_bar.dart';
import '../../custom_widgets/image_container.dart';
import '../../custom_widgets/search_box.dart';
import '../../models/patient_model.dart';
import '../login_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String name = 'A', uid = '', profileUrl = '';
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<AppointmentCard> appList = [];
  bool isLoading = false;
  bool isAppLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // fetchData().getData();
    uid = auth.currentUser!.uid;
    isSetup();
    getDetails();
    getAppointments();
  }

  isSetup() async {
    final data = await firestore.collection('Users').doc(uid).get();
    if (data['setup'] == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => AddPatientScreen()));
    }
  }

  getDetails() async {
    setState(() {
      isLoading = true;
    });
    final data = await firestore.collection('Patients').doc(uid).get();

    setState(() {
      name = data['patientName'];
      profileUrl = data['profileUrl'];
      isLoading = false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  getAppointments() async {
    // try {
      final patients = await firestore
          .collection('Patients')
          .doc(uid)
          .collection('Appointments')
          .get();

      appList.clear();

      for (var patient in patients.docs) {
        try {
          // if (DateTime
          //     .now()
          //     .millisecondsSinceEpoch < double.parse(patient['startTimeInMil']))
          appList.add(
            AppointmentCard(
              size: MediaQuery
                  .of(context)
                  .size,
              patientName: patient['patientName'],
              week: patient['week'],
              date: patient['date'],
              time: patient['time'],
              plan: patient['plan'],
              toothList: patient['toothList'],
              onMorePressed: (int itemNo) {},
              doctorName: patient['doctorName'],
              doctorUid: patient['doctorUid'],
              patientUid: patient['patientUid'],
              status: 'patienthomescreen',
              appId: patient['appId'],
              startTimeInMil: patient['startTimeInMil'],
              month: patient['month'],
              endTimeInMil: patient['endTimeInMil'],
              pm: null,
              refresh: (appId) {
                late AppointmentCard card;
                appList.forEach((element) {
                  if (element.appId == appId) {
                    card = element;
                  }
                });
                setState(() {
                  if (card != null)
                    appList.remove(card);
                });
              },
            ),
          );
        }catch(e){
          continue;
        }
      }
      appList.sort((a, b) => a.appId.compareTo(b.appId));
    // } catch (e) {
    // }
    setState(() {
      isAppLoading = false;
    });
  }


  logOut() async {
    Navigator.pop(context);
    await auth.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  deleteData(uid) async {
    await firestore.collection('Patients').doc(uid).delete();
    await firestore.collection('Users').doc(uid).delete();
  }

  deleteAccount() async {
    Navigator.pop(context);
    try {

      await deleteData(uid);

      await auth.currentUser!.delete();

      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));

    } on FirebaseAuthException catch (e) {
      print(e);

      if (e.code == "requires-recent-login") {
        print(e.code);
      } else {
        // Handle other Firebase exceptions
      }
    } catch (e) {
      print("General exception: $e");
      // Handle general exception
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Center(child: Image.asset('assets/logo.png'), ), decoration: BoxDecoration(color: Color(0xFFFFFFFF)),),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Log out'),
              onTap: () => logOut(),
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete account'),
                onTap: (){

                  showDialog(context: context, builder: (context) {

                    return AlertDialog(
                      title: Text('Are you sure?'),
                      content: Text('Delete account?'),
                      actions: [
                        ElevatedButton(onPressed: (){
                          Navigator.pop(context);

                        }, child: Text('No')),
                        ElevatedButton(onPressed: (){
                          deleteAccount();

                        }, child: Text('Yes')),
                      ],
                    );
                  });
                }
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: HomeTopBar(
          initials: GetInitials(name).get(),
          profileUrl: profileUrl,
          primaryText: '$name',
        ),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: kPrimaryColor,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      'Your Appointments',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    isAppLoading
                        ? Expanded(
                            child: Center(
                            child:
                                CircularProgressIndicator(color: kPrimaryColor),
                          ))
                        : ((appList.isEmpty)
                            ? Expanded(
                              child: Container(
                                child: Center(
                                    child: Text(
                                      'No Appointments as of now',
                                      style: TextStyle(fontSize: 18, color: kGrey),
                                    ),
                                  ),
                              ),
                            )
                            : Expanded(
                                child: ListView.builder(
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: appList[index],
                                    );
                                  },
                                  itemCount: appList.length,
                                ),
                              )),
                  ],
                ),
        ),
      ),
    );
  }
}
