import 'package:flutter/material.dart';

class GetFirstName{

  GetFirstName(this.name);
  String name;

  String get(){

    return name.split(' ')[0];
  }
}