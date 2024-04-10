import 'package:flutter/material.dart';

import '../constants.dart';

class PatientTextField extends StatefulWidget {
  PatientTextField(
      {required this.title,
        required this.onChanged,
        this.inputType = TextInputType.text,
        this.hintText = '',
        this.enabled = true,
        this.readOnly = false,
        this.inputValue = ''});
  String title, hintText;
  Function onChanged;
  TextInputType inputType;
  bool enabled, readOnly;
  String inputValue;

  void update(){

  }

  @override
  State<PatientTextField> createState() => _PatientTextFieldState();
}

class _PatientTextFieldState extends State<PatientTextField> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.hintText =
    (widget.hintText.isEmpty) ? 'Enter ${widget.title}' : widget.hintText;
    print(widget.inputValue);
    controller.text = widget.inputValue;
  }



  @override
  Widget build(BuildContext context) {
    controller.text = widget.inputValue;
    widget.hintText =
    (widget.hintText.isEmpty) ? 'Enter ${widget.title}' : widget.hintText;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.title,
            style: TextStyle(color: kGrey, fontSize: 16),
          ),
        ),
        SizedBox(
          width: 16,
        ),
        Expanded(
          flex: 2,
          child: TextField(
            onChanged: (value) {
              widget.onChanged(value);
            },
            controller: controller,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            maxLines: null,
            decoration: InputDecoration(
              hintText: '${widget.hintText}',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            keyboardType: widget.inputType,
          ),
        ),
      ],
    );
  }
}
