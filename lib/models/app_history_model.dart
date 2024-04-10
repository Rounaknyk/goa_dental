import 'package:goa_dental_clinic/models/patient_model.dart';

class AppHistoryModel {
  String date, time, week, patientName, doctorName, patientUid, doctorUid, appId, startTimeInMil, endTimeInMil, month, status;
  PatientModel? pm;

  AppHistoryModel({
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
    required this.status,
  });
}
