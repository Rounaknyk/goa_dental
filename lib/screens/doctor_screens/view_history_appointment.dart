import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
import '../../models/pre_model.dart';
import '../../models/prescription_model.dart';
import '../patient_screens/patient_details_screen.dart';
import 'package:http/http.dart' as http;

class ViewHistoryAppointment extends StatefulWidget {
  ViewHistoryAppointment({required this.am, this.itemNo = 0});
  AppModel am;
  int itemNo;

  @override
  State<ViewHistoryAppointment> createState() => _ViewHistoryAppointmentState();
}

class _ViewHistoryAppointmentState extends State<ViewHistoryAppointment> {
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
  String role = '';
  List<int> tList = [];
  List<PreModel> preList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = auth.currentUser!.uid;
    nodeId = '${widget.am.patientUid}_${widget.am.appId}';
    print(widget.am.doctorUid);
    if (widget.itemNo != 0) {
      print(widget.itemNo);
    }
    getDetails();
    getPre();
  }

  getPre() async {
    final data = await firestore.collection('Patients').doc(widget.am.patientUid).collection('Plan Prescriptions').get();

    setState(() {
      preList.clear();
      for(var pre in data.docs){
        preList.add(PreModel(title: pre['title'], des: pre['des'], preId: pre['preId']));
      }
    });
  }

  getDetails() async {
    getTreatmentPlans();
    getPrescriptionS();
    getNote();
    getImages();
  }


  getTreatmentPlans() async {
    final plans = await firestore
        .collection('Doctors')
        .doc(widget.am.doctorUid)
        .collection('History')
        .doc(nodeId)
        .collection('TreatmentPlans')
        .get();
    tmList.clear();
    for (var plan in plans.docs) {
      try {
        final data = await firestore
            .collection('Doctors')
            .doc(uid)
            .collection('History')
            .doc(nodeId)
            .collection('TreatmentPlans')
            .doc(plan.id)
            .collection('Tooth List').get();

        for (var tooth in data.docs) {
          tList.add(tooth['tooth']);
        }

        try {
          tmList.add(TreatmentModel(
              procedure: plan['procedure'],
              note: plan['note'],
              discount: plan['discount'],
              discountSymbol: plan['discountSymbol'],
              total: plan['total'],
              cost: plan['cost'],
              unit: plan['unit'],
              id: plan['id'],
              toothList: tList),);
        }catch(e){
          continue;
        }
      }catch(e){
        continue;
      }
    }
    setState(() {});
  }

  getPrescriptionS() async {
    final pre = await firestore
        .collection('Doctors')
        .doc(widget.am.doctorUid)
        .collection('History')
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
    print(widget.am.doctorUid);
    final notee = await firestore
        .collection('Doctors')
        .doc(widget.am.doctorUid)
        .collection('History')
        .doc(nodeId)
        .collection('Note')
        .doc('note')
        .get();
    setState(() {
      note = notee['note'];
    });
  }

  getImages() async {
    final images = await firestore
        .collection('Doctors')
        .doc(widget.am.doctorUid)
        .collection('History')
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
                          month: widget.am.month,
                          doctorUid: uid,
                          patientUid: widget.am.patientUid,
                          onMorePressed: (int itemNo) {
                            print(itemNo);
                          },
                          appId: widget.am.appId,
                          startTimeInMil: widget.am.startTimeInMil,
                          endTimeInMil: widget.am.endTimeInMil,
                          refresh: (appId){
                            Navigator.pop(context);
                          }, plan: widget.am.plan, toothList: widget.am.toothList,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: kGrey),),
                      width: double.infinity,
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Treatment Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
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
                    SizedBox(height: 16,),
                    (preList.isNotEmpty) ? Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: kGrey),),
                      width: double.infinity,
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Prescriptions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
                          SizedBox(height: 4 ,),
                          ListView(
                            shrinkWrap: true,
                            children: preList.map((e){

                              return ListTile(title: Text(e.title, style: TextStyle(fontSize: 18)), subtitle: Text(e.des, style: TextStyle(fontSize: 16)), contentPadding: EdgeInsets.all(0),);
                            }).toList(),
                          ),
                        ],
                      ),
                    ) : SizedBox(),
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
                      height: size.height * 0.2,
                      width: size.width * 0.8,
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: TreatmentPlanCard(
                              tm: tmList[index],
                              size: size,
                              editFunc: (TreatmentModel tm) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You cannot edit appointment history')));
                              },
                              addFunc: () {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You cannot edit appointment history')));
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
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You cannot edit appointment history')));
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
