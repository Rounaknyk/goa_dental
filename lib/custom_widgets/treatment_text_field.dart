import 'package:flutter/material.dart';

import '../constants.dart';

class TreatmentTextField extends StatefulWidget {
  TreatmentTextField(
      {required this.title,
        required this.onChanged,
        this.inputType = TextInputType.text,
        this.hintText = '',
        this.enabled = true,
        this.inputValue = ''});
  String title, hintText;
  Function onChanged;
  TextInputType inputType;
  bool enabled = false;
  String inputValue;

  @override
  State<TreatmentTextField> createState() => _TreatmentTextFieldState();
}

class _TreatmentTextFieldState extends State<TreatmentTextField> {
  late TextEditingController controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TextEditingController(text: widget.inputValue);
    _focusNode = FocusNode();
    widget.hintText =
    (widget.hintText.isEmpty) ? 'Enter ${widget.title}' : widget.hintText;
    print(widget.inputValue);
    controller.text = widget.inputValue;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _focusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    widget.hintText =
    (widget.hintText.isEmpty) ? 'Enter ${widget.title}' : widget.hintText;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.title,
          style: TextStyle(color: kGrey, fontSize: 16),
        ),
        SizedBox(
          width: 16,
        ),
        Expanded(
          flex: 3,
          child: TextField(
            focusNode: _focusNode,
            onChanged: (value) {
              widget.onChanged(value);
            },
            controller: controller,
            enabled: widget.enabled,
            readOnly: !widget.enabled,
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
