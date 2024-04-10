
import 'package:flutter/cupertino.dart';

import '../models/user_model.dart';

class UserProvider extends ChangeNotifier{

  late UserModel _um;

  UserModel get um => _um;

  setUser(um){
    _um = um;
    notifyListeners();
  }

}