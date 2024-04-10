import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/constants.dart';

class Tooth extends StatefulWidget {
  @override
  _ToothState createState() => _ToothState();

  Tooth({required this.index, required this.onTap, this.initialValue = false});
  int index;
  Function onTap;
  bool initialValue;
}

class _ToothState extends State<Tooth> {
  bool isSelected = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.initialValue)
      isSelected = widget.initialValue;
  }
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: (){
          setState(() {
            isSelected = !isSelected;
          });
          widget.onTap(widget.index, isSelected);
        },
        child: Container(
          // Customize the appearance of the tooth widget
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor : Colors.white,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${widget.index}',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
