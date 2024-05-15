import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/models/completed_plan_model.dart';
import 'package:goa_dental_clinic/screens/register_screen.dart';

import '../../custom_widgets/appointment_card.dart';
import '../../custom_widgets/appointment_history_card.dart';
import '../../custom_widgets/record_appointment_card.dart';
import '../login_screen.dart';

class AppointmentHistory extends StatefulWidget {
  const AppointmentHistory({Key? key}) : super(key: key);

  @override
  State<AppointmentHistory> createState() => _AppointmentHistoryState();
}

class _AppointmentHistoryState extends State<AppointmentHistory> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? uid;
  bool isLoading = true;
  List<AppointmentHistoryCard> appList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = auth.currentUser!.uid;
    getAppointments();
  }

  getAppointments() async {
    setState(() {
      isLoading = true;
    });

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.logout),
        backgroundColor: kPrimaryColor, onPressed: () async {
        await auth.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      },
      ),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Appointment History',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder(
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: kPrimaryColor,
                  ),
                );
              } else {
                appList.clear();
                
                List<CompletedPlanModel> cList = [];
                for (var plan in snapshot.data!.docs) {
                  try {
                    cList.add(
                      CompletedPlanModel(
                          plan: plan['plan'],
                          toothList: plan['toothList'],
                          time: plan['time'],
                          patientUid: plan['patientUid'],
                          patientName: plan['patientName'],
                          docName: plan['docName'],
                          docUid: plan['docUid'],
                          note: plan['note'],
                          week: plan['week']),
                    );
                    
                  } catch (e) {
                    print(e);
                    continue;
                  }
                }
                cList = cList.reversed.toList();
                return ListView(
                  children: cList.map((plan){
                    final list = plan.time.split(' ');
                    String date = list[0];
                    String month = list[1];

                    return RecordAppointmentCard(
                      size: size,
                      patientName: plan.patientName,
                      week: plan.week,
                      date: date,
                      time: plan.time,
                      onMorePressed: () {},
                      doctorName: plan.docName,
                      doctorUid: plan.docUid,
                      patientUid: plan.patientUid,
                      appId: 'appId',
                      pm: null,
                      startTimeInMil:
                      DateTime.now().millisecondsSinceEpoch.toString(),
                      month: month,
                      endTimeInMil:
                      DateTime.now().millisecondsSinceEpoch.toString(),
                      refresh: () {},
                      plan: plan.plan,
                      toothList: plan.toothList,
                      status: 'Completed',
                      note: plan.note,
                    );
                  }).toList(),
                );
              }
            },
            stream: firestore
                .collection('Completed Plans')
                .snapshots(),
          ),
        ),
      ),
    );
  }
}
