import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/models/patient_model.dart';
import 'package:goa_dental_clinic/screens/patient_screens/patient_details_screen.dart';

class PatientCard extends StatelessWidget {
  PatientCard({required this.pm});
  PatientModel pm;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PatientDetailsScreen(
                        pm: pm,
                        uid: pm.patientUid,
                      ),),);
        },
        child: Container(
          height: size.height * 0.08,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              pm.profileUrl.isEmpty
                  ? CircleAvatar(
                      backgroundColor: kPrimaryColor,
                      radius: 30,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    )
                  : CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(pm.profileUrl),
                    ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${pm.patientName}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text("${pm.phoneNumber1}"),
                ],
              ),
              Container(
                width: 50,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
