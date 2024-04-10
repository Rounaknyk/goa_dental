import 'package:flutter/material.dart';

import '../constants.dart';

class MedicalCheckBox extends StatefulWidget {
  MedicalCheckBox({required this.title, required this.onChanged, this.isChecked = false});
  String title;
  bool isChecked;
  Function(bool, String) onChanged;

  @override
  State<MedicalCheckBox> createState() => _MedicalCheckBoxState();
}

class _MedicalCheckBoxState extends State<MedicalCheckBox> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Checkbox(value: widget.isChecked, onChanged: (value){
          setState(() {
            widget.onChanged(value!, widget.title);
            widget.isChecked = value;
          });
    }, activeColor: kPrimaryColor,),
    title: Text("${widget.title}"),);
  }
}
