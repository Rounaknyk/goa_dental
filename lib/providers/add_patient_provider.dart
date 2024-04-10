import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/models/patient_model.dart';

class AddPatientProvider extends ChangeNotifier{

  PatientModel _pm = PatientModel(patientUid: '', patientName: '', email: '', dob: '', gender: '', phoneNumber1: '', streetAddress: '', profileUrl: '');
  List<String> _medicalList = [];
  PatientModel get pm => _pm;
  List<String> get mList => _medicalList;

  setPatient(PatientModel pm){
    print(pm.patientName);
    _pm = pm;
    notifyListeners();
  }

  setList(List<String> list){
    _medicalList = list;
    notifyListeners();
  }

  resetPatient(){
    _pm = PatientModel(patientUid: '', patientName: '', email: '', dob: '', gender: '', phoneNumber1: '', streetAddress: '', profileUrl: '');
    _medicalList.clear();
    notifyListeners();
  }

  emptyList(){
    _medicalList.clear();
    notifyListeners();
  }

}