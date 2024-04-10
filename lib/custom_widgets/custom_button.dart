import 'package:flutter/material.dart';
import '../constants.dart';

class CustomButton extends StatelessWidget {
  CustomButton({required this.text, required this.backgroundColor, required this.onPressed, this.isLoading = false, this.loadingWidget = null});
  String text;
  Color backgroundColor;
  Function onPressed;
  bool isLoading;
  var loadingWidget;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        if(!isLoading)
        onPressed();
      },
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(16)),
        child: Center(child: isLoading ? loadingWidget : Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),)),
      ),
    );
  }
}
