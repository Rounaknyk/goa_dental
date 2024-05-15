import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/classes/date_time_parser.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/appointment_history_card.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/custom_widgets/record_appointment_card.dart';
import 'package:intl/intl.dart';

import '../../models/completed_plan_model.dart';

class CheckRecordsScreen extends StatefulWidget {
  const CheckRecordsScreen({super.key});

  @override
  State<CheckRecordsScreen> createState() => _CheckRecordsScreenState();
}

class _CheckRecordsScreenState extends State<CheckRecordsScreen> {
  TextEditingController _controller = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<CompletedPlanModel> cList = [];
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.text =
        DateTimeParser(DateTime.now().toString()).getFormattedDate();
  }

  fetchRecords() async {
    setState(() {
      loading = true;
    });

    final plans = await firestore.collection('Completed Plans').get();
    cList.clear();
    for (var plan in plans.docs) {
      try {
        print(plan['time'] + _controller.text);
        if (plan['time'] == _controller.text) {
          print(plan['plan'] + plan['patientName'] + plan['docName']);
          cList.add(
            CompletedPlanModel(
                plan: plan['plan'],
                toothList: plan['toothList'],
                time: plan['time'],
                patientUid: plan['patientUid'],
                patientName: plan['patientName'],
                docName: plan['docName'],
                docUid: plan['docUid'],
                note: plan['note'],
                week: plan['week']),
          );
        }
      } catch (e) {
        print(e);
        continue;
      }
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text('Check Records'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 8.0,
                ),
                Text(
                  'Select the date: ',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 12.0),
                Container(
                  child: TextField(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(), //get today's date
                          firstDate: DateTime(
                              1900), //DateTime.now() - not to allow to choose before today.
                          lastDate: DateTime(2101));

                      if (pickedDate != null) {
                        setState(() {
                          //t(pickedDate);
                          final dob =
                              DateFormat('yyyy-MM-dd').format(pickedDate!);
                          print(dob);
                          String date = DateTimeParser(pickedDate.toString())
                              .getFormattedDate();
                          _controller.text = date;
                          // DateTime dateTime = DateTime(pickedDate!.year,
                          //     pickedDate!.month, pickedDate!.day);
                          // ageController.text = AgeCalculator
                          //     .age(dateTime)
                          //     .years
                          //     .toString();
                          // dobController.text = dob!;
                        });
                      }
                      // updateData();
                    },
                    controller: _controller,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Today\'s date selected',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      suffixIcon: InkWell(
                        child: Icon(
                          Icons.calendar_month,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.0),
                CustomButton(
                  text: 'Fetch Records',
                  backgroundColor: kPrimaryColor,
                  onPressed: () {
                    fetchRecords();
                  },
                  loadingWidget: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  isLoading: loading,
                ),
                SizedBox(height: 12.0),
                SingleChildScrollView(
                  child: Column(
                    children: cList.map((e) {
                      final list = e.time.split(' ');
                      String date = list[0];
                      String month = list[1];
                      return RecordAppointmentCard(
                        size: size,
                        patientName: e.patientName,
                        week: e.week,
                        date: date,
                        time: e.time,
                        onMorePressed: () {},
                        doctorName: e.docName,
                        doctorUid: e.docUid,
                        patientUid: e.patientUid,
                        appId: 'appId',
                        pm: null,
                        startTimeInMil:
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        month: month,
                        endTimeInMil:
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        refresh: () {},
                        plan: e.plan,
                        toothList: e.toothList,
                        status: 'Completed',
                        note: e.note,
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
