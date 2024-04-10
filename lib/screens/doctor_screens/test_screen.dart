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
import '../../providers/add_patient_provider.dart';

class TestScreen extends StatefulWidget {
  TestScreen({required this.patientUid, this.status = 'normal'});
  String patientUid;
  String status;

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
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

  createPre(){
    showDialog(
        context: context,
        builder: (context) {
          return Material(
            color: Colors.transparent,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SelectionPrescriptionCard(title: '', readOnly: false, onChecked: (checked, tit, d){
                      setState(() {
                        isChecked = checked;
                        title = tit;
                        des = d;
                      });
                    }, des: '', onChanged: (checked, tit, d){
                      setState(() {
                        isChecked = checked;
                        title = tit;
                        des = d;
                      });
                    },),
                    SizedBox(
                      height: 12,
                    ),
                    Container(
                      child: CustomButton(
                          text: 'ADD',
                          backgroundColor: kPrimaryColor,
                          onPressed: () {
                            setState(() {
                              PreModel pm = PreModel(title: title, des: des, isChecked: isChecked, preId: DateTime.now().millisecondsSinceEpoch.toString());
                              preList.add(pm);
                              if(isChecked){
                                selectedPreList.add(pm);
                                Provider.of<AddPreProvider>(context, listen: false)
                                    .setPList(selectedPreList);
                              }
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
    String dateMonth = DateTimeParser(DateTime.now().toString()).date + DateTimeParser(DateTime.now().toString()).getMonth()+DateTimeParser(DateTime.now().toString()).getYear();

    for (var plan in selectedPlanList) {
      firestore
          .collection('Patients')
          .doc(widget.patientUid)
          .collection('Plans')
          .doc(plan.plan)
          .set({
        "plan": plan.plan,
        "toothList": plan.toothList,
        "time": dateMonth,
      });
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

    for (var pre in selectedPreList) {
      firestore
          .collection('Patients')
          .doc(widget.patientUid)
          .collection('Plan Prescriptions')
          .doc(pre.title)
          .set({
        "title": pre.title,
        "des": pre.des,
        "preId": pre.preId,
      });
    }

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
          context, MaterialPageRoute(builder: (context) => NavScreen()));
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
    addInitialCards();
  }

  addInitialCards() async {
    setState(() {
      isLoading = true;
    });
    var list = Provider.of<AddPlanProvider>(context, listen: false).pList;
    var list2 = Provider.of<AddPreProvider>(context, listen: false).pList;

    if(widget.status != 'normal' || widget.patientUid.isNotEmpty) {
      list.clear();
      list2.clear();
      final data = await firestore.collection('Patients')
          .doc(widget.patientUid)
          .collection('Plans')
          .get();
      final data2 = await firestore.collection('Patients').doc(
          widget.patientUid).collection('Plan Prescriptions').get();
      for (var plan in data.docs) {
        list.add(
          PlanModel(plan: plan['plan'],
              toothList: plan['toothList'],
              isChecked: true, time: plan['time']),
        );
      }
      for (var pre in data2.docs) {
        list2.add(
          PreModel(title: pre['title'], des: pre['des'], isChecked: true, preId: pre['preId']),
        );
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

      preList.add(
        PreModel(title: 'Cap Nurokind Forte -z (30)', des: 'Take one capsule after breakfast for 30 days', preId: DateTime.now().millisecondsSinceEpoch.toString()),
      );

      preList.add(
        PreModel(title: 'Tab Acecloren-P (10)', des: 'Can take one tablet every 12 hours on a full stomach', preId: DateTime.now().millisecondsSinceEpoch.toString()),
      );
      preList.add(
        PreModel(title: 'Tab Zipant 40', des: 'Take one tablet 30 minutes before breakfast on empty stomach', preId: DateTime.now().millisecondsSinceEpoch.toString()),
      );
      preList.add(
        PreModel(title: 'Colgate Phosflor Mouthwash', des: 'Rinse with 10 ml undiluted twice daily for on minute and then spit. Do not eat or drink for 30 minutes after rinsing.', preId: DateTime.now().millisecondsSinceEpoch.toString()),
      );

      List<PlanModel> pmList = [];
      List<PreModel> pmList2 = [];
      for (var li in list) {
        var value = 0;
        for (var plan in planList) {
          if (li.plan == plan.plan) {
            value = 1;
            plan.toothList = li.toothList;
            plan.isChecked = li.isChecked;
          }
        }
        if (value == 0) {
          pmList.add(li);
        }
      }

      for (var li in list2) {
        var value = 0;
        for (var pre in preList) {
          if (li.title == pre.title) {
            value = 1;
            pre.isChecked = li.isChecked;
            pre.des = li.des;
          }
        }
        if (value == 0) {
          pmList2.add(li);
        }
      }

      for (var plan in pmList) {
        planList.add(plan);
      }


      for (var pre in pmList2) {
        preList.add(pre);
      }


      for (var plan in planList) {
        if (plan.isChecked) selectedPlanList.add(plan);
      }

      for (var pre in preList) {
        if (pre.isChecked) selectedPreList.add(pre);
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
                  PatientDetailsScreen(pm: pm, uid: widget.patientUid,)));
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
                        isChecked: e.isChecked,
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
                Text(
                  'Prescriptions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 8,
                ),
                Column(
                  children: preList.map((e){

                    return SelectionPrescriptionCard(title: e.title, onChecked: (value, title, des){
                      setState(() {
                        if(value){
                          selectedPreList.add(PreModel(title: title, des: des, isChecked: value, preId: DateTime.now().millisecondsSinceEpoch.toString()),);
                          Provider.of<AddPreProvider>(context, listen: false)
                              .setPList(selectedPreList);
                        }
                        else{
                          selectedPreList.remove(PreModel(title: title, des: des, isChecked: value, preId: DateTime.now().millisecondsSinceEpoch.toString()),);
                          Provider.of<AddPreProvider>(context, listen: false)
                              .setPList(selectedPreList);
                        }
                      });
                    }, des: e.des, isChecked: e.isChecked,);
                  }).toList(),
                ),
                SizedBox(
                  height: 16,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      createPre();
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
                              "Add Prescription",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : Container(),
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
