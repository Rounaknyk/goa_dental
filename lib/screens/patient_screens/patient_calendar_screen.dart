import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/classes/get_patient_details.dart';
import 'package:goa_dental_clinic/classes/pref.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/models/app_model.dart';
import 'package:goa_dental_clinic/models/appointment_msg_model.dart';
import 'package:goa_dental_clinic/models/patient_model.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/appointment_screen.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../classes/date_time_parser.dart';
import '../../classes/get_first_name.dart';
import '../../classes/get_initials.dart';
import '../../classes/meeting_data_source.dart';
import '../../models/plan_model.dart';

class PatientCalendarScreen extends StatefulWidget {
  const PatientCalendarScreen({Key? key}) : super(key: key);

  @override
  State<PatientCalendarScreen> createState() => _PatientCalendarScreenState();
}

class _PatientCalendarScreenState extends State<PatientCalendarScreen> {
  CalendarController controller = CalendarController();
  late String formattedTime, formmatedDate;
  List<DropDownValueModel> doctorList = [];
  List<DropDownValueModel> patientList = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  late String uid;
  late String patientName, doctorName, patientUid, doctorUid, startTimeInMil, endTimeInMil;
  PatientModel? pm;
  String? appId;
  List<Appointment> meetings = [];
  bool isLoading = true;
  TextEditingController planController = TextEditingController();
  Duration appDuration = Duration(hours: 1);
  List<PlanModel> planList = [];
  PlanModel planModel = PlanModel(plan: 'checkup', toothList: [], time: DateTimeParser(DateTime.now().toString()).date + DateTimeParser(DateTime.now().toString()).getMonth()+DateTimeParser(DateTime.now().toString()).getYear());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = auth.currentUser!.uid;
    patientUid = uid;
    getDoctors();
    getPatients();
    getAppointments();
    getPlans();
    // cell();
  }

  getPlans() async {

    final data = await firestore.collection('Patients').doc(uid).collection('Plans').get();

    setState(() {

      planList.clear();
      String time = DateTimeParser(DateTime.now().toString()).date + DateTimeParser(DateTime.now().toString()).getMonth()+DateTimeParser(DateTime.now().toString()).getYear();

      planList.add(PlanModel(plan: 'checkup', toothList: [], time: time));
      for(var plan in data.docs){
        planList.add(PlanModel(plan: plan['plan'], toothList: plan['toothList'], time: plan['time']));
      }
    });
  }

  getAppointments() async {

    setState(() {
      isLoading = true;
    });

    final datas = await firestore.collection('Patients').doc(uid).collection('Appointments').get();

    for(var data in datas.docs){
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(int.parse(data['startTimeInMil']));
      DateTime dt2 = DateTime.fromMillisecondsSinceEpoch(int.parse(data['endTimeInMil']));
      if(dt.hour == 0){
        meetings.add(Appointment(isAllDay: true, startTime: dt, endTime: dt2, subject: GetFirstName(data['patientName']).get(), color:  kPrimaryColor),);
      }
      else{
        meetings.add(Appointment(startTime: dt, endTime: dt2, subject: GetFirstName(data['patientName']).get(), color:  kPrimaryColor));
      }
    }

    try {
      print(meetings);
    }
    catch(e){
      print(e);
    }
    setState(() {
      isLoading = false;
    });
    return meetings;
  }

  requestAppointment(DateTimeParser parser) async {
    var date = DateTime
        .fromMillisecondsSinceEpoch(
        int.parse(
            startTimeInMil))
        .add(appDuration);
    print(date.minute);
    endTimeInMil = date.millisecondsSinceEpoch.toString();
    try {
      print('processing request');

      String startTime = parser.getFormattedTime();
      String endTime = DateTimeParser(DateTime.fromMillisecondsSinceEpoch(int.parse(endTimeInMil)).toString()).getFormattedTime();
      AppointmentMessageModel amm =
      AppointmentMessageModel(date: parser.date,
          startTime: startTime,
          endTime: endTime,
          patientName: patientName,
          patientUid: patientUid,
          appId: appId.toString(),
          week: parser.getWeek(),
          plan: planModel.plan,
          toothList: planModel.toothList,
          msgId: DateTime
              .now()
              .millisecondsSinceEpoch
              .toString(),
          message: 'Request for an appointment. $startTime - $endTime (Dr.$doctorName)',
          startTimeInMil: startTimeInMil,
          endTimeInMil: endTimeInMil, month: parser.getMonth());


      print('DATE: ${DateTimeParser(DateTime.fromMillisecondsSinceEpoch(int.parse(endTimeInMil)).toString()).getFormattedTime()}');

      await firestore.collection('Doctors').doc(doctorUid).collection(
          'Messages').doc(amm.msgId).set(
          {
            'date': amm.date,
            'startTime': amm.startTime,
            'endTime': amm.endTime,
            'msgId': amm.msgId,
            'appId': amm.appId,
            'week': amm.week,
            'patientName': amm.patientName,
            'patientUid': uid,
            'message': amm.message,
            'startTimeInMil': amm.startTimeInMil,
            'endTimeInMil': amm.endTimeInMil,
            'month': amm.month,
            'plan' : amm.plan,
            'toothList' : amm.toothList,
          }
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Appointment request sent to Dr. ${doctorName}.')));
      // AppModel am = AppModel(
      //   patientName: patientName,
      //   doctorName: doctorName,
      //   date: parser.date,
      //   week: parser.getWeek(),
      //   time: parser.getFormattedTime(),
      //   doctorUid: uid,
      //   patientUid: patientUid,
      //   pm: await getPatientDetails(),
      //   appId: appId!,
      // );
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) =>
      //             AppointmentScreen(am: am)));
    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Enter valid values. $e'), backgroundColor: Colors.red,));
    }
  }

  getDoctors() async {
    final doctors = await firestore.collection('Doctors').get();
    doctorList.clear();
    for (var doctor in doctors.docs) {
      try {
        doctorList
            .add(
            DropDownValueModel(name: doctor['name'], value: doctor['uid']));
      }
      catch(e){
        continue;
      }
      }
    setState(() {});
    // final doctors  = await firestore.collection('Doctors').get();
    // doctorList.clear();
    // for(var doctor in doctors.docs){
    //   print(doctor['name']);
    //   doctorList.add(DropDownValueModel(name: doctor['name'], value: doctor['uid'], toolTipMsg:
    //   "DropDownButton is a widget that we can use to select one unique value from a set of values"),);
    // }
  }

  getPatients() async {
    final data = await firestore.collection('Patients').doc(uid).get();

    String name = data['patientName'];
    patientName = name;
    // final patients = await firestore.collection('Patients').get();
    // patientList.clear();
    // for (var patient in patients.docs) {
    //   patientList.add(DropDownValueModel(
    //       name: patient['patientName'], value: patient['patientUid']));
    // }
  }

  Future getPatientDetails() async {
    print('${patientUid}s');
    final datas = await firestore.collection('Patients').get();
    PatientModel? pm;
    setState(() {
      for (var data in datas.docs) {
        if (patientName == data['patientName'])
          pm = GetPatientDetails().get(data);
      }
    });
    return pm;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: (isLoading) ? Center(child: CircularProgressIndicator(color: kPrimaryColor,),) : SfCalendar(
          todayHighlightColor: kPrimaryColor,
          view: CalendarView.week,
          dataSource: MeetingDataSource(meetings),
          // appointmentBuilder: (context, details){
          //
          //   print(details.appointments.first);
          //   for(Appointment detail in details.appointments){
          //     for(Appointment meeting in meetings){
          //       if(meeting.startTime == detail.startTime && meeting.endTime == detail.endTime){
          //         MeetingDataSource([meeting]);
          //       }
          //     }
          //   }
          //
          //     return Container(
          //       color: Colors.blue, // Set the background color for the cell
          //       child: Center(
          //         child: Text('Rounak Naik', style: TextStyle(color: Colors.white, fontSize: 12),),
          //       ),
          //     );
          // },
          onTap: (details) {
            var parser = DateTimeParser(details.date.toString());
            appId = DateTime.parse(details.date.toString())
                .millisecondsSinceEpoch
                .toString();
            print(DateTime.parse(details.date.toString()).weekday);
            setState(() {
              formattedTime = parser.getFormattedTime();
              formmatedDate = parser.getFormattedDate();
              startTimeInMil = details.date!.millisecondsSinceEpoch.toString();
              endTimeInMil = details.date!.add(Duration(hours: 1)).millisecondsSinceEpoch.toString();
            });
            showDialog(
                context: context,
                builder: (context) {
                  return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
                    return Material(
                      color: Colors.transparent,
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16)),
                          height: size.height * 0.5,
                          width: size.width * 0.8,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Appointment at',
                                        style: TextStyle(
                                            fontSize: 22,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold)),
                                    InkWell(child: Icon(Icons.highlight_remove_outlined, color: Colors.red,), onTap: (){
                                      Navigator.pop(context);
                                    },)
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
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                DropDownTextField(
                                  dropdownColor: Colors.white,

                                  dropDownList: [
                                    DropDownValueModel(
                                        name: '1 hour', value: Duration(hours: 1)),
                                    DropDownValueModel(
                                        name: '1 hour 30 min', value: Duration(hours: 1, minutes: 30)),
                                    DropDownValueModel(
                                      name: '2 hour', value: Duration(hours: 3),),
                                    DropDownValueModel(
                                        name: '2 hour 30 min', value: Duration(hours: 2, minutes: 30)),
                                    DropDownValueModel(
                                        name: '3 hour', value: Duration(hours: 3)),
                                    DropDownValueModel(
                                        name: '3 hour 30 min', value: Duration(hours: 3, minutes: 30)),
                                  ],
                                  textFieldDecoration: InputDecoration(hintText: '${appDuration.inHours} hour', border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black),
                                  ),),
                                  onChanged: (value){
                                    DropDownValueModel val = value;
                                    setState((){
                                      appDuration = val.value;
                                    });
                                  },
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  'Doctor: ',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                DropDownTextField(
                                  dropdownColor: Colors.white,

                                  dropDownList: doctorList,
                                  enableSearch: true,
                                  searchDecoration: InputDecoration(hintText: 'Search'),
                                  onChanged: (value) {
                                    setState(() {
                                      DropDownValueModel val = value;
                                      doctorName = val.name;
                                      doctorUid = val.value;
                                    });
                                  },
                                  textFieldDecoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black),
                                      ),
                                      hintText: 'Add Doctor'),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  'Plan: ',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                DropDownTextField(
                                  dropdownColor: Colors.white,

                                  dropDownList: planList.map((e){
                                    return DropDownValueModel(name: e.plan, value: e);
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      DropDownValueModel val = value;
                                      planModel = val.value;
                                    });
                                  },
                                  textFieldDecoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black),
                                      ),
                                      hintText: 'Add Plan'),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                CustomButton(
                                    text: 'Request Appointment',
                                    backgroundColor: kPrimaryColor,
                                    onPressed: () async {
                                      await requestAppointment(parser);
                                      Navigator.pop(context);
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
          },
          controller: controller,
        ),
      ),
    );
  }
}
