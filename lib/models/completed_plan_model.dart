import 'package:flutter/material.dart';

class CompletedPlanModel{

  String plan, time, note, docUid, docName, patientUid, patientName, week;
  List<dynamic> toothList = [];
  bool isChecked;

  CompletedPlanModel({required this.plan, required this.toothList, this.isChecked = false, required this.time, this.note = '', required this.patientUid, required this.patientName, required this.docName, required this.docUid, required this.week});
}