import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/models/appointment_msg_model.dart';
import 'package:goa_dental_clinic/models/patient_model.dart';
import 'package:goa_dental_clinic/screens/patient_screens/patient_details_screen.dart';

class MessageCard extends StatefulWidget {

  @override
  State<MessageCard> createState() => _MessageCardState();

  MessageCard({required this.onAccept, required this.onReject, required this.am});
  AppointmentMessageModel? am;
  Function onAccept, onReject;

}

class _MessageCardState extends State<MessageCard> {

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  showAcceptDialogBox() {
    showDialog(context: context, builder: (context) {
      return Material(
        color: Colors.transparent,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AlertDialog(
              title: Text('Accept it ?'),
              content: Text('Do you accept ${widget.am!.patientName}\'s appointment request ?'),
              actions: [
                ElevatedButton(onPressed: () {
                  widget.onAccept(widget.am);
                  Navigator.pop(context);
                }, child: Text('Yes'),),
                ElevatedButton(onPressed: () {
                  Navigator.pop(context);
                }, child: Text('No'),),
              ],
            ),
          ),
        ),
      );
    });
  }

  showRejectDialogBox() {
    showDialog(context: context, builder: (context) {
      return Material(
        color: Colors.transparent,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AlertDialog(
              title: Text('Reject it ?'),
              content: Text('Do you reject Rounak\'s appointment request ?'),
              actions: [
                ElevatedButton(onPressed: () {
                  widget.onReject();
                  Navigator.pop(context);
                }, child: Text('Yes'),),
                ElevatedButton(onPressed: () {
                  Navigator.pop(context);
                }, child: Text('No')),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => PatientDetailsScreen(pm: null, uid: widget.am!.patientUid,)));
        },
        child: Dismissible(
          background: Container(
            padding: EdgeInsets.all(16.0),
            child: Align(child: Text('Accept', style: TextStyle(color: Colors.white, fontSize: 18),), alignment: AlignmentDirectional.centerStart,),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.greenAccent,),
          ),
          secondaryBackground: Container(
            padding: EdgeInsets.all(16.0),
            child: Align(child: Text('Reject', style: TextStyle(color: Colors.white, fontSize: 18),), alignment: AlignmentDirectional.centerEnd,),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.redAccent,),
          ),
          confirmDismiss: (direction) async {
            if(DismissDirection.startToEnd == direction){
              showAcceptDialogBox();
              return false;
            }
            else {
              showRejectDialogBox();
              return false;
            }
          },
          key: UniqueKey(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                  border: Border.all(color: kGrey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            child: Center(
                              child: CircleAvatar(
                                radius: 30,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${widget.am?.patientName}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                    '${widget.am?.message}'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: (){
                            showAcceptDialogBox();
                          },
                          child: Container(
                            height: 32,
                            child: Center(
                              child: Text(
                                'Accept',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            decoration:
                            BoxDecoration(color: Colors.greenAccent, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12))),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: (){
                            showRejectDialogBox();
                          },
                          child: Container(
                              height: 32,
                              child: Center(
                                child: Text(
                                  'Reject',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              decoration:
                              BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.only(bottomRight: Radius.circular(12)))),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
