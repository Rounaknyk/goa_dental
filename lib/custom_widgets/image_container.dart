import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ImageContainer extends StatelessWidget {
  ImageContainer({
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
        height: size.height * 0.25,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 20),
              height: size.height * 0.2,
              width: size.width * 0.40,
              decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16)),
              child: Align(child: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20),), alignment: Alignment.bottomCenter,),
            ),
            // Positioned(child: Text('Check clinics near you', style: TextStyle(color: Colors.white, fontSize: 14),), bottom: size.height * 0.25 - (size.height * 0.25 * 0.85), left: 10,),
            Positioned(
              top: 0,
              child: Container(
                  height: size.height * 0.2,
                  width: size.width * 0.35,
                  child: SvgPicture.asset(
                    '$imgAddress',
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
