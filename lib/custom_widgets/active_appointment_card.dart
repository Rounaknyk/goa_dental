import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../constants.dart';

class ActiveAppointmentCard extends StatelessWidget {
  ActiveAppointmentCard({
    required this.size,
    required this.name,
    required this.day,
    required this.date,
    required this.time,
    required this.role,
  });

  final Size size;
  final String name, role, date, day, time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height: size.height * 0.15,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: kGrey,
          ), color: Colors.white),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kGrey),),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$date', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
                  Text('$day', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),),
                ],
              ),
            ),
          ),
          SizedBox(width: 12,),
          Container(
            decoration: BoxDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Container(
                  width: size.width * 0.8 * 0.2,
                  decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(16)),
                  child: Center(child: Text('$time', style: TextStyle(color: Colors.white, fontSize: 12),)),
                ),
                SizedBox(height: 4,),
                Expanded(child: Text('$name', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), maxLines: 1,), flex: 2,),
                SizedBox(height: 4,),
                Expanded(child: Text('$role'), flex: 2,),
              ],
            ),
          ),
          SizedBox(width: 10),
          LottieBuilder.asset('anim/doctor_appointment.json'),
          SizedBox(width: 10),
          GestureDetector(child: Icon(Icons.more_vert, color: Colors.black,), onTap: (){
            print('pressed on more');
          },),
        ],
      ),
    );

  }
}
