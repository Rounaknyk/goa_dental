import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goa_dental_clinic/classes/pref.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/custom_widgets/message_card.dart';
import 'package:goa_dental_clinic/models/app_model.dart';
import 'package:goa_dental_clinic/models/appointment_msg_model.dart';
import 'package:goa_dental_clinic/models/patient_msg_model.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/appointment_screen.dart';
import 'package:goa_dental_clinic/screens/patient_screens/patient_message_screen.dart';

import '../../classes/get_patient_details.dart';
import '../../custom_widgets/patient_msg_card.dart';
import '../../models/patient_model.dart';
import '../../models/patient_msg_model2.dart';
import '../patient_screens/add_patient_screen.dart';

class DoctorMessageScreen extends StatefulWidget {
  const DoctorMessageScreen({Key? key}) : super(key: key);

  @override
  State<DoctorMessageScreen> createState() => _DoctorMessageScreenState();
}

class _DoctorMessageScreenState extends State<DoctorMessageScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? uid, doctorName;
  List<MessageCard> msgList = [];
  bool isLoading = false;

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
      doctorName = data['name'];
    } catch (e) {
      print('Message screen exception: $e');
    }
    setState(() {});
  }

  onAccept(AppointmentMessageModel amm) async {
    final datas = await firestore.collection('Patients').get();
    PatientModel? pm;
    setState(() {
      for (var data in datas.docs) {
        print(data['patientName'] + data['patientName']);
        if (amm.patientName == data['patientName']) {
          pm = GetPatientDetails().get(data);
          break;
        }
      }
    });

    // print(pm!.patientName+pm!.dob+pm!.language+pm!.age+pm!.age);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AppointmentScreen(
                  am: AppModel(
                      patientName: amm.patientName.toString(),
                      doctorName: doctorName.toString(),
                      date: amm.date.toString(),
                      week: amm.week.toString(),
                      time: amm.startTime.toString(),
                      doctorUid: (amm.doctorUid != '') ? amm.doctorUid : uid!,
                      patientUid: amm.patientUid.toString(),
                      appId: amm.appId.toString(),
                      pm: pm,
                      startTimeInMil: amm.startTimeInMil,
                      endTimeInMil: amm.endTimeInMil,
                      month: amm.month, plan: amm.plan, toothList : amm.toothList),
                )));

    if(amm.doctorUid == '')
    removeMsg(amm.msgId, uid);
    else
    removeMsg(amm.msgId, amm.doctorUid);

    setState(() {});
  }

  removeMsg(msgId, docUid) async {
    //it shouldn't use current doc uid....uid should be dynamically selected
    await firestore
        .collection('Doctors')
        .doc(docUid)
        .collection('Messages')
        .doc(msgId)
        .delete();
    msgList.removeWhere((msg) {
      return (msg.am?.msgId == msgId);
    });
  }

  getAllMessages() async {
    setState(() {
      isLoading = true;
    });
    final allDocs = await firestore.collection('Doctors').get();

    msgList.clear();
    for(var doc in allDocs.docs){
      final msgs = await firestore.collection('Doctors').doc(doc['uid']).collection('Messages').get();
      for(var msg in msgs.docs){
        String msgId = msg.reference.id;

        String docUid = doc['uid'];

        setState(() {
          msgList.add(
            MessageCard(onAccept: (amm){
              onAccept(amm);
            }, onReject: (){
              removeMsg(msgId, docUid);
            }, am:
            AppointmentMessageModel(
              date: msg['date'],
              startTime: msg['startTime'],
              endTime: msg['endTime'],
              message: msg['message'],
              patientName: msg['patientName'],
              patientUid: msg['patientUid'],
              week: msg['week'],
              appId: msg['appId'],
              msgId: msgId,
              startTimeInMil: msg['startTimeInMil'],
              endTimeInMil: msg['endTimeInMil'],
              month: msg['month'], plan: msg['plan'], toothList: msg['toothList'], doctorUid: docUid),
            ),
          );
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  showMessageDialog() async {
    showDialog(context: context, builder: (context){
      Size size = MediaQuery.of(context).size;
      return Material(
        color: Colors.transparent,
        child: Center(
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white),
                width: size.width * 0.8,
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Send message', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),),
                    SizedBox(height: 16,),
                    TextField(
                      decoration: InputDecoration(hintText: 'Type here...', border: OutlineInputBorder()),
                      maxLines: null,
                    ),
                    SizedBox(height: 16,),
                    CustomButton(text: 'Send', backgroundColor: kPrimaryColor, onPressed: () async {
                      await sendMsg();
                      Navigator.pop(context);
                    }),
                  ],
                ),
              ),
              InkWell(child: Icon(Icons.cancel_outlined, color: Colors.red, size: 30,), onTap: (){
                Navigator.pop(context);
              }),
            ],
          ),
        ),
      );
    });

  }

  sendMsg() async {
    // FirebaseMessaging messaging = FirebaseMessaging.instance;
    // Map<String, dynamic> message = {
    //   'notification': {
    //     'title': 'Hello from Firebase!',
    //     'body': 'This is a message sent from the app.'
    //   },
    // };
    // await messaging.sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: !isLoading ? Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              Container(
                height: double.infinity,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // InkWell(
                          //   onTap: () {
                          //     showMessageDialog();
                          //   },
                          //   child: Container(
                          //     height: 50,
                          //     width: size.width * 0.35,
                          //     decoration: BoxDecoration(
                          //       color: kPrimaryColor,
                          //       borderRadius: BorderRadius.circular(12),
                          //     ),
                          //     child: Center(
                          //       child: Text(
                          //         'Send Message',
                          //         style: TextStyle(
                          //             color: Colors.white,
                          //             fontWeight: FontWeight.bold,
                          //             fontSize: 14),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      StreamBuilder(
                          stream: firestore
                              .collection('Doctors')
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
                            if (snapshot.hasData && msgList.isEmpty) {
                              final messages = snapshot.data;

                              msgList.clear();
                              for (var msg in (messages?.docs)!) {
                                String msgId = msg.reference.id;
                                msgList.add(
                                  MessageCard(
                                    onAccept: (AppointmentMessageModel amm) {
                                      onAccept(amm);
                                    },
                                    onReject: () {
                                      removeMsg(msgId, uid);
                                    },
                                    am: AppointmentMessageModel(
                                        date: msg['date'],
                                        startTime: msg['startTime'],
                                        endTime: msg['endTime'],
                                        message: msg['message'],
                                        patientName: msg['patientName'],
                                        patientUid: msg['patientUid'],
                                        week: msg['week'],
                                        appId: msg['appId'],
                                        msgId: msgId,
                                        startTimeInMil: msg['startTimeInMil'],
                                        endTimeInMil: msg['endTimeInMil'],
                                        month: msg['month'], plan: msg['plan'], toothList: msg['toothList'],),
                                  ),
                                );
                              }
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
                          })
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  getAllMessages();
                },
                child: Material(
                  borderRadius: BorderRadius.circular(12),
                  elevation: 5,
                  child: Container(
                    height: 50,
                    width: size.width * 0.35,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'All Messages',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ) : Center(child: CircularProgressIndicator(color: kPrimaryColor,),),
        ),
      ),
    );
  }
}
