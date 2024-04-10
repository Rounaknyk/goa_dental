import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/classes/alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Pref{

  dynamic key, value;
  Pref(this.key, this.value);

  storeString() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString(key, value);
    }
    catch(e){
      print('Preference error: $e');
    }
  }

  Future getString() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    return pref.getString(key);
  }
}