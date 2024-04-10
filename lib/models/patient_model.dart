import 'package:flutter/material.dart';

class PatientModel {
  String patientName,
      patientUid,
      gender,
      dob, profileUrl, token;

  //Contact Details
  String phoneNumber1,
      email,
      streetAddress;

  PatientModel({
    required this.patientUid,
    required this.patientName,
    required this.email,
    required this.dob,
    required this.gender,
    required this.phoneNumber1,
    required this.streetAddress,
    required this.profileUrl,
    this.token = '',
  });
}
