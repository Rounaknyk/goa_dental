import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/appointment_card.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/custom_widgets/file_input_card.dart';
import 'package:goa_dental_clinic/custom_widgets/icon_text.dart';
import 'package:goa_dental_clinic/custom_widgets/presciption_card.dart';
import 'package:goa_dental_clinic/custom_widgets/prescription_input_card.dart';
import 'package:goa_dental_clinic/custom_widgets/treatment_plan_card.dart';
import 'package:goa_dental_clinic/models/app_model.dart';
import 'package:goa_dental_clinic/models/treatment_model.dart';
import 'package:goa_dental_clinic/custom_widgets/note_input_card.dart';

import '../../classes/alert.dart';
import '../../custom_widgets/fixed_sized_tooth.dart';
import '../../custom_widgets/image_des_container.dart';
import '../../custom_widgets/treatment_plan_input_card.dart';
import '../../custom_widgets/treatment_text_field.dart';
import '../../models/image_model.dart';
import '../../models/prescription_model.dart';
import 'patient_details_screen.dart';
import 'package:http/http.dart' as http;

class PatientViewAppointmentScreen extends StatefulWidget {
  PatientViewAppointmentScreen({required this.am, this.itemNo = 0});
  AppModel am;
  int itemNo;

  @override
  State<PatientViewAppointmentScreen> createState() => _PatientViewAppointmentScreenState();
}

class _PatientViewAppointmentScreenState extends State<PatientViewAppointmentScreen> {
  List<TreatmentModel> tmList = [];
  List<PrescriptionModel> pmList = [];
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late String uid;
  bool isUploading = false;
  String note = '', url = '';
  File? file;
  FirebaseStorage storage = FirebaseStorage.instance;
  UploadTask? uploadTask;
  String des = '';
  String? nodeId;
  List<ImageModel> imList = [];
  List<Widget> treatmentPlan = [];
  List<Widget> precription = [];
  List<Widget> notes = [];
  List<Widget> images = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = auth.currentUser!.uid;
    nodeId = '${widget.am.patientUid}_${widget.am.appId}';
    if (widget.itemNo != 0) {
      autoShowCards(widget.itemNo, context);
    }
    getTreatmentPlans();
    getPrescriptionS();
    getNote();
    getImages();
  }

  autoShowCards(itemNo, context, {tm = null}) {
    switch (itemNo) {
      case 1:
        Timer(Duration(milliseconds: 500), () {
          showTreatmentInputCard(tm: tm);
        });
        break;
      case 2:
        Timer(Duration(milliseconds: 500), () {
          showPrescriptionInputCard();
        });
        break;
      case 3:
        Timer(Duration(milliseconds: 500), () {
          showNoteCard();
        });
        break;
      case 4:
        Timer(Duration(milliseconds: 500), () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PatientDetailsScreen(
                        pm: widget.am.pm,
                        uid: widget.am.patientUid,
                      )));
        });
        break;
      default:
        break;
    }
  }

  getTreatmentPlans() async {
    final plans = await firestore
        .collection('Doctors')
        .doc(widget.am.doctorUid)
        .collection('Appointments')
        .doc(nodeId)
        .collection('TreatmentPlans')
        .get();
    tmList.clear();
    for (var plan in plans.docs) {

      List<int> tList = [];

      final data = await firestore
          .collection('Doctors')
          .doc(widget.am.doctorUid)
          .collection('Appointments')
          .doc(nodeId)
          .collection('TreatmentPlans')
          .doc(plan.id)
          .collection('Tooth List').get();

      for(var tooth in data.docs){
        tList.add(tooth['tooth']);
      }

      tmList.add(TreatmentModel(
          procedure: plan['procedure'],
          note: plan['note'],
          discount: plan['discount'],
          discountSymbol: plan['discountSymbol'],
          total: plan['total'],
          cost: plan['cost'],
          unit: plan['unit'],
          id: plan['id'], toothList: tList));
    }
    setState(() {});
  }

  getPrescriptionS() async {
    final pre = await firestore
        .collection('Doctors')
        .doc(widget.am.doctorUid)
        .collection('Appointments')
        .doc(nodeId)
        .collection('Prescription')
        .get();
    pmList.clear();
    for (var p in pre.docs) {
      pmList.add(PrescriptionModel(
          dosage: p['dosage'],
          drug: p['drug'],
          duration: p['duration'],
          generalInstruction: p['generalInstruction'],
          instruction: p['instruction'],
          id: p['id']));
    }
    setState(() {});
  }

  getNote() async {
    try {
      final nt = await firestore
          .collection('Doctors')
          .doc(widget.am.doctorUid)
          .collection('Appointments')
          .doc(nodeId)
          .collection('Note')
          .doc('note')
          .get();
      setState(() {
        note = nt['note'];
      });
    } catch (e) {
      print(e);
    }
  }

  getImages() async {
    final images = await firestore
        .collection('Doctors')
        .doc(widget.am.doctorUid)
        .collection('Appointments')
        .doc(nodeId)
        .collection('Files')
        .get();

    imList.clear();
    for (var image in images.docs) {
      imList.add(
          ImageModel(url: image['url'], description: image['description']));
    }
    setState(() {});
  }

  uploadData() async {
    setState(() {
      isUploading = true;
    });

    // if(file != null)
    // await uploadImage();
    //uploading AppModel details
    await firestore
        .collection('Doctors')
        .doc(uid)
        .collection('Appointments')
        .doc(nodeId)
        .set({
      'patientName': widget.am.patientName,
      'doctorName': widget.am.doctorName,
      'date': widget.am.date,
      'week': widget.am.week,
      'patientUid': widget.am.patientUid,
      'doctorUid': widget.am.doctorUid,
      'time': widget.am.time,
      'appId': widget.am.appId,
      'startTimeInMil': widget.am.startTimeInMil,
      'endTimeInMil': widget.am.endTimeInMil,
    });

    await firestore
        .collection('Patients')
        .doc(widget.am.patientUid)
        .collection('Appointments')
        .doc(nodeId)
        .set({
      'patientName': widget.am.patientName,
      'doctorName': widget.am.doctorName,
      'date': widget.am.date,
      'week': widget.am.week,
      'patientUid': widget.am.patientUid,
      'doctorUid': widget.am.doctorUid,
      'time': widget.am.time,
      'appId': widget.am.appId,
      'startTimeInMil': widget.am.startTimeInMil,
      'endTimeInMil': widget.am.endTimeInMil,
    });

    //uploading Treatment Plans
    for (var plan in tmList) {
      await firestore
          .collection('Doctors')
          .doc(uid)
          .collection('Appointments')
          .doc(nodeId)
          .collection('TreatmentPlans')
          .doc(plan.id)
          .set({
        'procedure': plan.procedure,
        'note': plan.note,
        'discount': plan.discount,
        'discountSymbol': plan.discountSymbol,
        'cost': plan.cost,
        'total': plan.total,
        'unit': plan.unit,
        'id': plan.id,
      });
    }

    //uploading Prescriptions
    for (var pre in pmList) {
      await firestore
          .collection('Doctors')
          .doc(uid)
          .collection('Appointments')
          .doc(nodeId)
          .collection('Prescription')
          .doc(pre.id)
          .set({
        'dosage': pre.dosage,
        'drug': pre.drug,
        'duration': pre.duration,
        'generalInstruction': pre.generalInstruction,
        'instruction': pre.instruction,
        'id': pre.id,
      });
    }

    //uploading note
    if (note.isNotEmpty) {
      await firestore
          .collection('Doctors')
          .doc(uid)
          .collection('Appointments')
          .doc(nodeId)
          .collection('Note')
          .doc('note')
          .set({
        'note': note,
      });
    }

    if (file != null) {
      String url = await uploadImage();
      await firestore
          .collection('Doctors')
          .doc(uid)
          .collection('Appointments')
          .doc(nodeId)
          .collection('Files')
          .doc(DateTime.now().millisecondsSinceEpoch.toString())
          .set({
        'url': url,
        'description': des,
      });
    }
    notifyPatient(
        widget.am.pm?.token,
        'Updated your appointment scheduled on ${widget.am.date} ${widget.am.week} at ${widget.am.time}.',
        'Notification from ${widget.am.doctorName}');
    setState(() {
      isUploading = false;
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

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Data saved !'),
      backgroundColor: Colors.green,
    ));
    Navigator.pop(context);
  }

  Future<String> uploadImage() async {
    try {
      final data = storage
          .ref()
          .child("images")
          .child(DateTime.now().millisecondsSinceEpoch.toString());
      uploadTask = data.putFile(file!);
      final snapshot = await uploadTask?.whenComplete(() => () {});
      url = (await snapshot?.ref.getDownloadURL())!;
      file = null;
      return url;
    } on FirebaseException catch (e) {
      Alert(context, e);
      file = null;
      setState(() {
        isUploading = false;
      });
      return '';
    }
  }

  showPrescriptionInputCard({pm = null}) {
    Size size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (context) {
          return PrescriptionInputCard(
            size: size,
            onChanged: (PrescriptionModel data) {
              setState(() {
                pmList.add(data);
              });
            },
            pm: pm,
          );
        });
  }

  showTreatmentInputCard({tm = null}) {
    Size size = MediaQuery.of(context).size;

    showDialog(
        context: context,
        builder: (context) {
          return Material(
            color: Colors.transparent,
            child: Center(
              child: TreatmentPlanInputCard(
                  size: size,
                  onSubmit: (TreatmentModel tPlan) {
                    setState(() {
                      tmList.add(tPlan);
                    });
                  },
                  tm: tm),
            ),
          );
        });
  }

  showNoteCard() {
    Size size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (context) {
          return NoteInputCard(
              onSubmit: (value) {
                setState(() {
                  note = value;
                });
              },
              size: size);
        });
  }

  showFileCard(size) {
    showDialog(
        context: context,
        builder: (context) {
          return FileInputCard(
            size: size,
            onUpload: (fi, d) {
              setState(() {
                imList.add(ImageModel(file: fi, description: d, url: ''));
                file = fi;
                des = d;
              });
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.black,
          ),
        ),
        title: Align(
          child: Text(
            'Appointment',
            style: TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          alignment: AlignmentDirectional.centerStart,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.white),
                      child: Center(
                        child: AppointmentCard(
                          size: size,
                          patientName: widget.am.patientName.toString(),
                          week: widget.am.week,
                          date: widget.am.date,
                          time: widget.am.time,
                          doctorName: widget.am.doctorName,
                          pm: widget.am.pm,
                          status: 'patienthomescreen',
                          month: widget.am.month,
                          doctorUid: uid,
                          patientUid: widget.am.patientUid,
                          onMorePressed: (int itemNo) {
                            print(itemNo);
                            autoShowCards(itemNo, context);
                          },
                          appId: widget.am.appId,
                          startTimeInMil: widget.am.startTimeInMil,
                          endTimeInMil: widget.am.endTimeInMil,
                          plan: widget.am.plan,
                          toothList: widget.am.toothList,
                          refresh: (appId){
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 12,),
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: kGrey),),
                      width: double.infinity,
                      padding: EdgeInsets.all(4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
                          SizedBox(height: 4,),
                          Text('${widget.am.plan}', style: TextStyle(fontSize: 16),),
                          SizedBox(height: 8,),
                          Wrap(
                            children: widget.am.toothList.map((e){

                              return FixedSizeTooth(index: e, onTap: (){}, nontapable: true, height: 40, width: 40,);
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: !(tmList.isEmpty) ? 20 : 0,
                    ),
                    !(tmList.isEmpty)
                        ? Text(
                            'Treatment Plans',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: !(tmList.isEmpty) ? 8 : 0,
                    ),
                    !(tmList.isEmpty)
                        ? Container(
                            height: size.height * 0.18,
                            width: double.infinity,
                            child: ListView.builder(
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: TreatmentPlanCard(
                                    tm: tmList[index],
                                    isPatient: true,
                                    size: size,
                                    editFunc: (TreatmentModel tm) {
                                      autoShowCards(1, context, tm: tm);
                                    },
                                    addFunc: () {
                                      showTreatmentInputCard(tm: null);
                                    },
                                  ),
                                );
                              },
                              itemCount: tmList.length,
                              scrollDirection: Axis.horizontal,
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: !(tmList.isEmpty) ? 16 : 0,
                    ),
                    !(pmList.isEmpty)
                        ? Text(
                            'Prescriptions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 8,
                    ),
                    !(pmList.isEmpty)
                        ? Container(
                            height: size.height * 0.18,
                            width: double.infinity,
                            child: ListView.builder(
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: PrescriptionCard(
                                    pm: pmList[index],
                                    editFunc: (PrescriptionModel pm) {
                                      showPrescriptionInputCard(pm: pm);
                                    },
                                  ),
                                );
                              },
                              itemCount: pmList.length,
                              scrollDirection: Axis.horizontal,
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 16,
                    ),
                    !(note.isEmpty)
                        ? Text(
                            'Note',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 8,
                    ),
                    !(note.isEmpty)
                        ? Text(
                            '$note',
                          )
                        : Container(),
                    SizedBox(
                      height: 16,
                    ),
                    (imList.isNotEmpty)
                        ? Text(
                            'Images',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 8,
                    ),
                    !(imList.isEmpty)
                        ? Container(
                            height: size.height * 0.4,
                            child: ListView.builder(
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ImageDesContainer(im: imList[index]),
                                );
                              },
                              itemCount: imList.length,
                              scrollDirection: Axis.horizontal,
                            ),
                          )
                        : Container(),
                    Container(
                      height: 100,
                    ),
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
