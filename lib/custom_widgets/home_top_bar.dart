import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/screens/patient_screens/add_patient_screen.dart';
import 'package:lottie/lottie.dart';

import '../constants.dart';

class HomeTopBar extends StatelessWidget {
  HomeTopBar({required this.primaryText, this.secondaryText = 'Hello!', required this.initials, this.profileUrl = ''});
  String primaryText, secondaryText, initials, profileUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Text(
            primaryText,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          Spacer(),
          LottieBuilder.asset('anim/tooth.json', height: 40, width: 40,),
          SizedBox(width: 10,),
          (profileUrl == '') ?
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Center(
                child: Text(
                  '$initials',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 24,),
                ),),
          ) : CircleAvatar(backgroundImage: CachedNetworkImageProvider(profileUrl),),
        ],
      ),
    );
  }
}
