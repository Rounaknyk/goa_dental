import 'package:flutter/material.dart';

import '../constants.dart';

class IconTextField extends StatefulWidget {
  IconTextField(
      {required this.hintText,
      required this.icon,
      this.isSecured = false,
      this.trailingFunc = null, this.inputType = TextInputType.text, required this.onChanged, this.inputValue = '', this.readOnly = false, this.errorText});
  String hintText;
  IconData icon;
  bool isSecured;
  var trailingFunc;
  TextInputType inputType;
  Function onChanged;
  bool readOnly;
  var inputValue;
  var errorText;

  @override
  State<IconTextField> createState() => _IconTextFieldState();
}

class _IconTextFieldState extends State<IconTextField> {
  bool visible = false;
  IconData suffixIcon = Icons.remove_red_eye;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    visible = widget.isSecured;
    suffixIcon = (visible) ? Icons.remove_red_eye : Icons.not_accessible;
    controller.text = widget.inputValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          widget.icon,
          color: kGrey,
        ),
        SizedBox(
          width: 16,
        ),
        Expanded(
          child: TextField(
            readOnly: widget.readOnly,
            controller: controller,
            onChanged: (newValue){
              widget.onChanged(newValue);
            },
            keyboardType: widget.inputType,
            decoration: InputDecoration(
              errorText: widget.errorText,
              hintText: widget.hintText,
              suffixIcon: widget.isSecured ? GestureDetector(
                onTap: () {
                  visible = !visible;
                  setState(() {
                    suffixIcon = (visible) ? Icons.remove_red_eye:  Icons.not_accessible;
                  });
                },
                child: GestureDetector(
                  child: Icon(
                    suffixIcon,
                    color: kGrey,
                  ),
                ),) : null
            ),
            style: TextStyle(fontWeight: FontWeight.w600,),
            obscureText: visible,
          ),
        ),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
