import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/custom_widgets/fixed_sized_tooth.dart';

class PlanCard extends StatelessWidget {
  PlanCard({required this.plan, required this.toothList});
  String plan;
  List<dynamic> toothList;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${plan}'),
            Wrap(
              children: toothList.map((e){

                return FixedSizeTooth(index: e, onTap: (){}, height: 40, width: 40,);
              }).toList(),
            ),
            Divider(
            ),
          ],
        ),
      ),
    );
  }
}
