import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/custom_widgets/fixed_sized_tooth.dart';
import 'package:goa_dental_clinic/custom_widgets/tooth.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/tooth_selection_container.dart';
import '../constants.dart';
import '../models/treatment_model.dart';
import 'custom_button.dart';
import 'treatment_text_field.dart';

class TreatmentPlanInputCard extends StatefulWidget {
  TreatmentPlanInputCard({required this.size, required this.onSubmit, this.status = 'normal', this.tm = null});
  Size size;
  Function onSubmit;
  String status;
  TreatmentModel? tm;

  @override
  State<TreatmentPlanInputCard> createState() => _TreatmentPlanInputCardState();
}

class _TreatmentPlanInputCardState extends State<TreatmentPlanInputCard> {
  List<DropDownValueModel> discountList = [
    DropDownValueModel(name: '%', value: '%'),
    DropDownValueModel(name: kRupee, value: kRupee)
  ];
  TextEditingController totalController = TextEditingController();
  List<FixedSizeTooth> toothList = [];

  TreatmentModel tm = TreatmentModel(
    procedure: '',
    note: '',
    discount: -18,
    discountSymbol: '%',
    total: 0,
    cost: 0,
    unit: 0,
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    toothList: [],
  );
  bool isPercentage = true;

  updateTotal() {
    setState(() {
      if (tm.discountSymbol == '%') {
        if (tm.discount != -18)
          totalController.text = ((tm.unit * tm.cost) -
                  ((tm.unit * tm.cost) / 10 * (tm.discount / 10)))
              .toString();
        else
          totalController.text = (tm.unit * tm.cost).toString();
      } else {
        totalController.text = ((tm.unit * tm.cost) - tm.discount).toString();
      }
    });
  }

  showToothSelectionCard(size) {
    showDialog(
        context: context,
        builder: (context) {
          return ToothSelectionWidget(
              numberOfTeeth: 32,
              tList: tm.toothList,
              onDone: (List<dynamic> tList) {
                setState(() {

                  tm.toothList = tList;
                  tList.forEach((element) {
                    toothList.add(FixedSizeTooth(index: element, onTap: (){}));
                  });
                });

              });
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(widget.tm != null){
      tm = widget.tm!;
      totalController.text = tm.total.toString();
      tm.toothList.forEach((element) {
        toothList.add(FixedSizeTooth(index: element, onTap: (){}));
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    totalController.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    return Material(
      color: Colors.transparent,
      child: Center(
        child: GestureDetector(
        onTap: () {
      // Request focus when tapping outside any interactive widgets
        },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            width: widget.size.width * 0.95,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Treatment Plan',
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
                  SizedBox(
                    height: 16,
                  ),
                  TreatmentTextField(
                    title: 'Procedure',
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        tm.procedure = value;
                      });
                    },
                    inputValue: tm.procedure,
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
                  Row(
                    children: [
                      Expanded(
                        child: TreatmentTextField(
                          title: 'Unit',
                          onChanged: (value) {
                            setState(() {
                              tm.unit = int.parse(value);
                              updateTotal();
                            });
                          },
                          inputValue: (tm.unit == 0) ? '' : tm.unit.toString(),
                          inputType: TextInputType.number,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: TreatmentTextField(
                          title: 'Cost',
                          onChanged: (value) {
                            setState(() {
                              tm.cost = double.parse(value);
                              updateTotal();
                            });
                          },
                          inputType: TextInputType.number,
                          inputValue: (tm.cost == 0) ? '' : tm.cost.toString(),
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
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TreatmentTextField(
                          title: 'Discount',
                          onChanged: (value) {
                            setState(() {
                              tm.discount = double.parse(value);
                              updateTotal();
                            });
                          },
                          inputType: TextInputType.number,
                          inputValue: (tm.discount == 0 || tm.discount == -18.0) ? '' : tm.discount.toString(),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: DropDownTextField(
                          dropdownColor: Colors.white,
                          dropDownList: discountList,
                          textFieldDecoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              hintText: (tm.discountSymbol)),
                          onChanged: (value) {
                            DropDownValueModel val = value;
                            setState(() {
                              tm.discountSymbol = val.value;
                              updateTotal();
                              if (val.value == '%') {
                                isPercentage = true;
                              } else {
                                isPercentage = false;
                              }
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(color: kGrey, fontSize: 16),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          onChanged: (value) {},
                          readOnly: true,
                          controller: totalController,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'Total Ammount',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                          keyboardType: TextInputType.number,
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
                  TreatmentTextField(
                    title: 'Note',
                    onChanged: (value) {
                      setState(() {
                        tm.note = value;
                      });
                    },
                    hintText: 'Add Note',
                    inputValue: tm.note,
                  ),
                  SizedBox(height: 16,),
                  InkWell(child: Text('Add Teeth', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 14),), onTap: (){
                    // showToothSelectionCard(MediaQuery.of(context).size);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ToothSelectionWidget(
                        numberOfTeeth: 32,
                        tList: tm.toothList,
                        onDone: (List<dynamic> tList) {
                          setState(() {
                            tm.toothList = tList;
                            toothList.clear();
                            tList.forEach((element) {
                              toothList.add(FixedSizeTooth(index: element, onTap: (){}));
                            });
                          });

                        }),));
                  },),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    height: 65,
                    child: Center(
                      child: ListView.builder(itemBuilder: (context, index){

                        return toothList[index];
                      }, itemCount: toothList.length, scrollDirection: Axis.horizontal,),
                    ),
                  ),
                  SizedBox(height: 16,),
                  // Container(
                  //   height: 300,
                  //   child: ToothSelectionWidget(numberOfTeeth: 32, onToothSelected: (index){
                  //     print('$index');
                  //   }),
                  // ),
                  CustomButton(
                      text: 'Submit',
                      backgroundColor: kPrimaryColor,
                      onPressed: () {
                        tm.total = double.parse(totalController.text).roundToDouble();
                        if (tm.discount == -18.0)
                          setState(() {
                            tm.discount = 0.0;
                          });
                        TreatmentModel tm1 = tm;
                        widget.onSubmit(tm1);
                        Navigator.pop(context);
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
