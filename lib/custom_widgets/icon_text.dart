import 'package:flutter/material.dart';

import '../constants.dart';

class IconText extends StatelessWidget {

  IconText({required this.text, required this.icon, required this.func});
  String text;
  IconData icon;
  Function func;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: (){
        func();
      },
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(child: Icon(icon, color: Colors.white,), decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: kPrimaryColor),),
              SizedBox(width: 8,),
              Text('$text', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),),
            ],
          ),
        ),
      ),
    );
  }
}
