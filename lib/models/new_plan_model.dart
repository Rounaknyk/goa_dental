import 'package:flutter/material.dart';

class NewPlanModel{

  String plan;
  List<dynamic> toothList = [];
  String time;

  NewPlanModel({required this.plan, required this.toothList, required this.time});
}