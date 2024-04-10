import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class PatientDropDown extends StatefulWidget {
  PatientDropDown({required this.title, required this.list, required this.onChanged, this.hintText = ''});
  String title, hintText;
  List<DropDownValueModel> list = [];
  Function onChanged;

  @override
  State<PatientDropDown> createState() => _PatientDropDownState();
}

class _PatientDropDownState extends State<PatientDropDown> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.hintText =
    (widget.hintText.isEmpty) ? 'Enter ${widget.title}' : widget.hintText;

  }
  @override
  Widget build(BuildContext context) {

    widget.hintText =
    (widget.hintText.isEmpty) ? 'Enter ${widget.title}' : widget.hintText;

    return Row(
      children: [
        Expanded(
          child: Text(
            widget.title,
            style: TextStyle(color: kGrey, fontSize: 16),
          ),
        ),
        SizedBox(
          width: 8,
        ),
        Expanded(
          flex: 2,
          child: DropDownTextField(
            dropdownColor: Colors.white,
            dropDownList: widget.list,
            textFieldDecoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
                hintText: widget.list[0].name),
            onChanged: (value) {
              widget.onChanged(value);
            },
          ),
        ),
      ],
    );
  }
}
