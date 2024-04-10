import 'package:goa_dental_clinic/models/patient_model.dart';

class AppModel {
  String date, time, week, patientName, doctorName, patientUid, doctorUid, appId, startTimeInMil, endTimeInMil, month, plan;
  PatientModel? pm;
  List<dynamic> toothList = [];

  AppModel({
    required this.patientName,
    required this.doctorName,
    required this.date,
    required this.week,
    required this.time,
    required this.doctorUid,
    required this.patientUid,
    required this.appId,
    required this.pm,
    required this.startTimeInMil,
    required this.endTimeInMil,
    required this.month,
    required this.plan,
    required this.toothList,
  });
}
