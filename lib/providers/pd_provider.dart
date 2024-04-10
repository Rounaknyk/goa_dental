import 'dart:io';

import 'package:flutter/material.dart';

class PdProvider extends ChangeNotifier{

  String name = '', gender= '', phone = '', dob= '', email = '', address = '', url = '';

  File? file;
  List<String> medList=  [];

  String get _name => name;
  String get _gender => gender;
  String get _email => email;
  String get _dob => dob;
  String get _address => address;
  String get _phone => phone;
  String get _url => url;
  File get _file => file!;
  List<String> get _medList => medList;

  setFirstPage(name, gender, phone, dob, email, address){
    this.name = name;
    this.gender = gender;
    this.email = email;
    this.address = address;
    this.phone = phone;
    this.dob = dob;
    notifyListeners();
  }
  setProfileUrl(url){
    this.url= url;
    notifyListeners();
  }
  setProfileFile(file){
    this.file= file;
    notifyListeners();
  }
  setMedHistory(list){
    this.medList = list;
    notifyListeners();
  }

}