import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/custom_widgets/suggestion_treatment_text_field.dart';
import 'package:goa_dental_clinic/custom_widgets/text_dropdown.dart';
import 'package:goa_dental_clinic/custom_widgets/treatment_text_field.dart';
import 'package:goa_dental_clinic/models/prescription_model.dart';

import '../constants.dart';

class PrescriptionInputCard extends StatefulWidget {
  PrescriptionInputCard({required this.size, required this.onChanged, this.pm = null});
  Size size;
  Function onChanged;
  PrescriptionModel? pm;

  @override
  State<PrescriptionInputCard> createState() => _PrescriptionInputCardState();
}

class _PrescriptionInputCardState extends State<PrescriptionInputCard> {

  PrescriptionModel pm = PrescriptionModel(dosage: '', drug: '', duration: '', generalInstruction: '', instruction: '', id: DateTime.now().millisecondsSinceEpoch.toString());

  List<DropDownValueModel> instructionList = [
    DropDownValueModel(name: 'Before food', value: 'Before food'),
    DropDownValueModel(name: 'After food', value: 'After food'),
  ];
  List<DropDownValueModel> dosageList = [
    DropDownValueModel(name: '1-0-1', value: '1-0-1'),
    DropDownValueModel(name: '1-1-1', value: '1-1-1'),
    DropDownValueModel(name: '0-1-1', value: '0-1-1'),
  ];

  List<DropDownValueModel> durationList = [
    DropDownValueModel(name: 'day(s)', value: 'day(s)'),
    DropDownValueModel(name: 'week(s)', value: 'week(s)'),
    DropDownValueModel(name: 'month(s)', value: 'month(s)'),
  ];

  String duration1 = '', duration2 = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.pm != null){
      pm = widget.pm!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          width: widget.size.width * 0.95,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Prescription',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.cancel,
                      color: Colors.black,
                    ),
                  )
                ],
              ),
              SizedBox(height: 16,),
              TreatmentTextField(title: 'Drug', onChanged: (value){
                setState(() {
                  pm.drug = value;
                });
              }, inputValue: pm.drug,),
              SizedBox(
                height: 4,
              ),
              Divider(
                color: kGrey,
              ),
              SizedBox(
                height: 4,
              ),
              TextDropdown(title: 'Dosage & Frequency', list: dosageList, onChanged: (DropDownValueModel value){
                setState(() {
                  pm.dosage = value.name;
                });
              }, dropDownHint: pm.dosage,),
              SizedBox(
                height: 4,
              ),
              Divider(
                color: kGrey,
              ),
              SizedBox(
                height: 4,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TreatmentTextField(
                      title: 'Duration',
                      onChanged: (value) {
                        setState(() {
                          duration1 = value;
                        });
                      },
                      inputValue: (pm.duration != '') ? pm.duration.split(' ')[0] : '',
                      inputType: TextInputType.number, hintText: 'Duration',
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropDownTextField(
                      dropdownColor: Colors.white,
                      dropDownList: durationList,
                      textFieldDecoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          hintText: (pm.duration == '') ? durationList[0].name : pm.duration.split(' ')[1]) ,
                      onChanged: (value) {
                        DropDownValueModel val = value;
                        setState(() {
                            duration2 = val.name;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 4,
              ),
              Divider(
                color: kGrey,
              ),
              SizedBox(
                height: 4,
              ),
              TextDropdown(title: 'Instruction', list: instructionList, onChanged: (DropDownValueModel value){
                setState(() {
                  pm.instruction = value.name;
                },);
              },dropDownHint: pm.instruction, ),
              SizedBox(
                height: 4,
              ),
              Divider(
                color: kGrey,
              ),
              SizedBox(
                height: 4,
              ),
              TreatmentTextField(title: 'General Instruction', hintText: 'Type here',onChanged: (value){
                setState(() {
                  pm.generalInstruction = value;
                });
              }, inputValue: pm.generalInstruction,),
              SizedBox(height: 16,),
              CustomButton(text: 'Submit', backgroundColor: kPrimaryColor, onPressed: (){
                setState(() {
                  pm.duration = '${duration1} ${duration2}';
                  widget.onChanged(pm);
                  Navigator.pop(context);
                });
                print("${pm.duration + pm.dosage + pm.generalInstruction + pm.instruction + pm.drug}");
              })
            ],
          ),
        ),
      ),
    );
  }
}
