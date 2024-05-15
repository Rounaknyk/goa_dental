import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goa_dental_clinic/classes/get_patient_details.dart';
import 'package:goa_dental_clinic/classes/meeting_data_source.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/models/app_history_model.dart';
import 'package:goa_dental_clinic/models/user_model.dart';
import 'package:goa_dental_clinic/providers/user_provider.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/test_screen.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/tooth_selection_container.dart';
import 'package:goa_dental_clinic/models/patient_model.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/view_appointments.dart';
import 'package:goa_dental_clinic/screens/login_screen.dart';
import 'package:goa_dental_clinic/screens/patient_screens/add_patient_screen.dart';
import 'package:goa_dental_clinic/screens/patient_screens/add_patient_screen4.dart';
import 'package:googleapis/connectors/v1.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../classes/get_initials.dart';
import '../../classes/pref.dart';
import '../../custom_widgets/appointment_card.dart';
import '../../custom_widgets/home_top_bar.dart';
import '../../custom_widgets/image_container.dart';
import '../../custom_widgets/long_image_container.dart';
import '../../custom_widgets/search_box.dart';
import '../../models/app_model.dart';
import 'check_records_screen.dart';
import 'manage_appointments_screen.dart';
import 'package:provider/provider.dart' as pro;

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String name = '';
  late String uid;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<AppointmentCard> appList = [];
  bool isLoading = true;
  bool isAppLoading = true;
  List<Appointment> meetings = [];
  CalendarController controller = CalendarController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // fetchData().getData();
    uid = auth.currentUser!.uid;
    getDetails();
    getMeetings();
    // getUpcomingAppoitments(context);
  }

  getMeetings() async {
    setState(() {
      isAppLoading = true;
    });

    meetings.clear();

    // Stream or QuerySnapshot based on your needs
    final doctorSnapshots = await firestore.collection('Doctors').get();

    for (var doctorDoc in doctorSnapshots.docs) {
      final doctorUid = doctorDoc.id;
      final appointments = await firestore
          .collection('Doctors')
          .doc(doctorUid)
          .collection('Appointments')
          .get();

      for (var app in appointments.docs) {
        try {
          meetings.add(
            Appointment(
              subject:
              'Dr. ${app['doctorName']}: ${app['patientName'].toString().toUpperCase()} (${app['plan'].toString().toUpperCase()})',
              notes: 'No notes',
              color: kPrimaryColor,
              id: AppModel(
                  patientName: app['patientName'],
                  doctorName: app['doctorName'],
                  date: app['date'],
                  week: app['week'],
                  time: app['time'],
                  doctorUid: app['doctorUid'],
                  patientUid: app['patientUid'],
                  appId: app['appId'],
                  pm: null,
                  startTimeInMil: app['startTimeInMil'],
                  endTimeInMil: app['endTimeInMil'],
                  month: app['month'],
                  plan: app['plan'],
                  toothList: app['toothList']),
              startTime: DateTime.fromMillisecondsSinceEpoch(
                  int.parse(app['startTimeInMil'])),
              endTime: DateTime.fromMillisecondsSinceEpoch(
                int.parse(app['endTimeInMil']),
              ),
            ),
          );
        } catch (e) {
          print(e);
          continue;
        }
      }
    }

    setState(() {
      isAppLoading = false;
    });
  }
  getUpcomingAppoitments(context) async {
    setState(() {
      isAppLoading = true;
    });
    final patients = await firestore
        .collection('Doctors')
        .doc(uid)
        .collection('Appointments')
        .get();

    appList.clear();

    for (var patient in patients.docs) {
      try {
        if (DateTime.fromMillisecondsSinceEpoch(int.parse(patient['appId']))
                .day ==
            DateTime.now().day) {
          final datas = await firestore.collection('Patients').get();
          PatientModel? pm;
          // if (DateTime
          //     .now()
          //     .millisecondsSinceEpoch < double.parse(patient['startTimeInMil'])) {
          for (var data in datas.docs) {
            if (patient['patientName'] == data['patientName'])
              pm = GetPatientDetails().get(data);
          }
          appList.add(AppointmentCard(
            size: MediaQuery.of(context).size,
            patientName: patient['patientName'],
            week: patient['week'],
            date: patient['date'],
            time: patient['time'],
            onMorePressed: (int itemNo) {},
            doctorName: patient['doctorName'],
            doctorUid: patient['doctorUid'],
            patientUid: patient['patientUid'],
            status: 'homescreen',
            appId: patient['appId'],
            startTimeInMil: patient['startTimeInMil'],
            endTimeInMil: patient['endTimeInMil'],
            month: patient['month'],
            plan: patient['plan'],
            toothList: patient['toothList'],
            refresh: (appId) {
              late AppointmentCard card;
              appList.forEach((element) {
                if (element.appId == appId) {
                  card = element;
                }
              });
              setState(() {
                if (card != null) appList.remove(card);
              });
            },
            pm: pm,
          ));
          // }
        }
      } catch (e) {
        continue;
      }
    }
    appList.sort((a, b) => a.appId.compareTo(b.appId));
    setState(() {
      isAppLoading = false;
    });
  }

  getDetails() async {
    setState(() {
      isLoading = true;
    });
    final data = await firestore.collection('Users').doc(uid).get();
    name = data['name'];
    pro.Provider.of<UserProvider>(context, listen: false).setUser(UserModel(
        name: data['name'],
        email: data['email'],
        phoneNumber: data['phoneNumber'],
        pass: data['pass']));
    setState(() {
      isLoading = false;
    });
  }

  checkRecords(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => CheckRecordsScreen()));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  addPatient(){
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPatientScreen(
          status: 'create_patient',
        ),
      ),
    );
  }
  
  logOut() async {
    Navigator.pop(context);
    await auth.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  deleteData(uid) async {
    await firestore.collection('Doctors').doc(uid).delete();
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
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Welcome ${name}!', style: TextStyle(color: Colors.black),),
        centerTitle: false,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Center(child: Image.asset('assets/logo.png'), ), decoration: BoxDecoration(color: Color(0xFFFFFFFF)),),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Add patient'),
              onTap: () => addPatient()
            ),
            ListTile(
                leading: Icon(Icons.date_range),
                title: Text('Check records'),
                onTap: () => checkRecords()
            ),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              !isAppLoading
                  ? SfCalendar(
                      todayHighlightColor: kPrimaryColor,
                      view: CalendarView.day,
                      controller: controller,
                      headerHeight: size.height * 0.05,
                      onTap: (details) {
                        var date = details.date;
                        if (date != null) {
                          meetings.forEach((element) {
                            if (element.startTime == date) {
                              print(element.id);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ViewAppointmentScreen(
                                              am: element.id as AppModel)));
                            }
                          });
                        }
                      },
                      dataSource: MeetingDataSource(meetings),
                    )
                  : Center(
                      child: LottieBuilder.asset('anim/tooth.json', height: size.height * 0.5,),
                    ),
              isAppLoading ? Container() : Align(
                child: SvgPicture.asset(
                  'svgs/logo.svg',
                  height: size.height * 0.1,
                  width: size.width * 0.15,
                ),
                alignment: Alignment.topRight,
              ),
              // InkWell(
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => AddPatientScreen(
              //           status: 'create_patient',
              //         ),
              //       ),
              //     );
              //     // Navigator.push(context, MaterialPageRoute(builder: (context) => TestScreen(patientUid: 'alkdjkajdlkj',)));
              //   },
              //   child: Material(
              //     borderRadius: BorderRadius.circular(12),
              //     elevation: 5,
              //     child: Container(
              //       height: 50,
              //       width: size.width * 0.3,
              //       decoration: BoxDecoration(
              //         color: kPrimaryColor,
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //       child: Center(
              //         child: Text(
              //           'Add Patient',
              //           style: TextStyle(
              //               color: Colors.white,
              //               fontWeight: FontWeight.bold,
              //               fontSize: 14),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeTopBar(
                    initials: GetInitials(name).get(),
                    primaryText: '$name',
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  LongImageContainer(
                      size: MediaQuery.of(context).size,
                      imgAddress: 'assets/logo.png',
                      text: 'All Appointments',
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ManageAppointmentsScreen()));
                      }
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    'Today\'s Appointments',
                    style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  isLoading ? Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    )
                  ):
                  Expanded(
                    child: !(appList.isEmpty) ? ListView.builder(itemBuilder: (context, index){

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: appList[index],
                      );
                    }, itemCount: appList.length,) : Container(
                      child: Center(
                        child: Text('No Appointments as of now', style: TextStyle(fontSize: 18, color: kGrey),),
                        // child: SvgPicture.asset('svgs/doctors.svg', height: MediaQuery.of(context).size.height * 0.3, width: MediaQuery.of(context).size.width * 0.3,),
                      ),
                    ),
                  ),
                ],
              ),
 */
