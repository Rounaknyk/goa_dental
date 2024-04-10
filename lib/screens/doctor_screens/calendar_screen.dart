import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/classes/alert.dart';
import 'package:goa_dental_clinic/classes/get_patient_details.dart';
import 'package:goa_dental_clinic/classes/pref.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/custom_widgets/fixed_sized_tooth.dart';
import 'package:goa_dental_clinic/models/app_model.dart';
import 'package:goa_dental_clinic/models/patient_model.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/appointment_screen.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/nav_screen.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../classes/date_time_parser.dart';
import '../../classes/meeting_data_source.dart';
import '../../custom_widgets/message_card.dart';
import '../../models/appointment_msg_model.dart';
import '../../models/doctor_model.dart';
import '../../models/plan_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarController controller = CalendarController();
  late String formattedTime, formmatedDate;
  List<DropDownValueModel> doctorList = [];
  List<DropDownValueModel> patientList = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  late String uid;
  late String patientName, doctorName, patientUid;
  PatientModel? pm;
  String? appId;
  late String startTimeInMil, endTimeInMil;
  var dataSource;
  bool isLoading = true, toothLoading = true;
  List<Appointment> meetings = [];
  var _credentials, _clientID;
  static const _scopes = const [cal.CalendarApi.calendarScope];
  List<dynamic> toothList = [];
  TextEditingController planControler = TextEditingController();
  late DoctorModel dm;
  List<DropDownValueModel> planList = [];
  PlanModel planModel = PlanModel(plan: '', toothList: [], time: '');
  String plan = '', doctorUid = '';
  Duration appDuration = Duration(hours: 1);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    patientName = '';
    uid = auth.currentUser!.uid;
    getDoctors();
    getPatients();
  }

  List reqAppList = [];

  getAllMessages() async {
    setState(() {
      isLoading = true;
    });
    final allDocs = await firestore.collection('Doctors').get();

    reqAppList.clear();
    for(var doc in allDocs.docs){
      final msgs = await firestore.collection('Doctors').doc(doc['uid']).collection('Messages').get();
      for(var msg in msgs.docs){
        String msgId = msg.reference.id;

        String docUid = doc['uid'];

        setState(() {
          reqAppList.add(AppointmentMessageModel(
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
          );
          DateTime dt = DateTime.fromMillisecondsSinceEpoch(
              int.parse(msg['startTimeInMil']));
          DateTime dt2 =
          DateTime.fromMillisecondsSinceEpoch(int.parse(msg['endTimeInMil']));

          meetings.add(
            Appointment(
                isAllDay: false,
                startTime: dt,
                endTime: dt2,
                subject: msg['patientName'],
                color: Colors.green, id: 'request', recurrenceId:
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

  onReqAccept(AppointmentMessageModel amm) async {
    try {
      final datas = await firestore.collection('Patients').get();
      PatientModel? pm;
      setState(() {
        for (var data in datas.docs) {
          print(data['patientName'] + data['patientName']);
          if (amm.patientUid == data['patientUid']) {
            pm = GetPatientDetails().get(data);
            break;
          }
        }
      });

      print(pm!.patientName);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AppointmentScreen(
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
                        month: amm.month,
                        plan: amm.plan,
                        toothList: amm.toothList),
                  )));

      if (amm.doctorUid == '')
        removeMsg(amm.msgId, uid);
      else
        removeMsg(amm.msgId, amm.doctorUid);

      // Navigator.push(context,
      //     MaterialPageRoute(builder: (context) => NavScreen(screenNo: 2,)));
    }catch(e){
      print('msg error: $e');
    }
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
    
  }

  sendNotificationToPatient(AppointmentMessageModel am) async {
    String msgId = DateTime.now().millisecondsSinceEpoch.toString();
    firestore
        .collection('Patients')
        .doc(am.patientUid)
        .collection('Messages')
        .doc(msgId)
        .set({
      'msg':
      'Rejected appointment request scheduled on ${am.date}${am.month}(${am.week}) at ${am.startTime}.',
      'msgId': msgId,
      'docUid': uid,
      'docName': doctorName,
      'date': am.date,
      'week': am.week,
      'time': am.startTime,
      'plan': am.plan,
      'toothList': am.toothList,
    });
  }


  showAcceptDialogBox(patientName,AppointmentMessageModel appModel) {
    showDialog(context: context, builder: (context) {
      return Material(
        color: Colors.transparent,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AlertDialog(
              title: Text('Accept it ?'),
              content: Text('Do you accept ${patientName}\'s appointment request ?'),
              actions: [
                ElevatedButton(onPressed: () {
                  Navigator.pop(context);
                  removeMsg(appModel.msgId, uid);
                  sendNotificationToPatient(appModel);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => NavScreen(screenNo: 2,)));
                }, child: Text('Reject'),),
                ElevatedButton(onPressed: () {
                  onReqAccept(appModel);
                  Navigator.pop(context);
                }, child: Text('Accept'),),
              ],
            ),
          ),
        ),
      );
    });
  }

  getAppointments(docUid) async {
    // setState(() {
    //   isLoading = true;
    // });

    final datas = await firestore
        .collection('Doctors')
        .doc(docUid)
        .collection('Appointments')
        .get();
    meetings.clear();

    for (var data in datas.docs) {
      print('da');
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(
          int.parse(data['startTimeInMil']));
      DateTime dt2 =
          DateTime.fromMillisecondsSinceEpoch(int.parse(data['endTimeInMil']));
      if (dt.hour == 0) {
        meetings.add(
          Appointment(
              isAllDay: true,
              startTime: dt,
              endTime: dt2,
              subject: data['patientName'],
              color: kPrimaryColor),
        );
      } else {
        meetings.add(
          Appointment(
            startTime: dt,
            endTime: dt2,
            subject: data['patientName'],
            color: kPrimaryColor,
          ),
        );
      }
    }

    try {
      print(meetings);
    } catch (e) {
      print(e);
    }
    setState(() {
      isLoading = false;
    });
    return meetings;
  }

  getDoctors() async {
    final data = await firestore.collection('Doctors').doc(uid).get();
    String name = data['name'];
    setState(() {
      doctorName = name;
      doctorUid = data['uid'];
    });

    //get all doctors
    final docs = await firestore.collection('Doctors').get();
    // List<DoctorModel> docmList = [];
    doctorList.clear();
    setState(() {
      for (var doc in docs.docs) {
        // dmList.add(DoctorModel(name: doc['name'], uid: doc['uid']));
        doctorList.add(DropDownValueModel(
            name: doc['name'],
            value: DoctorModel(name: doc['name'], uid: doc['uid'])));
      }
    });

    await getAppointments(doctorUid);
    await getAllMessages();
  }

  getPatients() async {
    final patients = await firestore.collection('Patients').get();
    patientList.clear();
    for (var patient in patients.docs) {
      // try {
      patientList.add(DropDownValueModel(
          name: patient['patientName'], value: patient['patientUid']));
      // }
      // catch(e){
      //   continue;
      // }
    }

    print("done ${patientList.length}");

    setState(() {});
  }

  Future getPatientDetails() async {
    print('${patientUid}s');
    final datas = await firestore.collection('Patients').get();
    PatientModel? pm;
    setState(() {
      for (var data in datas.docs) {
        try {
          if (patientName == data['patientName'])
            pm = GetPatientDetails().get(data);
        } catch (e) {
          print('jhihuhi');
          continue;
        }
      }
    });
    return pm;
  }

  getPlans() async {
    final data = await firestore
        .collection('Patients')
        .doc(patientUid)
        .collection('Plans')
        .get();

    planList.clear();
    setState(() {
      for (var plan in data.docs) {
        planList.add(DropDownValueModel(
            name: plan['plan'],
            value:
                PlanModel(plan: plan['plan'], toothList: plan['toothList'], time: plan['time'])));
      }
    });


    // if (planList.isEmpty) {
      String time = DateTimeParser(DateTime.now().toString()).date + DateTimeParser(DateTime.now().toString()).getMonth()+DateTimeParser(DateTime.now().toString()).getYear();

      planList.add(DropDownValueModel(
          name: 'Checkup', value: PlanModel(plan: 'checkup', toothList: [], time: time)));
    // }
  }


  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    planControler.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: !isLoading
            ? Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.0),
                    height: size.height * 0.05,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Selected doctor: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Container(
                          height: size.height * 0.05,
                          width: size.width * 0.5,
                          child: DropDownTextField(
                            dropdownColor: Colors.white,
                            dropDownList: doctorList,
                            onChanged: (value) {
                              DropDownValueModel val = value;
                              DoctorModel dm2 = val.value;
                              setState(() {
                                doctorName = val.name;
                                dm = dm2;
                                doctorUid = dm.uid;
                                getAppointments(dm.uid);
                              });
                            },
                            enableSearch: true,
                            textFieldDecoration: InputDecoration(
                              hintText: doctorName,
                              hintStyle: TextStyle(color: Colors.black),
                            ),
                            searchDecoration:
                                InputDecoration(hintText: 'Search'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    height: size.height * 0.05,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select patient: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Container(
                          height: size.height * 0.05,
                          width: size.width * 0.5,
                          child: DropDownTextField(
                            dropdownColor: Colors.white,
                            dropDownList: patientList,
                            enableSearch: true,
                            searchDecoration:
                                InputDecoration(hintText: 'Search'),
                            onChanged: (value) async {
                              setState(() {
                                if (value != '') {
                                  DropDownValueModel val = value;
                                  patientName = val.name;
                                  patientUid = val.value;
                                  print(patientUid);
                                } else {
                                  patientName = '';
                                  patientUid = '';
                                }
                              });
                              await getPlans();
                            },
                            textFieldDecoration:
                                InputDecoration(hintText: 'Add Patient'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SfCalendar(
                      todayHighlightColor: kPrimaryColor,

                      view: CalendarView.week,
                      dataSource: MeetingDataSource(meetings),
                      onTap: (details) {
                        if(details.appointments != null && details.appointments!.first.id != null){
                          if(details.appointments!.first.id == 'request'){
                            showAcceptDialogBox(details.appointments!.first.subject, details.appointments!.first.recurrenceId);
                          }
                        }else {

                          if(patientName.isEmpty){
                            Alert(context, 'Select a patient');
                          }else{
                            var parser =
                            DateTimeParser(details.date.toString());
                            // creatingEvent(details!.date! , DateTime.now());
                            appId = DateTime
                                .parse(details.date.toString())
                                .millisecondsSinceEpoch
                                .toString();
                            setState(() {
                              formattedTime = parser.getFormattedTime();
                              formmatedDate = parser.getFormattedDate();
                              startTimeInMil = details
                                  .date!.millisecondsSinceEpoch
                                  .toString();
                            });
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (BuildContext context,
                                        void Function(void Function())
                                        setState) {
                                      return Material(
                                        color: Colors.transparent,
                                        child: Center(
                                          child: Container(
                                            padding: EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(
                                                  16),),
                                            height: size.height * 0.65,
                                            width: size.width * 0.8,
                                            child: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Text('Appointment at',
                                                          style: TextStyle(
                                                              fontSize: 22,
                                                              color:
                                                              Colors.black,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold)),
                                                      InkWell(
                                                        child: Icon(
                                                          Icons
                                                              .highlight_remove_outlined,
                                                          color: Colors.red,
                                                        ),
                                                        onTap: () {
                                                          planModel =
                                                              PlanModel(
                                                                  plan: '',
                                                                  toothList: [
                                                                  ],
                                                                  time: '');
                                                          plan = '';
                                                          setState;
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text(
                                                    '$formattedTime $formmatedDate',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                        fontWeight:
                                                        FontWeight.w500),
                                                  ),
                                                  SizedBox(
                                                    height: 16,
                                                  ),
                                                  Text(
                                                    'Appointment duration: ',
                                                    style: TextStyle(
                                                        fontSize: 16),
                                                  ), SizedBox(height: 8,),
                                                  DropDownTextField(
                                                    dropdownColor: Colors
                                                        .white,
                                                    dropDownList: [
                                                      DropDownValueModel(
                                                          name: '1 hour',
                                                          value: Duration(
                                                              hours: 1)),
                                                      DropDownValueModel(
                                                          name: '1 hour 30 min',
                                                          value: Duration(
                                                              hours: 1,
                                                              minutes: 30)),
                                                      DropDownValueModel(
                                                        name: '2 hour',
                                                        value: Duration(
                                                            hours: 2),),
                                                      DropDownValueModel(
                                                          name: '2 hour 30 min',
                                                          value: Duration(
                                                              hours: 2,
                                                              minutes: 30)),
                                                      DropDownValueModel(
                                                          name: '3 hour',
                                                          value: Duration(
                                                              hours: 3)),
                                                      DropDownValueModel(
                                                          name: '3 hour 30 min',
                                                          value: Duration(
                                                              hours: 3,
                                                              minutes: 30)),
                                                    ],
                                                    textFieldDecoration: InputDecoration(
                                                      hintText: '${appDuration
                                                          .inHours} hour',
                                                      border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .black),
                                                      ),),
                                                    onChanged: (value) {
                                                      DropDownValueModel val = value;
                                                      setState(() {
                                                        appDuration =
                                                            val.value;
                                                      });
                                                    },
                                                  ),
                                                  SizedBox(
                                                    height: 16,
                                                  ),
                                                  Text(
                                                    'Plans: ',
                                                    style:
                                                    TextStyle(fontSize: 16),
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  DropDownTextField(
                                                    dropdownColor: Colors
                                                        .white,
                                                    dropDownList: planList,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        DropDownValueModel val =
                                                            value;
                                                        PlanModel pm2 =
                                                            val.value;
                                                        plan = val.name;
                                                        planModel = pm2;
                                                        toothLoading = false;
                                                      });
                                                    },
                                                    textFieldDecoration:
                                                    InputDecoration(
                                                        border:
                                                        OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Colors
                                                                  .black),
                                                        ),
                                                        hintText:
                                                        'Add Plan'),
                                                  ),
                                                  SizedBox(
                                                    height: 16,
                                                  ),
                                                  (!toothLoading ||
                                                      planModel.toothList
                                                          .isNotEmpty)
                                                      ? Text(
                                                    'Toothlist: ',
                                                    style: TextStyle(
                                                        fontSize: 16),
                                                  )
                                                      : Container(),
                                                  SizedBox(
                                                    height: (!toothLoading ||
                                                        planModel.toothList
                                                            .isNotEmpty)
                                                        ? 8
                                                        : 0,
                                                  ),
                                                  (!toothLoading ||
                                                      planModel.toothList
                                                          .isNotEmpty)
                                                      ? Wrap(
                                                    children: planModel
                                                        .toothList
                                                        .map((e) {
                                                      return FixedSizeTooth(
                                                        index: e,
                                                        onTap: () {},
                                                        nontapable: true,
                                                        height: 40,
                                                        width: 40,
                                                      );
                                                    }).toList(),
                                                  )
                                                      : Container(),
                                                  SizedBox(
                                                    height: (!toothLoading ||
                                                        planModel.toothList
                                                            .isNotEmpty)
                                                        ? 16
                                                        : 0,
                                                  ),
                                                  CustomButton(
                                                      text: 'Schedule',
                                                      backgroundColor:
                                                      kPrimaryColor,
                                                      onPressed: () async {
                                                        var date = DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                          int.parse(
                                                              startTimeInMil),)
                                                            .add(appDuration);
                                                        print(date.minute);
                                                        endTimeInMil = date
                                                            .millisecondsSinceEpoch
                                                            .toString();
                                                        try {
                                                          AppModel am = AppModel(
                                                            patientName: patientName,
                                                            doctorName: doctorName,
                                                            date: parser.date,
                                                            week: parser
                                                                .getWeek(),
                                                            time: parser
                                                                .getFormattedTime(),
                                                            doctorUid: doctorUid,
                                                            patientUid: patientUid,
                                                            pm: await getPatientDetails(),
                                                            appId: appId!,
                                                            startTimeInMil: startTimeInMil,
                                                            endTimeInMil: endTimeInMil,
                                                            month: parser
                                                                .getMonth(),
                                                            plan: planModel
                                                                .plan,
                                                            toothList: planModel
                                                                .toothList,
                                                          );
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (
                                                                      context) =>
                                                                      AppointmentScreen(
                                                                          am: am)));
                                                        }
                                                        catch (e) {
                                                          Navigator.pop(
                                                              context);
                                                          ScaffoldMessenger
                                                              .of(context)
                                                              .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    'Enter valid values'),
                                                                backgroundColor: Colors
                                                                    .red,));
                                                        }
                                                      }),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                });
                          }
                        }
                      },
                      controller: controller,
                    ),
                  ),
                ],
              )
            : Center(
                child: CircularProgressIndicator(
                  color: kPrimaryColor,
                ),
              ),
      ),
    );
  }
}
