import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../classes/date_time_parser.dart';
import '../constants.dart';

class MedicalCheckBox extends StatefulWidget {
  MedicalCheckBox(
      {required this.title, required this.onChanged, this.isChecked = false});
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
      leading: Checkbox(
        value: widget.isChecked,
        onChanged: (value) {
          setState(() {
            widget.onChanged(value!, widget.title,);
            widget.isChecked = value;
          });
        },
        activeColor: kPrimaryColor,
      ),
      title: Text("${widget.title}"),
      // trailing: InkWell(
      //   onTap: () async {
      //     DateTime? pickedDate = await showDatePicker(
      //         context: context,
      //         initialDate: DateTime.now(), //get today's date
      //         firstDate: DateTime(
      //             1900), //DateTime.now() - not to allow to choose before today.
      //         lastDate: DateTime(2101));
      //
      //     if (pickedDate != null) {
      //       setState(() {
      //         //t(pickedDate);
      //         final dob =
      //         DateFormat('yyyy-MM-dd').format(pickedDate!);
      //         print(dob);
      //         String date = DateTimeParser(pickedDate.toString())
      //             .getFormattedDate();
      //         dateController.text = date;
      //         // DateTime dateTime = DateTime(pickedDate!.year,
      //         //     pickedDate!.month, pickedDate!.day);
      //         // ageController.text = AgeCalculator
      //         //     .age(dateTime)
      //         //     .years
      //         //     .toString();
      //         // dobController.text = dob!;
      //       });
      //     }
      //     // updateData();
      //   },
      //   child: Text(
      //     'Add Date',
      //     style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
      //   ),
      // ),
    );
  }
}
