import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/models/plan_model.dart';

class AddPlanProvider extends ChangeNotifier{
  List<PlanModel> _pList = [];

  List<PlanModel> get pList  => _pList;

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