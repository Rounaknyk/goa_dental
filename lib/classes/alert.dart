import 'package:flutter/material.dart';

class Alert{

  Alert(context, text){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$text',), backgroundColor: Colors.red,));
  }
}