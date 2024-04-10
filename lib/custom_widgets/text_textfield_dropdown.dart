import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class TextDropdown extends StatefulWidget {
  TextDropdown({required this.title, required this.list, required this.onChanged, this.hintText = ''});
  String title, hintText;
  List<DropDownValueModel> list = [];
  Function onChanged;

  @override
  State<TextDropdown> createState() => _TextDropdownState();
}

class _TextDropdownState extends State<TextDropdown> {

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
        Text(
          widget.title,
          style: TextStyle(color: kGrey, fontSize: 16),
        ),
        SizedBox(
          width: 8,
        ),
        Expanded(
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
