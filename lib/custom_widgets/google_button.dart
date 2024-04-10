import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/constants.dart';

class GoogleButton extends StatelessWidget {

  GoogleButton({required this.onPressed});
  Function onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        onPressed();
      },
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
            color: kBackgroundColor,
            borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Image.asset(
                  'assets/google.png',
                  height: 26,
                  width: 26,
                )),
            SizedBox(
              width: 16,
            ),
            Expanded(
              flex: 4,
              child: Text(
                'Login with Google',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
