import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/constants.dart';

import '../models/prescription_model.dart';

class PrescriptionCard extends StatelessWidget {

  PrescriptionCard({
    required this.pm,
    required this.editFunc,
  });
  PrescriptionModel pm;
  Function editFunc;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: kGrey), borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Drug Name: ${pm.drug}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 16,),
                InkWell(child: Icon(Icons.edit, color: kGrey,), onTap: (){
                  editFunc(pm);
                },),
              ],
            ),
            SizedBox(height: 8),
            Text('Duration: ${pm.duration}'),
            SizedBox(height: 8),
            Text('Dosage Frequency: ${pm.dosage}'),
            SizedBox(height: 8),
            Text('Instruction: ${pm.instruction}'),
            SizedBox(height: 8),
            Text('Note: ${pm.generalInstruction}'),
          ],
        ),
      ),
    );
  }
}
