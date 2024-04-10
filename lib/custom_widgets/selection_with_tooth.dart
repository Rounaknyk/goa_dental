import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goa_dental_clinic/custom_widgets/fixed_sized_tooth.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/test_screen.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/tooth_selection_container.dart';

import '../constants.dart';

class SelectionWithTooth extends StatefulWidget {
  SelectionWithTooth({required this.title, required this.onAdd, required this.onChecked, this.readOnly = true, this.isChecked = false, this.addList, this.isToothVisible =  true});
  Function(List<dynamic>, String, bool) onAdd;
  Function(bool, String) onChecked;
  bool readOnly;
  String title;
  bool isToothVisible;
  bool isChecked;
  List<dynamic>? addList;

  @override
  State<SelectionWithTooth> createState() => _SelectionWithToothState();
}

class _SelectionWithToothState extends State<SelectionWithTooth> {
  bool isChecked = false;
  TextEditingController textController = TextEditingController();
  List<Widget> toothList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.addList!.isNotEmpty || widget.addList != null)
      toothList = widget.addList!.map((e){
        return FixedSizeTooth(index: e, onTap: (){}, height: 40, width: 40,);
      }).toList();
    textController.text = widget.title;
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
                        widget.onChecked(checked, textController.text);
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
                    decoration: InputDecoration(border: InputBorder.none, hintText: "Enter title"),
                    readOnly: widget.readOnly,
                    controller: textController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ToothSelectionWidget(
                            numberOfTeeth: 32,
                            tList: widget.addList,
                            onDone: (list) {
                              print(list);
                              //switch orientation to protrait if in landscape mode
                              SystemChrome.setPreferredOrientations([
                                DeviceOrientation.portraitDown,
                                DeviceOrientation.portraitUp,
                              ]);
                              setState(() {
                                toothList.clear();
                                for(var e in list){
                                  toothList.add(FixedSizeTooth(index: e, onTap: (){}, height: 40, width: 40, nontapable: false,),);
                                }
                              });
                              widget.onAdd(list, textController.text, isChecked);
                            },
                          ),
                        ),
                      );
                    },
                    child: Visibility(
                      visible: widget.isToothVisible,
                      child: Container(
                        height: 40,
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '+ Add Tooth',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Wrap(
              children: toothList,
            ),
          ],
        ),
      ),
    );
  }
}
