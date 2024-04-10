import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class SuggestionTreatmentTextField extends StatefulWidget {
  SuggestionTreatmentTextField(
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
  State<SuggestionTreatmentTextField> createState() => _SuggestionTreatmentTextFieldState();
}

class _SuggestionTreatmentTextFieldState extends State<SuggestionTreatmentTextField> {
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
          child: DropDownTextField(
            onChanged: (value) {
              DropDownValueModel val = value;
              widget.onChanged(val.name);
            },
            enableSearch: true,
            searchDecoration: InputDecoration(
              hintText: "Search drug"
            ),
            textFieldDecoration: InputDecoration(
              hintText: '${widget.hintText}',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),dropDownList: [
              DropDownValueModel(name: 'drug', value: 'drug'),
          ],
          ),
        ),
      ],
    );
  }
}
