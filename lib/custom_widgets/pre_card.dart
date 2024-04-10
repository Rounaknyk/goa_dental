import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/models/pre_model.dart';

import '../constants.dart';


class PreCard extends StatelessWidget {

  PreCard({required this.pm, required this.onEdit, required this.onDelete});
  PreModel pm;
  Function onEdit, onDelete;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(border: Border.all(color: kGrey), borderRadius: BorderRadius.circular(12),),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${pm.title}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
            SizedBox(height: 8,),
            Text('${pm.des}'),
            SizedBox(height: 8,),
            Row(
              children: [
                InkWell(
                  onTap: (){
                    onEdit();
                  },
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.edit,),
                        SizedBox(width: 4.0,),
                        Text('Edit'),
                      ],
                    ),
                  ),
                ),
                Spacer(),
                InkWell(
                  onTap: (){
                    onDelete();
                  },
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.redAccent,),
                        SizedBox(width: 4.0,),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );;
  }
}
