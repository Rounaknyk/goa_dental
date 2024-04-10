import 'package:flutter/material.dart';

class UserModel{
  String name, email, phoneNumber, pass, profileUrl;

  UserModel({required this.name, required this.email, required this.phoneNumber, required this.pass, this.profileUrl = ''});

}