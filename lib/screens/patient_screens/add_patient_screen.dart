import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/classes/alert.dart';
import 'package:goa_dental_clinic/classes/erase_patient_data.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/custom_widgets/patient_dropdown.dart';
import 'package:goa_dental_clinic/custom_widgets/patient_text_field.dart';
import 'package:goa_dental_clinic/custom_widgets/text_textfield_dropdown.dart';
import 'package:goa_dental_clinic/custom_widgets/treatment_text_field.dart';
import 'package:goa_dental_clinic/models/patient_model.dart';
import 'package:goa_dental_clinic/providers/add_pre_provider.dart';
import 'package:goa_dental_clinic/providers/pd_provider.dart';
import 'package:goa_dental_clinic/providers/user_provider.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/nav_screen.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/test_screen.dart';
import 'package:goa_dental_clinic/screens/patient_screens/add_patient_screen4.dart';
import 'package:provider/provider.dart';

import '../../classes/date_time_parser.dart';
import '../../models/user_model.dart';
import '../../providers/add_patient_provider.dart';
import '../../providers/add_plan_provider.dart';
import 'add_patient_screen1.dart';
import 'add_patient_screen2.dart';
import 'add_patient_screen3.dart';

class AddPatientScreen extends StatefulWidget {
  AddPatientScreen({this.pm, this.status = 'normal', this.patientId = ''});
  PatientModel? pm;
  String patientId;
  String status;

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  PageController pageController = PageController();
  bool isNextVisible = true;
  bool isPrevVisible = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  String uid = '', actualUrl = '';
  UploadTask? uploadTask;
  var data1;
  List<String> data3 = [];
  File? fi;
  bool isLoading = false, dataUploading = false;
  String accessToken = '';


  createUser() async {
    setState(() {
      isLoading = true;
      dataUploading = true;
    });
    if(uid.isEmpty || uid == '') {
      try {
        accessToken = '${data1['patientName']}${data1['phoneNumber']}';
        FirebaseAuth auth = await FirebaseAuth.instance;
        await auth.createUserWithEmailAndPassword(email: '${accessToken}@gmail.com', password: '${accessToken}')
            .then((credentials) {
          print(credentials.user!.uid);
        });
        PatientModel pm = Provider.of<AddPatientProvider>(context, listen: false).pm;
        pm.patientUid = auth.currentUser!.uid;
        print("UIDDD : ${pm.patientUid}");
        Provider.of<AddPatientProvider>(context, listen: false).setPatient(pm);
        setState(() {
          uid = auth.currentUser!.uid;
        });
        await auth.signOut();
        await restoreCurrentUser();
        print('UID: $uid');
      } catch (e) {
        print('asalj $e');
        if(e.toString().contains('email address is already')){
          PatientModel pm = Provider.of<AddPatientProvider>(context, listen: false).pm;
          print("UIDDD2222 : ${pm.patientUid}");

          Navigator.push(context,
              MaterialPageRoute(builder: (context) => TestScreen(patientUid: pm.patientUid)));
        }
        setState(() {
          isLoading = false;
          dataUploading = false;
        });
      }
    }
    else
    await uploadData();
  }

  restoreCurrentUser() async {
    UserModel u = Provider.of<UserProvider>(context, listen: false).um;
    // print(u.email);
    FirebaseAuth auth = FirebaseAuth.instance;
    print('1');
    await auth.signInWithEmailAndPassword(email: u.email, password: u.pass);
    print('2 ${auth.currentUser!.email}');
    await uploadData();
  }

  uploadData() async {
    print('reached');
    setState(() {
      dataUploading = true;
    });

      try {
        try {
          setState(() {
            isLoading = true;
          });

          if (data1 != null) {
            print('cool');
            try {
              await firestore.collection('Patients').doc(uid).set({
                'patientName': data1['patientName'],
                'gender': data1['gender'],
                'dob': data1['dob'],
                'patientUid': uid,
                'phoneNumber': data1['phoneNumber'],
                'email': data1['email'],
                'streetAddress': data1['streetAddress'],
                'token': '',
              }, SetOptions(merge: true));
            } catch (e) {
              print('ljlj $e');
            }
          }

          String dateMonth = "${DateTimeParser(DateTime.now().toString()).date} ${DateTimeParser(DateTime.now().toString()).getMonth()} ${DateTimeParser(DateTime.now().toString()).getYear()}";

          List<String> disPresentInDb = [];


          // print(uid);


          final data = await firestore.collection('Patients').doc(uid)
              .collection('Medical History').get();

          for(var dis in data.docs){
            disPresentInDb.add(dis['disease']);
          }

          if (data3.isNotEmpty || data3 != null) {
            for (var disease in data3) {
              bool isPresent = false;

              for(var dis in disPresentInDb){
                if(disease == dis){
                  isPresent = true;
                  break;
                }
              }
              if(!isPresent){
                await firestore.collection('Patients').doc(uid)
                    .collection('Medical History').doc(disease).set({
                  'disease': disease,
                  'time': dateMonth.toString(),
                });
              }
              // await firestore
              //     .collection('Patients')
              //     .doc(uid)
              //     .collection('Medical History')
              //     .doc(dateMonth).collection('diseases').doc(disease.trim()).set({'disease': disease.trim()});
            }
          }

          String url = '';
          if (fi != null && actualUrl == '') {
            try {
              url = await uploadImage();
              await firestore.collection('Patients').doc(uid).set({
                'profileUrl': url,
              }, SetOptions(merge: true));
            } catch (e) {
              print(e);
              Alert(context, e);
            }
          } else if (fi == null && actualUrl == '') {
            await firestore.collection('Patients').doc(uid).set({
              'profileUrl': '',
            }, SetOptions(merge: true));
          }
          await firestore.collection('Users').doc(uid).set({
            'setup': 2,
          }, SetOptions(merge: true));

          if (widget.status != 'normal') {
            await firestore.collection('Users').doc(uid).set({
              'name': data1['patientName'].toString().trim(),
              'phoneNumber': data1['phoneNumber'].toString().trim(),
              'email': data1['email'].toString().trim(),
              'role': 'patient',
              'uid': uid,
              'token': '',
              'accessToken' : accessToken,
              'setup': 2,
            });
          }

          setState(() {
            isLoading = false;
            dataUploading = false;
          });
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => TestScreen(patientUid: uid)));
        } catch (e) {
          Alert(context, "ada $e");
        }

      }catch(e){
        Alert(context, e);
        setState(() {
          isLoading = false;
          dataUploading = false;
        });
      }
  }

  Future<String> uploadImage() async {
    try {
      final data = await storage
          .ref()
          .child('profiles')
          .child(DateTime.now().millisecondsSinceEpoch.toString());

      uploadTask = data.putFile(fi!);

      final snapshot = await uploadTask?.whenComplete(() => () {});
      return (await snapshot?.ref.getDownloadURL())!;
    } catch (e) {
      return '';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.status == 'normal') {
      uid = auth.currentUser!.uid;
    }
    if(widget.patientId.isNotEmpty){
      uid = widget.patientId;
    }

    else {

      // uid = '';
    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        child: Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: Colors.black,
                        ),
                        onTap: () {
                          showDialog(context: context, builder: (context) {

                            return AlertDialog(
                              title: Text('Go back ?',),
                              content: Text('Are you sure ?'),
                              actions: [
                                ElevatedButton(onPressed: (){
                                  Navigator.pop(context);
                                }, child: Text('NO'),),
                                ElevatedButton(onPressed: (){
                                  if(widget.status == 'normal'){
                                    ErasePatientData(context: context).erase();
                                    print('erased!');
                                  }
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                }, child: Text('YES'),),
                              ],
                            );
                          });
                        },
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Text(
                        'Add Details',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    'Fill this form to get started !',
                    style: TextStyle(color: kGrey, fontSize: 24),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Expanded(
                    child: PageView(
                      controller: pageController,
                      scrollDirection: Axis.horizontal,
                      onPageChanged: (pageIndex) {},
                      children: [
                        AddPatientScreen1(
                          updateData: (Map<String, String> data) {
                            try{
                              data1 = data;
                              print("asdad $data1");
                              Provider.of<AddPatientProvider>(context,
                                      listen: false)
                                  .setPatient(PatientModel(
                                      patientUid: data1['patientUid'] ?? "",
                                      patientName: data1['patientName'] ?? "",
                                      email: data1['email'] ?? "",
                                      dob: data1['dob'] ?? "",
                                      gender: data1['gender'],
                                      phoneNumber1: data1['phoneNumber'] ?? "",
                                      streetAddress:
                                          data1['streetAddress'] ?? "",
                                      profileUrl: data1['profileUrl'] ?? ""));
                              setState(() {

                              });
                            }catch(e){
                              print('patientttt : $e');
                            }
                          },
                          status: widget.status,
                          patientId: widget.patientId,
                        ),
                        AddPatientScreen3(
                          updateData: (file, url) {
                            // if(url == ''){
                            // if(file != null)
                            //   Provider.of<PdProvider>(context).setProfileFile(file);
                            // // }
                            // // else{
                            // if(url != null)
                            //   Provider.of<PdProvider>(context).setProfileUrl(url ?? '');
                            // }
                            setState(() {
                              fi = file;
                              actualUrl = url;
                            });
                          },
                          patientId: widget.patientId,
                        ),
                        AddPatientScreen4(updateData: (List<String> data) {
                          Provider.of<PdProvider>(context, listen: false).setMedHistory(data);
                          setState(() {
                            data3 = data;
                          });
                        }, patientId: widget.patientId,),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: isPrevVisible,
                    child: Container(
                        width: 100,
                        child: CustomButton(
                            text: 'PREVIOUS',
                            backgroundColor: kPrimaryColor,
                            onPressed: () {
                              pageController.previousPage(
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.ease);
                              int? pageIndex = pageController.page?.toInt();
                              switch (pageIndex) {
                                case 1:
                                  setState(() {
                                    isPrevVisible = true;
                                    isNextVisible = true;
                                  });
                                  break;
                                case 2:
                                  setState(() {
                                    isPrevVisible = true;
                                    isNextVisible = true;
                                  });
                                  break;
                                case 3:
                                  setState(() {
                                    isPrevVisible = true;
                                    isNextVisible = true;
                                  });
                                  break;
                                case 0:
                                  setState(() {
                                    isPrevVisible = false;
                                    isNextVisible = true;
                                  });
                                  break;
                              }
                            })),
                  ),
                  Visibility(
                    visible: isNextVisible,
                    child: Container(
                      width: 100,
                      child: CustomButton(
                        text: 'NEXT',
                        isLoading: isLoading,
                        loadingWidget: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: kPrimaryColor,
                        onPressed: () {
                          print('FINAL $data1');
                          if (!(data1['patientName'] == "" ||
                              data1['gender'] == "" ||
                              data1['phone1'] == "phoneNumber")) {
                            pageController.nextPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.ease);
                            int? pageIndex = pageController.page?.toInt();

                            if (pageIndex == 2) {
                              if(!dataUploading)
                              createUser();
                            }
                            switch (pageIndex) {
                              case 0:
                                setState(() {
                                  isPrevVisible = true;
                                  isNextVisible = true;
                                });
                                break;
                              case 1:
                                setState(() {
                                  isPrevVisible = true;
                                  isNextVisible = true;
                                });
                                break;
                              case 2:
                                setState(() {
                                  isPrevVisible = false;
                                  isNextVisible = true;
                                });
                                break;
                              case 3:
                                setState(() {
                                  isPrevVisible = false;
                                  isNextVisible = true;
                                });
                                break;
                            }
                          }else{
                            print(data1);
                            Alert(context, "Name, gender, Phone No. are mandatory fields!");
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
