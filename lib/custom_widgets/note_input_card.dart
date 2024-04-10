import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';

class NoteInputCard extends StatefulWidget {
  NoteInputCard({required this.onSubmit, required this.size});
  Function onSubmit;
  Size size;

  @override
  State<NoteInputCard> createState() => _NoteInputCardState();
}

class _NoteInputCardState extends State<NoteInputCard> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          width: widget.size.width * 0.95,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Add note',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.cancel,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16,),
              Expanded(
                child: TextField(
                  maxLines: null,
                  controller: controller,
                  decoration: InputDecoration(hintText: 'Type here...', border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black))),
                ),
              ),
              SizedBox(height: 16,),
              CustomButton(text: 'Submit', backgroundColor: kPrimaryColor, onPressed: (){
                widget.onSubmit(controller.text);
                Navigator.pop(context);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
