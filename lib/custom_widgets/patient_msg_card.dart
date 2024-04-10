import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/classes/alert.dart';
import 'package:goa_dental_clinic/classes/date_time_parser.dart';

import '../constants.dart';
import '../models/patient_msg_model2.dart';

class PatientMsgCard extends StatelessWidget {
  PatientMsgCard({required this.pmm, required this.markAsRead});
  PatientMsgModel2 pmm;
  Function markAsRead;
  FirebaseAuth auth = FirebaseAuth.instance;

  mark() async {
    try {
      await FirebaseFirestore.instance.collection('Patients').doc(
          auth.currentUser!.uid).collection('Messages').doc(pmm.msgId).delete();
      markAsRead(pmm.msgId);
    }
    catch(e){
      print('$e in patient message card');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notification from Dr. ${pmm.docName}',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text('at ${DateTimeParser(DateTime.fromMillisecondsSinceEpoch(int.parse(pmm.msgId)).toString()).getFormattedTime()}', style: TextStyle(fontSize: 12),),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${pmm.msg}',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              InkWell(
                onTap: (){
                  mark();
                },
                child: Container(
                  height: 35,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      color: kPrimaryColor
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.done, color: Colors.white,),
                        SizedBox(width: 8,),
                        Text('Mark as read', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        elevation: 4,
      ),
    );
  }
}
