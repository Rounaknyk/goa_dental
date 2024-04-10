import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/custom_widgets/fixed_sized_tooth.dart';
import 'package:goa_dental_clinic/custom_widgets/tooth.dart';
import 'package:goa_dental_clinic/models/treatment_model.dart';
import 'package:googleapis/chat/v1.dart';

class TreatmentPlanCard extends StatefulWidget {
  TreatmentPlanCard(
      {required this.tm,
      this.size,
      required this.addFunc,
      required this.editFunc, this.isPatient = false});
  TreatmentModel tm;
  Size? size;
  Function editFunc, addFunc;
  bool isPatient;

  @override
  State<TreatmentPlanCard> createState() => _TreatmentPlanCardState();
}

class _TreatmentPlanCardState extends State<TreatmentPlanCard> {
  List<Tooth> tList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (var tooth in widget.tm.toothList) {
      tList.add(Tooth(index: tooth, onTap: () {}));
    }
  }

  showNote() {
    showDialog(
        context: context,
        builder: (context) {
          return Material(
            color: Colors.transparent,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    color: Colors.white,
                    child: Text(widget.tm.note),
                  ),
                  SizedBox(height: 8,),
                  ElevatedButton(onPressed: (){
                    Navigator.pop(context);
                  }, child: Text('Cancel')),
                ],
              ),
            ),
          );
        });
  }

  showTooth(List<dynamic> toothList) {
    List<FixedSizeTooth> tList = [];

    toothList.forEach((element) {
      tList.add(FixedSizeTooth(index: element, onTap: () {}));
    });

    tList.sort((a, b) => a.index.compareTo(b.index));

    showDialog(
        context: context,
        builder: (context) {
          return Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Wrap(
                        children: tList,
                      ),
                      SizedBox(height: 8,),
                      ElevatedButton(onPressed: (){
                        Navigator.pop(context);
                      }, child: Text('Cancel')),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  '${widget.tm.procedure}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Visibility(
                  visible: !widget.isPatient,
                  child: InkWell(
                    child: Icon(
                      Icons.edit,
                      color: kGrey,
                    ),
                    onTap: () {
                      widget.editFunc(widget.tm);
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Unit: ',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      widget.tm.unit.toString(),
                      style: TextStyle(fontSize: 18, color: Colors.blue[600]),
                    ),
                  ],
                ),
                SizedBox(
                  width: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Cost: ',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      widget.tm.cost.toString(),
                      style: TextStyle(fontSize: 18, color: Colors.blue[600]),
                    ),
                  ],
                ),
                SizedBox(
                  width: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Discount(${widget.tm.discountSymbol})',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      widget.tm.discount.toString(),
                      style: TextStyle(fontSize: 18, color: Colors.blue[600]),
                    ),
                  ],
                ),
                SizedBox(
                  width: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Total: ',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    FittedBox(
                      child: Text(
                        widget.tm.total.toString(),
                        style: TextStyle(fontSize: 18, color: Colors.blue[600]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 8,),
          Expanded(
            child: Row(
              children: [
                (widget.tm.toothList.isEmpty)
                    ? Container(
                  height: 1,
                  width: 1,
                )
                    : InkWell(
                      child: Text(
                        'View tooth',
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      onTap: () {
                        showTooth(widget.tm.toothList);
                      },
                    ),
                Spacer(),
                (widget.tm.note.isEmpty)
                    ? Container(
                  height: 1,
                  width: 1,
                )
                    : InkWell(
                      child: Text(
                        'View Note',
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      onTap: () {
                        showNote();
                      },
                    ),
              ],
            ),
          ),


        ],
      ),
    );
  }
}
