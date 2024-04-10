import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants.dart';

class LongImageContainer extends StatelessWidget {
  LongImageContainer({
    required this.size,
    required this.imgAddress,
    required this.text,
    required this.onPressed,
  });

  final Size size;
  final String imgAddress;
  final String text;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        onPressed();
      },
      child: Container(
        padding: EdgeInsets.all(12),
        height: size.height * 0.15,
        width: size.width * 0.90,
        decoration: BoxDecoration(
            // color: Colors.blue.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16), border: Border.all(color: kGrey)),
        child: Row(
          children: [
            Container(
                height: size.height * 0.2,
                width: size.width * 0.3,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white, border: Border.all(color: kGrey)),
                child: Image.asset('$imgAddress'),),
            SizedBox(width: 8,),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),),
                  SizedBox(height: 8,),
                  Text('Check out details of your appointments.', style: TextStyle(color: Colors.black),)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
