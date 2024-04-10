import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goa_dental_clinic/custom_widgets/fixed_sized_tooth.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/test_screen.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/tooth_selection_container.dart';

import '../constants.dart';

class SelectionPrescriptionCard extends StatefulWidget {
  SelectionPrescriptionCard({required this.title, required this.onChecked, this.readOnly = true, this.isChecked = false, required this.des, this.onChanged});
  Function(bool, String, String) onChecked;
  bool readOnly;
  String title, des;
  bool isChecked;
  Function(bool, String, String)? onChanged;
  @override
  State<SelectionPrescriptionCard> createState() => _SelectionPrescriptionCardState();
}

class _SelectionPrescriptionCardState extends State<SelectionPrescriptionCard> {
  bool isChecked = false;
  TextEditingController titleController = TextEditingController();
  TextEditingController desController = TextEditingController();
  List<Widget> toothList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    titleController.text = widget.title;
    desController.text = widget.des;
    isChecked = widget.isChecked;
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: kGrey),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white
        ),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  activeColor: kPrimaryColor,
                  onChanged: (checked) {
                    setState(() {
                        isChecked = checked!;
                        widget.onChecked(checked, titleController.text, desController.text);
                        // widget.onChanged!(isChecked, titleController.text, desController.text);
                      },
                    );
                  },
                  value: isChecked,
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(border: !widget.readOnly ? null : InputBorder.none, hintText: "Enter title"),
                    readOnly: widget.readOnly,
                    controller: titleController,
                    onChanged: (title){
                      widget.onChanged!(isChecked, titleController.text, desController.text);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 4,),
            Divider(color: kGrey,),
            SizedBox(height: 2,),
            TextField(
              decoration: InputDecoration(border: !widget.readOnly ? null : InputBorder.none, hintText: "Enter description", ),
              readOnly: widget.readOnly,
              controller: desController,
              maxLines: null,
              onChanged: (des){
                widget.onChanged!(isChecked, titleController.text, desController.text);
              },
            ),
          ],
        ),
      ),
    );
  }
}
