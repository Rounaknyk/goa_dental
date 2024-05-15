import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/custom_widgets/fixed_sized_tooth.dart';
import 'package:goa_dental_clinic/models/patient_model.dart';
import 'package:goa_dental_clinic/models/plan_model.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/calendar_screen2.dart';

class PendingPlanCard extends StatelessWidget {
  PendingPlanCard({required this.plan, required this.toothList, required this.pm, this.hideButton = false, required this.pTime, required this.note});
  String plan;
  PatientModel pm;
  String pTime;
  String note;
  List<dynamic> toothList;
  bool hideButton;

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(12),),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('${plan}'),
                  SizedBox(width: 8.0,),
                  !hideButton ? InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CalendarScreen2(pm: pm, planModel: PlanModel(plan: plan, toothList: toothList, time: pTime),),),);
                    },
                    child: CircleAvatar(child: Icon(Icons.add, color: Colors.white,), radius: 15, backgroundColor: kPrimaryColor,),
                  ) : Container(),
                  Spacer(),
                  Text('${pTime}'),
                ],
              ),
              SizedBox(height: 8.0,),
              Wrap(
                children: toothList.map((e) {
                  return FixedSizeTooth(
                    index: e,
                    onTap: () {},
                    height: 40,
                    width: 40,
                  );
                }).toList(),
              ),
              SizedBox(height: 8.0,),
              Text('${note}'),
            ],
          ),
        ),
      ),
    );
  }
}