import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goa_dental_clinic/classes/pref.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/message_card.dart';
import 'package:goa_dental_clinic/models/app_model.dart';
import 'package:goa_dental_clinic/models/appointment_msg_model.dart';
import 'package:goa_dental_clinic/models/patient_msg_model.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/appointment_screen.dart';

import '../../classes/get_patient_details.dart';
import '../../custom_widgets/patient_msg_card.dart';
import '../../models/patient_model.dart';
import '../../models/patient_msg_model2.dart';

class PatientMessageScreen extends StatefulWidget {
  const PatientMessageScreen({Key? key}) : super(key: key);

  @override
  State<PatientMessageScreen> createState() => _PatientMessageScreenState();
}

class _PatientMessageScreenState extends State<PatientMessageScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? uid, patientName;
  List<PatientMsgCard> msgList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = auth.currentUser!.uid;
    getName();
  }

  getName() async {
    try {
      final data = await firestore.collection('Users').doc(uid).get();
      patientName = data['name'];
    } catch (e) {
      print('Message screen exception: $e');
    }
    setState(() {});
  }

  // removeMsg(msgId) async {
  //   await firestore.collection('Doctors').doc(uid).collection('Messages').doc(msgId).delete();
  //   msgList.removeWhere((msg) {
  //     return (msg.am?.msgId == msgId);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Messages',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 16,
                ),
                StreamBuilder(
                    stream: firestore
                        .collection('Patients')
                        .doc(uid)
                        .collection('Messages')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: kPrimaryColor,
                          ),
                        );
                      }
                      if (snapshot.hasData) {
                        final messages = snapshot.data;

                        msgList.clear();
                        for (var msg in (messages?.docs)!) {
                          String msgId = msg.reference.id;
                          msgList.add(PatientMsgCard(
                            pmm: PatientMsgModel2(
                                msg: msg['msg'],
                                msgId: msgId,
                                docName: msg['docName'],
                                docUid: msg['docUid'],
                                date: msg['date'],
                                week: msg['week'],
                                time: msg['time'],),
                            markAsRead: (msgId){
                              late PatientMsgCard card;
                              msgList.forEach((element) {
                                if(element.pmm.msgId == msgId){
                                  card = element;
                                }
                              });
                              setState(() {
                                if(card != null)
                                  msgList.remove(card);
                              });
                          },
                          ),);
                        }

                          msgList.sort((card1, card2){

                            return (int.parse(card2.pmm.msgId).compareTo(int.parse(card1.pmm.msgId)));
                          });
                      }
                      if (msgList.isEmpty) {
                        return Container(
                          child: Center(
                              child: Column(
                            children: [
                              SvgPicture.asset(
                                'svgs/no_data.svg',
                                height: size.height * 0.3,
                                width: size.width * 0.3,
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Text(
                                'No Messages yet',
                                style: TextStyle(fontSize: 18, color: kGrey),
                              ),
                            ],
                          )),
                        );
                      }
                      return Column(
                        children: msgList.map((e){

                          return e;
                        }).toList(),
                      );
                      // return ListView.builder(
                      //   itemBuilder: (context, index) {
                      //     return msgList[index];
                      //   },
                      //   itemCount: msgList.length,
                      //   shrinkWrap: true,
                      // );
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}

