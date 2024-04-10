import 'package:flutter/material.dart';

class PlanModel{

  String plan, time;
  List<dynamic> toothList = [];
  bool isChecked;

  PlanModel({required this.plan, required this.toothList, this.isChecked = false, required this.time});
}