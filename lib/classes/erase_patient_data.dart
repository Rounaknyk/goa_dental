import 'package:goa_dental_clinic/providers/add_patient_provider.dart';
import 'package:goa_dental_clinic/providers/pd_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../providers/add_plan_provider.dart';
import '../providers/add_pre_provider.dart';

class ErasePatientData{

  BuildContext context;
  ErasePatientData({required this.context});

  erase(){
    try {
      Provider.of<AddPlanProvider>(context, listen: false).emptyPlist();
      Provider.of<AddPatientProvider>(context, listen: false).resetPatient();
      Provider.of<AddPatientProvider>(context, listen: false).emptyList();
      Provider.of<AddPreProvider>(context, listen: false).emptyPlist();
    }catch(E){
      print(E);
    }
  }
}