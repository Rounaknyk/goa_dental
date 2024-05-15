import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goa_dental_clinic/classes/erase_patient_data.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/custom_widgets/selection_prescription_card.dart';
import 'package:goa_dental_clinic/custom_widgets/selection_with_tooth.dart';
import 'package:goa_dental_clinic/providers/add_plan_provider.dart';
import 'package:goa_dental_clinic/providers/add_pre_provider.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/nav_screen.dart';
import 'package:goa_dental_clinic/screens/patient_screens/patient_details_screen.dart';
import 'package:googleapis/vision/v1.dart';
import 'package:provider/provider.dart';

import '../../classes/date_time_parser.dart';
import '../../models/patient_model.dart';
import '../../models/plan_model.dart';
import '../../models/pre_model.dart';
import '../../models/user_model.dart';
import '../../providers/add_patient_provider.dart';
import '../../providers/user_provider.dart';

class CompletedPlanScreen extends StatefulWidget {
  CompletedPlanScreen({required this.patientUid, this.status = 'normal', required this.pm});
  String patientUid;
  String status;
  PatientModel pm;

  @override
  State<CompletedPlanScreen> createState() => _CompletedPlanScreenState();
}

class _CompletedPlanScreenState extends State<CompletedPlanScreen> {
  List<Widget> cards = [];
  bool isCreatingCard = false;
  String titleName = '';
  List<String> titles = [];
  List<Map> toothListMap = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  List<PlanModel> planList = [];
  List<PreModel> preList = [];
  List<PlanModel> selectedPlanList = [];
  List<PreModel> selectedPreList = [];
  String title = '', des = '';
  bool isChecked = false;
  bool isLoading = false;
  List<PlanModel> alrList = [];
  UserModel? um;
  List<PlanModel> noToothList = [
    PlanModel(plan: 'Scalling and polishing', toothList: [], time: ''),
    PlanModel(plan: 'Deep Scaling', toothList: [], time: ''),
    PlanModel(plan: 'Complete denture', toothList: [], time: ''),
  ];

  createCard() {
    showDialog(
        context: context,
        builder: (context) {
          return Material(
            color: Colors.transparent,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        maxLines: null,
                        onChanged: (newValue) {
                          setState(() {
                            titleName = newValue;
                          });
                        },
                        decoration: InputDecoration(hintText: 'Enter title'),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Container(
                    child: CustomButton(
                        text: 'ADD',
                        backgroundColor: kPrimaryColor,
                        onPressed: () {
                          setState(() {
                            String time = DateTimeParser(DateTime.now().toString()).date + DateTimeParser(DateTime.now().toString()).getMonth()+DateTimeParser(DateTime.now().toString()).getYear();
                            planList
                                .add(PlanModel(plan: titleName, toothList: [], time: time));
                            Provider.of<AddPlanProvider>(context, listen: false)
                                .setPList(selectedPlanList);
                          });
                          Navigator.pop(context);
                        }),
                    width: 80,
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Container(
                    child: CustomButton(
                        text: 'CANCEL',
                        backgroundColor: kPrimaryColor,
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    width: 80,
                  ),
                ],
              ),
            ),
          );
        });
  }

  save() async {
    setState(() {
      isLoading = true;
    });

    for (var e in selectedPreList) {
      print("${e.title + e.des.toString()}");
    }
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    String dateMonth = DateTimeParser(DateTime.now().toString()).getFormattedDate();
    String week = DateTimeParser(DateTime.now().toString()).getWeek();
    // String dateMonth = DateTimeParser(DateTime.now().toString()).date + DateTimeParser(DateTime.now().toString()).getMonth()+DateTimeParser(DateTime.now().toString()).getYear();

    for (var plan in selectedPlanList) {

      bool isAlreadyStored = false;

      for(var x in alrList){
        if(x.plan == plan.plan){
          isAlreadyStored = true;
          break;
        }
      }

      if(!isAlreadyStored){
        firestore
            .collection('Patients')
            .doc(widget.patientUid)
            .collection('Completed Plans')
            .doc(plan.plan)
            .set({
          "plan": plan.plan,
          "toothList": plan.toothList,
          "time": dateMonth,
          "note" : plan.note,
          "docUid" : auth.currentUser!.uid,
          "docName" : um!.name,
        }, SetOptions(merge: false));

        firestore
            .collection('Doctors')
            .doc(auth.currentUser!.uid)
            .collection('Completed Plans')
            .doc(widget.patientUid)
            .collection('Plans')
            .doc(plan.plan)
            .set({
          "plan": plan.plan,
          "toothList": plan.toothList,
          "time": dateMonth,
          "note" : plan.note,
          "docName" : um!.name,
          "docUid" : auth.currentUser!.uid,
        });


        firestore
            .collection('Completed Plans')
            .doc('${plan.time}${plan.plan}${widget.patientUid}${timeStamp}')
            .set({
          "plan": plan.plan,
          "toothList": plan.toothList,
          "time": dateMonth,
          "note" : plan.note,
          "docName" : um!.name,
          "docUid" : auth.currentUser!.uid,
          "patientName" : widget.pm.patientName,
          "patientUid" : widget.patientUid,
          "week" : week
        });
      }

    }
    //
    // for (var plan in selectedPlanList) {
    //   firestore
    //       .collection('Patients')
    //       .doc(widget.patientUid)
    //       .collection('Plans History')
    //       .doc(plan.plan)
    //       .set({
    //     "plan": plan.plan,
    //     "toothList": plan.toothList,
    //     "time": dateMonth,
    //   });
    // }

    Provider.of<AddPlanProvider>(context, listen: false).emptyPlist();
    Provider.of<AddPatientProvider>(context, listen: false).resetPatient();
    Provider.of<AddPatientProvider>(context, listen: false).emptyList();
    Provider.of<AddPreProvider>(context, listen: false).emptyPlist();

    setState(() {
      isLoading = false;
    });

    ErasePatientData(context: context).erase();

    if(widget.status == 'create_patient'){
      final patient = await firestore.collection('Patients').doc(widget.patientUid).get();

      PatientModel pm = PatientModel(patientUid: patient['patientUid'],
          patientName: patient['patientName'],
          email: patient['email'],
          dob: patient['dob'],
          gender: patient['gender'],
          phoneNumber1: patient['phoneNumber'],
          streetAddress: patient['streetAddress'],
          profileUrl: patient['profileUrl']);

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => PatientDetailsScreen(pm: pm, uid: widget.patientUid,)));

    }else{
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => PatientDetailsScreen(pm: widget.pm, uid: widget.patientUid,)));
          // Navigator.pop(context);
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    um = Provider.of<UserProvider>(context, listen: false).um;
    addInitialCards();
  }

  addInitialCards() async {
    setState(() {
      isLoading = true;
    });
    var list = Provider.of<AddPlanProvider>(context, listen: false).pList;

    if(widget.status != 'normal' || widget.patientUid.isNotEmpty) {
      list.clear();
      final data = await firestore.collection('Patients')
          .doc(widget.patientUid)
          .collection('Completed Plans')
          .get();
      // final data2 = await firestore.collection('Patients').doc(
      //     widget.patientUid).collection('Plan Prescriptions').get();
      for (var plan in data.docs) {
        try {
          list.add(
            PlanModel(plan: plan['plan'],
                toothList: plan['toothList'],
                isChecked: true, time: plan['time'], note: plan['note']),
          );
        }catch(e){
          continue;
        }
      }
      alrList = list;
      for (var pre in list) {
        print(pre.plan);
      }
    }

    setState(() {
      String time = DateTimeParser(DateTime.now().toString()).date + DateTimeParser(DateTime.now().toString()).getMonth()+DateTimeParser(DateTime.now().toString()).getYear();
      planList.add(
        PlanModel(plan: 'Scalling and polishing', toothList: [], time: time),
      );
      planList.add(
        PlanModel(plan: 'Deep Scaling', toothList: [],  time: time),
      );
      planList.add(
        PlanModel(plan: 'Composite filings', toothList: [],  time: time),
      );
      planList.add(
        PlanModel(plan: 'GIC fillings', toothList: [],  time: time),
      );
      planList.add(
        PlanModel(plan: 'Root canal treatment', toothList: [],  time: time),
      );
      planList.add(
        PlanModel(plan: 'Crowns and bridges', toothList: [],  time: time),
      );
      planList.add(
        PlanModel(plan: 'Implants', toothList: [],  time: time),
      );
      planList.add(
        PlanModel(plan: 'Removable partial denture', toothList: [],  time: time),
      );
      planList.add(
        PlanModel(plan: 'Complete denture', toothList: [], time: time),
      );


      List<PlanModel> pmList = [];
      for (var li in list) {
        var value = 0;
        for (var plan in planList) {
          if (li.plan == plan.plan) {
            value = 1;
            plan.toothList = li.toothList;
            plan.isChecked = li.isChecked;
            plan.note = li.note;
          }
        }
        if (value == 0) {
          pmList.add(li);
        }
      }

      for (var plan in pmList) {
        planList.add(plan);
      }


      for (var plan in planList) {
        if (plan.isChecked) selectedPlanList.add(plan);
      }

      isLoading = false;
    });
  }

  isToothVisible(PlanModel e){
    bool res = true;
    noToothList.forEach((element) {
      if(element.plan == e.plan)
        res = false;
    });

    return res;
  }

  @override
  Widget build(BuildContext context) {
    // addInitialCards();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text("Treatment Plan"),
        leading: InkWell(child: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white,), onTap: () async {
          if(widget.status == 'normal'){
            setState(() {
              isLoading = true;
            });
            try {
              final patient = await firestore.collection('Patients').doc(
                  widget.patientUid).get();

              PatientModel pm = PatientModel(patientUid: patient['patientUid'],
                  patientName: patient['patientName'],
                  email: patient['email'],
                  dob: patient['dob'],
                  gender: patient['gender'],
                  phoneNumber1: patient['phoneNumber'],
                  streetAddress: patient['streetAddress'],
                  profileUrl: patient['profileUrl']);

              ErasePatientData(context: context).erase();
              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  PatientDetailsScreen(pm: pm, uid: widget.pm.patientUid,)));
            }catch(e){
              setState(() {
                isLoading = false;
              });
            }
          }
          else{
            Navigator.push(context, MaterialPageRoute(builder: (context) => NavScreen()));
          }
          setState(() {
            isLoading = false;
          });
        },),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(!isLoading)
          save();
        },
        child: isLoading ? Center(child: CircularProgressIndicator(color: Colors.white,)) : Icon(Icons.save),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: !isLoading ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Column(
                    children: planList.map((e) {

                      return SelectionWithTooth(
                        title: e.plan,
                        note: e.note,
                        isToothVisible: isToothVisible(e),
                        addList: e.toothList,
                        onAdd: (list, title, isChecked) {
                          e.toothList = list;
                          if (isChecked) {
                            selectedPlanList.forEach((element) {
                              if (element == title) {
                                element.toothList = list;
                              }
                            });
                            Provider.of<AddPlanProvider>(context, listen: false)
                                .setPList(selectedPlanList);
                          } else {
                            selectedPlanList.remove(e);
                            Provider.of<AddPlanProvider>(context, listen: false)
                                .setPList(selectedPlanList);
                          }
                        },
                        onChecked: (value, title) {
                          try {
                            if (value) {
                              selectedPlanList.add(PlanModel(
                                  plan: e.plan,
                                  toothList: e.toothList,
                                  time: e.time,
                                  isChecked: value));
                              Provider.of<AddPlanProvider>(context,
                                      listen: false)
                                  .setPList(selectedPlanList);
                            } else {
                              selectedPlanList.remove(e);
                              Provider.of<AddPlanProvider>(context,
                                      listen: false)
                                  .setPList(selectedPlanList);
                            }
                          } catch (e) {
                            print(e);
                          }
                        },
                        isChecked: e.isChecked, onNoteAdd: (String note, bool isChecked) {
                        e.note = note;

                        print("ON SAVE $note ${e.plan}");

                        if (isChecked) {
                          print('eached');
                          selectedPlanList.forEach((element) {
                            if (element.plan == e.plan) {
                              element.note = note;
                              print(element.note);
                            }
                          });

                          Provider.of<AddPlanProvider>(context, listen: false)
                              .setPList(selectedPlanList);
                        } else {
                          selectedPlanList.remove(e);
                          Provider.of<AddPlanProvider>(context, listen: false)
                              .setPList(selectedPlanList);
                        }
                        setState(() {
                        });
                      },
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      createCard();
                    });
                  },
                  child: !isCreatingCard
                      ? Container(
                          height: 80,
                          decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Text(
                              "Add Plan",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : Container(),
                ),
                SizedBox(
                  height: 16,
                ),
              ],
            ),
          ) : Center(child: CircularProgressIndicator(color: kPrimaryColor,),),
        ),
      ),
    );
  }
}

class TitleTooth {
  String title;
  List<int> tooth;

  TitleTooth({required this.title, required this.tooth});
}
