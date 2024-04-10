import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../classes/get_patient_details.dart';
import '../../classes/pref.dart';
import '../../constants.dart';
import '../../custom_widgets/appointment_card.dart';
import '../../models/patient_model.dart';

class ManageAppointmentsScreen extends StatefulWidget {
  const ManageAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<ManageAppointmentsScreen> createState() =>
      _ManageAppointmentsScreenState();
}

class _ManageAppointmentsScreenState extends State<ManageAppointmentsScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  String? uid, name;
  List<AppointmentCard> appList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = auth.currentUser!.uid;
    getDetails();
    getAppointments(context);
  }

  getAppointments(context) async {
    final patientApps = await firestore
        .collection('Doctors')
        .doc(uid)
        .collection('Appointments')
        .get();

    appList.clear();

    for (var app in patientApps.docs) {
      try {
        if (DateTime
            .now()
            .millisecondsSinceEpoch < double.parse(app['endTimeInMil'])) {
          appList.add(AppointmentCard(
            size: MediaQuery
                .of(context)
                .size,
            patientName: app['patientName'],
            week: app['week'],
            date: app['date'],
            time: app['time'],
            onMorePressed: (int itemNo) {},
            doctorName: app['doctorName'],
            doctorUid: app['doctorUid'],
            patientUid: app['patientUid'],
            status: 'homescreen',
            appId: app['appId'],
            pm: null,
            startTimeInMil: app['startTimeInMil'],
            endTimeInMil: app['endTimeInMil'],
            month: app['month'],
            plan: app['plan'],
            toothList: app['toothList'],
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
          ));
        }
      }
      catch(e){
        continue;
      }
    }
    appList.sort((a, b) => a.appId.compareTo(b.appId));
    setState(() {});
  }

  getDetails() async {
    final data = await firestore.collection('Doctors').doc(uid).get();
    name = data['name'];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          'All Appointments',
          style: TextStyle(
            color: Colors.black,
            fontSize: 21,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: InkWell(child: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black,), onTap: (){
          Navigator.pop(context);
        },),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                (appList.isNotEmpty)
                    ? ListView.builder(
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: appList[index],
                          );
                        },
                        itemCount: appList.length,
                        shrinkWrap: true,
                      )
                    : Container(
                        child: Center(
                          child: Text(
                            'No Appointments as of now',
                            style: TextStyle(fontSize: 18, color: kGrey),
                          ),
                          // child: SvgPicture.asset('svgs/doctors.svg', height: MediaQuery.of(context).size.height * 0.3, width: MediaQuery.of(context).size.width * 0.3,),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
