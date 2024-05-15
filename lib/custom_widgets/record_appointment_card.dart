import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/classes/alert.dart';
import 'package:goa_dental_clinic/models/app_model.dart';
import 'package:goa_dental_clinic/models/patient_model.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/appointment_screen.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/view_history_appointment.dart';
import 'package:goa_dental_clinic/screens/patient_screens/patient_view_appointments.dart';

import '../classes/date_time_parser.dart';
import '../constants.dart';
import '../screens/doctor_screens/nav_screen.dart';
import '../screens/doctor_screens/view_appointments.dart';
import '../screens/patient_screens/patient_details_screen.dart';
import 'package:http/http.dart' as http;

import 'fixed_sized_tooth.dart';

class RecordAppointmentCard extends StatefulWidget {
  RecordAppointmentCard({
    required this.size,
    required this.patientName,
    required this.week,
    required this.date,
    required this.time,
    required this.onMorePressed,
    required this.doctorName,
    required this.doctorUid,
    required this.patientUid,
    required this.appId,
    required this.pm,
    required this.startTimeInMil,
    required this.month,
    required this.endTimeInMil,
    this.isDoc = true,
    this.status = 'normal',
    this.orderId = '0',
    required this.refresh,
    required this.plan,
    required this.toothList,
    required this.note,
  });

  final Size size;
  final String patientName,
      doctorName,
      date,
      week,
      time,
      status,
      doctorUid,
      patientUid,
      appId,
      startTimeInMil,
      endTimeInMil,
      month, plan, orderId;
  List<dynamic> toothList = [];
  Function onMorePressed;
  PatientModel? pm;
  bool isDoc;
  Function refresh;
  String note;

  @override
  State<RecordAppointmentCard> createState() => _RecordAppointmentCardState();
}

class _RecordAppointmentCardState extends State<RecordAppointmentCard> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  sendNotificationToPatient() async {
    String msgId = DateTime.now().millisecondsSinceEpoch.toString();
    firestore
        .collection('Patients')
        .doc(widget.patientUid)
        .collection('Messages')
        .doc(msgId)
        .set({
      'msg':
      'Cancelled appointment scheduled on ${widget.date}(${widget.week}) at ${widget.time}.',
      'msgId': msgId,
      'docUid': widget.doctorUid,
      'docName': widget.doctorName,
      'date': widget.date,
      'week': widget.week,
      'time': widget.time,
    });
  }

  notifyPatient(patientToken, body, title) async {
    try {
      await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: <String, String>{
          "Content-Type": "application/json",
          "Authorization": "key=$messagingServerKey"
        },
        body: jsonEncode(
          <String, dynamic>{
            "priority": "high",
            "data": <String, dynamic>{
              "click_action": "FLUTTER_NOTIFICATION_CLICK",
              "status": "done",
              "body": body,
              "title": title,
              "type": "chat",
            },
            "notification": <String, dynamic>{
              "title": title,
              "body": body,
              "android_channel_id": "dbfood",
            },
            "to": patientToken,
          },
        ),
      );
      print('Notification sent!');
    } catch (e) {
      print(e);
    }

    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data saved !'), backgroundColor: Colors.green,));
    // Navigator.push(context, MaterialPageRoute(builder: (context) => NavScreen(screenNo: 2)));
  }

  deleteAppointment() {
    // Navigator.pop(context);
    Timer(Duration(milliseconds: 500), () {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Are you sure?'),
              content: Text('Delete appointment!'),
              actions: [
                ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        final data = await firestore
                            .collection('Patients')
                            .doc(widget.patientUid)
                            .get();
                        String patientToken = data['token'];
                        await firestore
                            .collection('Doctors')
                            .doc(widget.doctorUid)
                            .collection('Appointments')
                            .doc('${widget.patientUid}_${widget.appId}')
                            .delete();
                        await firestore
                            .collection('Patients')
                            .doc(widget.patientUid)
                            .collection('Appointments')
                            .doc('${widget.patientUid}_${widget.appId}')
                            .delete();
                        widget.refresh(
                          widget.appId,
                        );
                        sendNotificationToPatient();
                        notifyPatient(
                            patientToken,
                            'Canceled appointment scheduled on ${widget.date}(${widget.week}) at ${widget.time}.',
                            'Notification from Dr. ${widget.doctorName}');
                      } catch (e) {
                        Alert(context, 'Error deleting : $e');
                      }
                    },
                    child: Text('Yes')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('No')),
              ],
            );
          });
    });
  }

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () {
        // Navigator.push(context, MaterialPageRoute(builder: (context) => ViewHistoryAppointment(am: AppModel(patientName: widget.patientName, doctorName: widget.doctorName, date: widget.date, week: widget.week, time: widget.time, doctorUid: widget.doctorUid, patientUid: widget.patientUid, appId: widget.appId, pm: widget.pm, startTimeInMil: widget.startTimeInMil, endTimeInMil: widget.endTimeInMil, month: widget.month, plan: widget.plan, toothList: widget.toothList))));
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: kGrey,
              ),
              color: Colors.white),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(0),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(0),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      child: Center(
                          child: Text(
                            "${widget.month}",
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: kGrey),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${widget.date}',
                                style:
                                TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${widget.week}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Container(
                          decoration: BoxDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 14,
                              ),
                              (widget.isDoc)
                                  ? Text(
                                '${widget.patientName}',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                maxLines: 1,
                              )
                                  : Text(
                                'Dr. ${widget.doctorName}',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                                maxLines: 1,
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              (widget.isDoc)
                                  ? Text('By Dr. ${widget.doctorName}')
                                  : Text(''),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                widget.status,
                                style: TextStyle(color: (widget.status == 'Pending') ? Colors.blue : ((widget.status == 'Cancelled') ? Colors.red : Colors.green), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(color: kGrey,),
                    SizedBox(height: 4,),
                    Text('Plan: ${widget.plan}'),
                    widget.toothList.isEmpty ? Container() : Wrap(
                      children: widget.toothList.map((e) {
                        return FixedSizeTooth(
                          index: e,
                          onTap: () {},
                          height: 40,
                          width: 40,
                        );
                      }).toList(),
                    ),
                    widget.note.isEmpty ? Container() : Divider(color: kGrey,),
                    widget.note.isEmpty ? Container() : SizedBox(height: 4,),
                    widget.note.isEmpty ? Container() : Text('Note: ${widget.note}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
