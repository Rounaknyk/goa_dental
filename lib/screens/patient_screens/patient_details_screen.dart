import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:goa_dental_clinic/classes/alert.dart';
import 'package:goa_dental_clinic/classes/date_time_parser.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/custom_widgets/done_plan_card.dart';
import 'package:goa_dental_clinic/custom_widgets/image_des_container.dart';
import 'package:goa_dental_clinic/custom_widgets/image_viewer.dart';
import 'package:goa_dental_clinic/custom_widgets/pending_plan_card.dart';
import 'package:goa_dental_clinic/custom_widgets/pre_card.dart';
import 'package:goa_dental_clinic/custom_widgets/selection_prescription_card.dart';
import 'package:goa_dental_clinic/models/image_model.dart';
import 'package:goa_dental_clinic/models/new_med_hist.dart';
import 'package:goa_dental_clinic/models/patient_model.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/completed_plan_screen.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/search_screen.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/test_screen.dart';
import 'package:goa_dental_clinic/screens/login_screen.dart';
import 'package:goa_dental_clinic/screens/patient_screens/add_patient_screen.dart';
import 'package:goa_dental_clinic/screens/patient_screens/view_patient_appointments.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../classes/get_patient_details.dart';
import '../../custom_widgets/file_input_card.dart';
import '../../custom_widgets/image_container.dart';
import '../../models/plan_model.dart';
import '../../models/pre_model.dart';
import 'package:fluttertoast/fluttertoast.dart' as flut;

import '../doctor_screens/nav_screen.dart';

class PatientDetailsScreen extends StatefulWidget {
  PatientDetailsScreen(
      {required this.pm,
      this.uid = '',
      this.isPatient = false,
      this.showBackIcon = true});
  PatientModel? pm;
  String uid;
  bool isPatient;
  bool showBackIcon;

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  bool isLoading = false;
  bool isImgUploading = false;
  bool isImgUploading2 = false;
  bool isImgUploading3 = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  List<NewMedHistory> medHisList = [];
  List<Map<String, List<NewMedHistory>>> finalMedHisList = [];
  List<Map<String, List<PlanModel>>> finalTPlan = [];
  String profileUrl = '';
  List<PlanModel> pendingPlanList = [];
  List<PlanModel> donePlanList = [];
  List<PreModel> preList = [];
  List<ImageModel> imList = [];
  List<ImageModel> imList2 = [];
  List<ImageModel> bloodList = [];
  List<ImageModel> photoList = [];
  String accessToken = 'No token';
  TextEditingController dateController = TextEditingController();

  List<Map<String, List<NewMedHistory>>> convertListToMap(
      List<NewMedHistory> medHisList) {
    Map<String, List<NewMedHistory>> resultMap = {};

    for (NewMedHistory medHis in medHisList) {
      if (!resultMap.containsKey(medHis.time)) {
        resultMap[medHis.time] = [];
      }

      resultMap[medHis.time]!.add(medHis);
    }

    List<Map<String, List<NewMedHistory>>> result =
        resultMap.entries.map((entry) => {entry.key: entry.value}).toList();

    for (var r in result) {
      // print(r[r.keys.first][0]);
    }
    return result;
  }

  getMedicalHistory() async {
    setState(() {
      isLoading = true;
    });
    final diseases = await firestore
        .collection('Patients')
        .doc(widget.uid)
        .collection('Medical History')
        .get();

    medHisList.clear();
    for (var dis in diseases.docs) {
      try {
        medHisList.add(NewMedHistory(
            time: dis['time'], disease: dis['disease'], time2: dis['time2']));
      } catch (e) {
        medHisList.add(NewMedHistory(
            time: dis['time'], disease: dis['disease'], time2: ''));
      }
    }

    setState(() {
      // finalMedHisList = convertListToMap(medHisList);
    });

    setState(() {
      isLoading = false;
    });
  }

  getPendingPlans() async {
    final apps = await firestore
        .collection('Patients')
        .doc(widget.uid)
        .collection('Appointments')
        .get();
    final plans = await firestore
        .collection('Patients')
        .doc(widget.uid)
        .collection('Plans')
        .get();

    for (var plan in plans.docs) {
      var value = true;
      for (var app in apps.docs) {
        if (app['plan'] == plan['plan']) {
          value = false;
          //pending
          pendingPlanList.add(PlanModel(
              plan: plan['plan'],
              toothList: plan['toothList'],
              time: plan['time'],
              note: plan['note']));
        }
      }
      if (value) {
        pendingPlanList.add(PlanModel(
            plan: plan['plan'],
            toothList: plan['toothList'],
            time: plan['time'],
            note: plan['note']));
      }
    }

    setState(() {
      finalTPlan = convertPlanListToMap(pendingPlanList);
    });
  }

  List<Map<String, List<PlanModel>>> convertPlanListToMap(
      List<PlanModel> pendingPlanList) {
    Map<String, List<PlanModel>> resultMap = {};

    for (PlanModel plan in pendingPlanList) {
      if (!resultMap.containsKey(plan.time)) {
        resultMap[plan.time] = [];
      }

      resultMap[plan.time]!.add(plan);
    }

    List<Map<String, List<PlanModel>>> result =
        resultMap.entries.map((entry) => {entry.key: entry.value}).toList();

    for (var r in result) {
      print(r[r.keys.first]?[0].plan);
    }
    return result;
  }

  addMed() async {
    showMedDialog();
  }

  getDonePlans() async {
    final data = await firestore
        .collection('Patients')
        .doc(widget.uid)
        .collection('Completed Plans')
        .get();
    donePlanList.clear();
    for (var plan in data.docs) {
      try {
        donePlanList.add(PlanModel(
            plan: plan['plan'],
            toothList: plan['toothList'],
            time: plan['time'],
            note: plan['note']));
      } catch (e) {
        continue;
      }
    }
    setState(() {});
  }

  showMedDialog({String status = '', NewMedHistory? e = null}) async {
    showDialog(
        context: context,
        builder: (context) {
          return Material(
            color: Colors.transparent,
            child: Center(
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Add Disease',
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        TextField(
                          controller: desController,
                          decoration: InputDecoration(hintText: 'Enter here'),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        TextField(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(), //get today's date
                                firstDate: DateTime(
                                    1900), //DateTime.now() - not to allow to choose before today.
                                lastDate: DateTime(2101));

                            if (pickedDate != null) {
                              setState(() {
                                //t(pickedDate);
                                final dob = DateFormat('yyyy-MM-dd')
                                    .format(pickedDate!);
                                print(dob);
                                String date =
                                    DateTimeParser(pickedDate.toString())
                                        .getFormattedDate();
                                dateController.text = date;
                                // DateTime dateTime = DateTime(pickedDate!.year,
                                //     pickedDate!.month, pickedDate!.day);
                                // ageController.text = AgeCalculator
                                //     .age(dateTime)
                                //     .years
                                //     .toString();
                                // dobController.text = dob!;
                              });
                            }
                            // updateData();
                          },
                          controller: dateController,
                          decoration: InputDecoration(
                              hintText: 'Tap to add treatment date'),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              if (desController.text.isNotEmpty) {
                                Navigator.pop(context);
                                String dateMonth = DateTimeParser(
                                            DateTime.now().toString())
                                        .date +
                                    DateTimeParser(DateTime.now().toString())
                                        .getMonth() +
                                    DateTimeParser(DateTime.now().toString())
                                        .getYear();

                                setState(() {
                                  // medHisList.forEach((element) {
                                  //   if(element.time == dateMonth){
                                  //     element.diseases.add(desController.text);
                                  //   }
                                  // });
                                  if (finalMedHisList.isNotEmpty) {
                                    finalMedHisList.forEach((element) {
                                      element[element.keys.first]?.add(
                                          NewMedHistory(
                                              time: dateMonth,
                                              disease: desController.text,
                                              time2: dateController.text));
                                    });
                                  } else {
                                    Map<String, List<NewMedHistory>> map = {
                                      dateMonth: [
                                        NewMedHistory(
                                            time: dateMonth,
                                            disease: desController.text,
                                            time2: dateController.text)
                                      ],
                                    };
                                    finalMedHisList.add(map);
                                  }
                                });
                                String time = dateMonth.toString();
                                await firestore
                                    .collection('Patients')
                                    .doc(widget.uid)
                                    .collection('Medical History')
                                    .doc(desController.text)
                                    .set({
                                  'disease': desController.text,
                                  'time': time,
                                  'time2': dateController.text
                                });
                                if(status == 'edit'){
                                  medHisList.remove(e);
                                }

                                medHisList.add(NewMedHistory(
                                    time: time,
                                    disease: desController.text,
                                    time2: dateController.text));

                                desController.text = '';
                                dateController.clear();
                                setState(() {});
                              } else {
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            'ADD',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(kPrimaryColor)),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    child: InkWell(
                      child: Icon(
                        Icons.cancel,
                        color: Colors.red,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    right: 0,
                  ),
                ],
              ),
            ),
          );
        });
  }

  getPreList() async {
    final data = await firestore
        .collection('Patients')
        .doc(widget.uid)
        .collection('Plan Prescriptions')
        .get();

    print(widget.uid);
    setState(() {
      for (var pre in data.docs) {
        preList.add(
          PreModel(title: pre['title'], des: pre['des'], preId: pre['preId']),
        );
      }
    });
  }

  deletePre(PreModel pm) async {
    print(widget.pm!.patientUid);
    print(pm.title);
    await firestore
        .collection('Patients')
        .doc(widget.pm!.patientUid)
        .collection('Plan Prescriptions')
        .doc(pm.title)
        .delete();
    setState(() {
      preList.remove(pm);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.pm == null) {
      getDetails();
    }
    checkRole();
    getAccessToken();
    getMedicalHistory();
    getPendingPlans();
    getDonePlans();
    getPreList();
    getFiles();
  }

  getAccessToken() async {
    final data = await firestore.collection('Users').doc(widget.uid).get();

    accessToken = data['accessToken'];
  }

  checkRole() async {
    final data = await firestore
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (data['role'] != 'doctor') {
      widget.isPatient = true;
    }
  }

  getDetails() async {
    setState(() {
      isLoading = true;
    });
    final datas = await firestore.collection('Patients').doc(widget.uid).get();
    widget.pm = GetPatientDetails().get(datas);
    setState(() {
      isLoading = false;
    });
  }

  sendEmail(email, subject, body) async {
    Uri mail = Uri.parse("mailto:$email?subject=$subject&body=$body");
    if (await launchUrl(mail)) {
      //email app opened
    } else {
      Alert(context, 'Error: Invaid email');
      //email app is not opened
    }
  }

  call(number) async {
    try {
      // if (number.startsWith("+91"))
      //   await FlutterPhoneDirectCaller.callNumber("$number");
      // else if (number.startsWith("91"))
      //   await FlutterPhoneDirectCaller.callNumber("+$number");
      // else
      //   await FlutterPhoneDirectCaller.callNumber("+91$number");
    } catch (e) {
      Alert(context, "Error: $e");
    }
  }

  getFiles() async {
    setState(() {
      isLoading = true;
    });
    final data = await firestore
        .collection('Patients')
        .doc(widget.uid)
        .collection('Files')
        .get();
    final data2 = await firestore
        .collection('Patients')
        .doc(widget.uid)
        .collection('Blood Report')
        .get();
    final data3 = await firestore
        .collection('Patients')
        .doc(widget.uid)
        .collection('Photos')
        .get();

    //xray
    setState(() {
      imList.clear();
      for (var pic in data.docs) {
        print(pic['url']);
        imList.add(ImageModel(
            url: pic['url'],
            description: pic['des'],
            isPdf: pic['url'].toString().contains('pdf')));
      }
    });
    setState(() {
      bloodList.clear();
      for (var pic in data2.docs) {
        bloodList.add(ImageModel(
            url: pic['url'],
            description: pic['des'],
            isPdf: pic['url'].toString().contains('pdf')));
      }
    });
    setState(() {
      photoList.clear();
      for (var pic in data3.docs) {
        photoList.add(ImageModel(
            url: pic['url'],
            description: pic['des'],
            isPdf: pic['url'].toString().contains('pdf')));
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  uploadImage(File file, des) async {
    try {
      if (file != null) {
        setState(() {
          isImgUploading = true;
        });
        late UploadTask ut;
        FirebaseStorage storage = FirebaseStorage.instance;

        ut = storage
            .ref()
            .child('images')
            .child(DateTime.now().millisecondsSinceEpoch.toString())
            .putFile(file);
        var snapshot = await ut.whenComplete(() {});

        String url = await snapshot.ref.getDownloadURL();
        String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
        imList.add(ImageModel(
            url: url, description: des, isPdf: (file.path.endsWith('.pdf'))));
        setState;
        await firestore
            .collection('Patients')
            .doc(widget.uid)
            .collection('Files')
            .doc(timeStamp)
            .set({
          'url': url,
          'des': des,
        });
        setState(() {
          isImgUploading = false;
        });
        print(url);
      }
    } catch (e) {
      Alert(context, e);
      setState(() {
        isImgUploading = false;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    preEditController.dispose();
    desController.dispose();
  }

  TextEditingController preEditController = TextEditingController();

  saveEditedPre(PreModel pm) async {
    await firestore
        .collection('Patients')
        .doc(widget.pm!.patientUid)
        .collection('Plan Prescriptions')
        .doc(pm.title)
        .set(
      {'des': preEditController.text, 'title': pm.title, 'preId': pm.preId},
    );

    setState(() {
      preList.remove(pm);
      pm.des = preEditController.text;
      preList.add(pm);
      preList.sort((a, b) {
        return a.title.compareTo(b.title);
      });
      // preList.map((e){
      //   if(e == pm){
      //     e.des = preEditController.text;
      //     return e;
      //   }
      // });
    });

    preEditController.clear();
  }

  editPre(PreModel pm) async {
    preEditController.text = pm.des;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete this prescription?'),
            content: TextField(
              controller: preEditController,
              minLines: 1,
              maxLines: null,
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')),
              ElevatedButton(
                  onPressed: () async {
                    await saveEditedPre(pm);
                    Navigator.pop(context);
                  },
                  child: Text('Save')),
            ],
          );
        });

    // showDialog(context: context, builder: (context){
    //
    //   return Center(
    //     child: Container(
    //       width: MediaQuery.of(context).size.width * 0.8,
    //       decoration: BoxDecoration(color: Colors.white),
    //       child: Container(
    //         height: 100,
    //         child: TextFormField(
    //
    //         ),
    //       ),
    //     ),
    //   );
    // });
  }

  uploadBloodReport(file, des) async {
    try {
      if (file != null) {
        setState(() {
          isImgUploading2 = true;
        });
        late UploadTask ut;
        FirebaseStorage storage = FirebaseStorage.instance;

        ut = storage
            .ref()
            .child('images')
            .child(DateTime.now().millisecondsSinceEpoch.toString())
            .putFile(file);
        var snapshot = await ut.whenComplete(() {});

        String url = await snapshot.ref.getDownloadURL();
        bloodList.add(ImageModel(url: url, description: des));
        setState;
        String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

        await firestore
            .collection('Patients')
            .doc(widget.uid)
            .collection('Blood Report')
            .doc(timeStamp)
            .set({
          'url': url,
          'des': des,
        });
        setState(() {
          isImgUploading2 = false;
        });
        print(url);
      }
    } catch (e) {
      Alert(context, e);
      setState(() {
        isImgUploading2 = false;
      });
    }
  }

  uploadPhotos(file, des) async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    bool isPdf = file.toString().endsWith('.pdf\'');
    try {
      if (file != null) {
        setState(() {
          isImgUploading3 = true;
        });
        late UploadTask ut;
        FirebaseStorage storage = FirebaseStorage.instance;

        ut = storage
            .ref()
            .child('photos')
            .child(DateTime.now().millisecondsSinceEpoch.toString())
            .putFile(file);
        var snapshot = await ut.whenComplete(() {});

        String url = await snapshot.ref.getDownloadURL();
        photoList.add(ImageModel(url: url, description: des));
        setState;
        await firestore
            .collection('Patients')
            .doc(widget.uid)
            .collection('Photos')
            .doc(timeStamp)
            .set({
          'url': url,
          'des': des,
          'isPdf': isPdf,
        });
        setState(() {
          isImgUploading3 = false;
        });
        print(url);
      }
    } catch (e) {
      Alert(context, e);
      setState(() {
        isImgUploading3 = false;
      });
    }
  }

  TextEditingController desController = TextEditingController();

  deleteMed(NewMedHistory e) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Are you sure you want to delete it?'),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    try {
                      // List<NewMedHistory> newHis = medHisList;
                      // newHis.remove(e);
                      // newHis.forEach((element) {
                      //   print(element.disease);
                      //   if (element.time == date && med == element.disease) {
                      //     newHis.remove(element);
                      //   }
                      // });
                      setState(() {
                        medHisList.remove(e);
                      });
                    } catch (E) {
                      print(E);
                    }
                    print("reached");
                    await firestore
                        .collection('Patients')
                        .doc(widget.uid)
                        .collection('Medical History')
                        .doc(e.disease)
                        .delete();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete: ${e}')));
                  }
                },
                child: Text('Delete'),
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.redAccent),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: !isLoading
              ? SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            widget.showBackIcon
                                ? InkWell(
                                    child: Icon(
                                      Icons.arrow_back_ios_new_outlined,
                                      color: Colors.black,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => NavScreen(
                                                    screenNo: 3,
                                                  )));
                                    },
                                  )
                                : Container(
                                    height: 1,
                                    width: 1,
                                  ),
                            SizedBox(
                              width: widget.showBackIcon ? 8 : 0,
                            ),
                            (widget.pm!.profileUrl == '')
                                ? InkWell(
                                    child: CircleAvatar(
                                      backgroundColor: kPrimaryColor,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ImageViewer(
                                                  im: ImageModel(
                                                      url: widget
                                                          .pm!.profileUrl))));
                                    },
                                  )
                                : InkWell(
                                    child: CircleAvatar(
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              widget.pm!.profileUrl,
                                              errorListener: (s) {}),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ImageViewer(
                                                  im: ImageModel(
                                                      url: widget
                                                          .pm!.profileUrl))));
                                    },
                                  ),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Text(
                                "${widget.pm?.patientName}",
                                style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ViewPatientAppointments(
                                                uid: widget.uid)));
                              },
                              child: Text(
                                'View Appointments',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll(kPrimaryColor)),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        ExpansionTile(
                          title: Text('Details'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Container(
                                child: Row(
                                  children: [
                                    Text(
                                      'Access Token: ',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        child: Text(
                                          '${accessToken}',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: kPrimaryColor),
                                        ),
                                        onTap: () async {
                                          await Clipboard.setData(
                                              ClipboardData(text: accessToken));
                                          flut.Fluttertoast.showToast(
                                              msg: "Access Token Copied!",
                                              toastLength:
                                                  flut.Toast.LENGTH_LONG,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 2,
                                              backgroundColor: Colors.black,
                                              textColor: Colors.white,
                                              fontSize: 16.0);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            (widget.pm!.email.isNotEmpty)
                                ? Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    child: Container(
                                      child: Row(
                                        children: [
                                          Text(
                                            'Email: ',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          InkWell(
                                            child: Text(
                                              '${widget.pm!.email}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: kPrimaryColor),
                                            ),
                                            onTap: () {
                                              sendEmail(
                                                  widget.pm!.email, "", "");
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 1,
                                    width: 1,
                                  ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Container(
                                child: Row(
                                  children: [
                                    Text(
                                      'Phone: ',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        child: Text(
                                          '${widget.pm!.phoneNumber1}',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: kPrimaryColor),
                                        ),
                                        onTap: () {
                                          call(widget.pm!.phoneNumber1);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            (widget.pm!.dob.isNotEmpty)
                                ? Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    child: Container(
                                      child: Row(
                                        children: [
                                          Text(
                                            'Dob: ',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '${widget.pm!.dob}',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 1,
                                    width: 1,
                                  ),
                            (widget.pm!.streetAddress.isNotEmpty)
                                ? Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    child: Container(
                                      child: Row(
                                        children: [
                                          Text(
                                            'Address: ',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Expanded(
                                              child: Text(
                                            '${widget.pm!.streetAddress}',
                                            style: TextStyle(fontSize: 16),
                                          )),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 1,
                                    width: 1,
                                  ),
                          ],
                        ),
                        // ExpansionTile(
                        //   title: Text(
                        //     'Access Token',
                        //     style: TextStyle(fontSize: 20),
                        //   ),
                        //   children: [
                        //     InkWell(child: Text('$accessToken', style: TextStyle(fontSize: 16, color: Colors.blue),), onTap: () async {
                        //       //copy
                        //       await  Clipboard.setData(ClipboardData(text: accessToken));
                        //       flut.Fluttertoast.showToast(
                        //           msg: "Access Token Copied!",
                        //           toastLength: flut.Toast.LENGTH_LONG,
                        //           gravity: ToastGravity.BOTTOM,
                        //           timeInSecForIosWeb: 2,
                        //           backgroundColor: Colors.black,
                        //           textColor: Colors.white,
                        //           fontSize: 16.0
                        //       );
                        //     },),
                        //     SizedBox(height: 8,),
                        //   ],
                        //   initiallyExpanded: true,
                        // ),
                        // SizedBox(
                        //   height: widget.pm!.dob.isNotEmpty ? 12 : 0,
                        // ),
                        // Visibility(
                        //   visible: widget.pm!.dob.isNotEmpty,
                        //   child: ExpansionTile(
                        //     title: Text(
                        //       'Personal details',
                        //       style: TextStyle(fontSize: 20),
                        //     ),
                        //     children: [
                        //       RowText(
                        //           title: 'Date of birth: ',
                        //           content: widget.pm!.dob),
                        //     ],
                        //     initiallyExpanded: true,
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 12,
                        // ),
                        // ExpansionTile(
                        //   initiallyExpanded: true,
                        //   title: Text(
                        //     'Contact details',
                        //     style: TextStyle(fontSize: 20),
                        //   ),
                        //   children: [
                        //     RowText(
                        //       title: 'Phone Number: ',
                        //       content: widget.pm!.phoneNumber1,
                        //       func: () {
                        //         call(widget.pm!.phoneNumber1);
                        //       },
                        //       fontColor: Colors.blue,
                        //     ),
                        //     (widget.pm!.email.isNotEmpty)
                        //         ? RowText(
                        //             title: 'Email: ',
                        //             content: widget.pm!.email,
                        //             func: () {
                        //               sendEmail(widget.pm!.email, "", "");
                        //             },
                        //             fontColor: Colors.blue,
                        //           )
                        //         : Container(),
                        //     (widget.pm!.streetAddress.isNotEmpty)
                        //         ? RowText(
                        //             title: 'Street Address: ',
                        //             content: widget.pm!.streetAddress)
                        //         : Container(),
                        //   ],
                        // ),
                        SizedBox(
                          height: 12,
                        ),
                        ExpansionTile(
                            initiallyExpanded: true,
                            title: Row(
                              children: [
                                Text(
                                  'Medical History',
                                  style: TextStyle(fontSize: 20),
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                                !widget.isPatient
                                    ? InkWell(
                                        onTap: () async {
                                          await addMed();
                                        },
                                        child: CircleAvatar(
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          ),
                                          radius: 15,
                                          backgroundColor: kPrimaryColor,
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                            children: medHisList.map((e) {
                              return GestureDetector(
                                onLongPress: () async {
                                  await deleteMed(e);
                                  // showDialog(context: context, builder: (context){
                                  //
                                  //   return AlertDialog(
                                  //     title: Text('Delete this ?'),
                                  //     actions: [
                                  //       ElevatedButton(onPressed: (){
                                  //         Navigator.pop(context);
                                  //       }, child: Text('No')),
                                  //       ElevatedButton(onPressed: () async {
                                  //         Navigator.pop(context);
                                  //       }, child: Text('Yes')),
                                  //     ],
                                  //   );
                                  // });
                                },
                                child: Card(
                                  child: ListTile(
                                    title: Text(e.disease),
                                    subtitle: e.time2.isEmpty
                                        ? null
                                        : Text('Treatment date: ${e.time2}'),
                                    trailing: Column(children: [
                                      Text(e.time),
                                      SizedBox(height: 12.0,),
                                      InkWell(
                                        onTap: (){
                                          desController.text = e.disease;
                                          showMedDialog(status: 'edit', e : e);
                                          setState(() {
                                          });
                                        },
                                        child: Text(
                                          'Add Date',
                                          style: TextStyle(
                                              color: kPrimaryColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],),
                                  ),
                                ),
                              );
                              // return Padding(
                              //             padding: EdgeInsets.symmetric(vertical: 4),
                              //             child: Row(
                              //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //               children: [
                              //                 Expanded(
                              //                   child: Text(
                              //                     '${e.disease} (${e.time})',
                              //                     style: TextStyle(fontSize: 16),
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //           );
                            }).toList()
                            // children: finalMedHisList.map((e){
                            //
                            //   return ExpansionTile(
                            //     title: Text(e[e.keys.first]![0].time),
                            //     children: e[e.keys.first]!.map((e){
                            //
                            //       return Padding(
                            //         padding: EdgeInsets.symmetric(vertical: 4),
                            //         child: Row(
                            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //           children: [
                            //             Expanded(
                            //               child: Text(
                            //                 '${e.disease}',
                            //                 style: TextStyle(fontSize: 16),
                            //               ),
                            //             ),
                            //           ],
                            //         ),
                            //       );
                            //     }).toList(),
                            //   );
                            // }).toList(),
                            ),
                        SizedBox(
                          height: 12,
                        ),
                        ExpansionTile(
                          initiallyExpanded: true,
                          trailing: widget.isPatient
                              ? Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                )
                              : InkWell(
                                  child: CircleAvatar(
                                      child:
                                          Icon(Icons.add, color: Colors.white),
                                      backgroundColor: Colors.blue,
                                      radius: 18),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => TestScreen(
                                                patientUid:
                                                    widget.pm!.patientUid)));
                                  }),
                          title: Text(
                            "Treatment Required",
                            style: TextStyle(fontSize: 20),
                          ),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          expandedAlignment: Alignment.centerLeft,
                          children: pendingPlanList.map((e) {
                            return PendingPlanCard(
                              plan: e.plan,
                              note: e.note,
                              toothList: e.toothList,
                              pm: widget.pm!,
                              pTime: e.time,
                            );
                          }).toList(),
                          // children: finalTPlan.map((e){
                          //
                          //   return ExpansionTile(
                          //     title: Text(e[e.keys.first]![0].time),
                          //     children: e[e.keys.first]!.map((e){
                          //
                          //       return PendingPlanCard(
                          //         plan: e.plan,
                          //         toothList: e.toothList,
                          //         pm: widget.pm!,
                          //         hideButton: widget.isPatient,
                          //         pTime: e.time,
                          //       );
                          //     }).toList(),
                          //   );
                          // }).toList(),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        ExpansionTile(
                          initiallyExpanded: true,
                          trailing: widget.isPatient
                              ? Container(
                                  child: Icon(Icons.keyboard_arrow_down),
                                )
                              : InkWell(
                                  child: CircleAvatar(
                                      child:
                                          Icon(Icons.add, color: Colors.white),
                                      backgroundColor: Colors.blue,
                                      radius: 18),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CompletedPlanScreen(
                                                  patientUid:
                                                      widget.pm!.patientUid,
                                                  pm: widget.pm!,
                                                )));
                                  }),
                          title: Text("Completed Treatment Plans",
                              style: TextStyle(fontSize: 20)),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          expandedAlignment: Alignment.centerLeft,
                          children: donePlanList.map((e) {
                            return DonePlanCard(
                                time: e.time,
                                plan: e.plan,
                                toothList: e.toothList,
                                pm: widget.pm!,
                                note: e.note);
                          }).toList(),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        ExpansionTile(
                          initiallyExpanded: true,
                          title: Text("Prescriptions",
                              style: TextStyle(fontSize: 20)),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          expandedAlignment: Alignment.centerLeft,
                          children: preList.map((e) {
                            return PreCard(
                              onEdit: () {
                                editPre(e);
                              },
                              onDelete: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title:
                                            Text('Delete this prescription?'),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('No')),
                                          ElevatedButton(
                                              onPressed: () async {
                                                await deletePre(e);
                                                Navigator.pop(context);
                                              },
                                              child: Text('Yes')),
                                        ],
                                      );
                                    });
                              },
                              pm: e,
                            );
                          }).toList(),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        ExpansionTile(
                            initiallyExpanded: true,
                            trailing: InkWell(
                              child: CircleAvatar(
                                child: isImgUploading
                                    ? Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                    : Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                radius: 15,
                                backgroundColor: kPrimaryColor,
                              ),
                              onTap: () {
                                if (!isImgUploading) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return FileInputCard(
                                          size: size,
                                          onUpload: (file, des) async {
                                            uploadImage(file, des);
                                          });
                                    },
                                  );
                                } else {}
                              },
                            ),
                            title:
                                Text("X-rays", style: TextStyle(fontSize: 20)),
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.start,
                            expandedAlignment: Alignment.centerLeft,
                            children: [
                              Container(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: imList.map((e) {
                                      print(e.url);
                                      return Padding(
                                        padding: EdgeInsets.all(4),
                                        child: ImageDesContainer(im: e),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ]),
                        SizedBox(
                          height: 12,
                        ),
                        ExpansionTile(
                            initiallyExpanded: true,
                            trailing: InkWell(
                              child: CircleAvatar(
                                child: isImgUploading2
                                    ? Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                    : Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                radius: 15,
                                backgroundColor: kPrimaryColor,
                              ),
                              onTap: () {
                                if (!isImgUploading2) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return FileInputCard(
                                          size: size,
                                          onUpload: (file, des) async {
                                            uploadBloodReport(file, des);
                                          });
                                    },
                                  );
                                } else {}
                              },
                            ),
                            title: Text("Blood Report",
                                style: TextStyle(fontSize: 20)),
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.start,
                            expandedAlignment: Alignment.centerLeft,
                            children: [
                              Container(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: bloodList.map((e) {
                                      return Padding(
                                        padding: EdgeInsets.all(4),
                                        child: ImageDesContainer(im: e),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ]),
                        SizedBox(
                          height: 12,
                        ),
                        ExpansionTile(
                            initiallyExpanded: true,
                            trailing: InkWell(
                              child: CircleAvatar(
                                child: isImgUploading3
                                    ? Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                    : Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                radius: 15,
                                backgroundColor: kPrimaryColor,
                              ),
                              onTap: () {
                                if (!isImgUploading3) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return FileInputCard(
                                          size: size,
                                          onUpload: (file, des) async {
                                            uploadPhotos(file, des);
                                          });
                                    },
                                  );
                                } else {}
                              },
                            ),
                            title:
                                Text("Photo", style: TextStyle(fontSize: 20)),
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.start,
                            expandedAlignment: Alignment.centerLeft,
                            children: [
                              Container(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: photoList.map((e) {
                                      return Padding(
                                        padding: EdgeInsets.all(4),
                                        child: ImageDesContainer(im: e),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ]),
                        SizedBox(
                          height: 12,
                        ),
                        !widget.isPatient
                            ? CustomButton(
                                text: 'ADD PLAN & PRESCRIPTION',
                                backgroundColor: kPrimaryColor,
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TestScreen(
                                                patientUid: widget.uid,
                                                status: 'normal',
                                              )));
                                })
                            : Container(),
                        SizedBox(
                          height: 12,
                        ),
                        !widget.isPatient
                            ? CustomButton(
                                text: 'Edit Details',
                                backgroundColor: kPrimaryColor,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddPatientScreen(
                                        patientId: widget.uid,
                                      ),
                                    ),
                                  );
                                })
                            : Container(),
                      ]),
                )
              : Center(
                  child: CircularProgressIndicator(
                    color: kPrimaryColor,
                  ),
                ),
        ),
      ),
    );
  }
}

class RowText extends StatelessWidget {
  RowText(
      {required this.title,
      required this.content,
      this.func,
      this.fontColor = Colors.black});
  String title, content;
  Function? func;
  Color fontColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: InkWell(
        child: Text(
          content,
          style: TextStyle(fontSize: 16, color: fontColor),
        ),
        onTap: () {
          try {
            func!();
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}

/*
Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${e}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    !widget.isPatient ? InkWell(child: Icon(Icons.delete, color: Colors.redAccent,), onTap: (){
                                      deleteMed(dates.time, e);
                                    },) : Container(),
                                  ],
                                ),
                              );
 */
