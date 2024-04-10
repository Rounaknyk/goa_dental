import '../models/patient_model.dart';

class  GetPatientDetails{

  get(data){
    PatientModel? pm;
    try {
      pm = PatientModel(patientUid: data['patientUid'],
        patientName: data['patientName'],
        email: data['email'],
        dob: data['dob'],
        gender: data['gender'],
        phoneNumber1: data['phoneNumber'],
        streetAddress: data['streetAddress'],
        profileUrl: data['profileUrl'], token: data['token']);
    }
    catch(e){
      print(e);
    }
    return pm;
    }
}