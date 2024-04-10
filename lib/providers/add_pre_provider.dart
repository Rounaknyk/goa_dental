import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/models/plan_model.dart';

import '../models/pre_model.dart';

class AddPreProvider extends ChangeNotifier{
  List<PreModel> _pList = [];

  List<PreModel> get pList  => _pList;

  setPList(list){
    _pList = list;
    notifyListeners();
  }

  removePlist(PlanModel pm){
    _pList.remove(pm);
    notifyListeners();
  }

  emptyPlist(){
    _pList.clear();
    notifyListeners();
  }
}