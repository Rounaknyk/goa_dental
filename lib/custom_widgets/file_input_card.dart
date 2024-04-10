import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:image_picker/image_picker.dart';

import '../classes/alert.dart';

class FileInputCard extends StatefulWidget {
  FileInputCard({required this.size, required this.onUpload});
  Size size;
  Function(File, String) onUpload;

  @override
  State<FileInputCard> createState() => _FileInputCardState();
}

class _FileInputCardState extends State<FileInputCard> {

  File? file;
  UploadTask? uploadTask;
  FirebaseStorage storage = FirebaseStorage.instance;
  String url = '';
  TextEditingController controller = TextEditingController();

  pickFile() async {
    FilePickerResult? res = await FilePicker.platform.pickFiles(type: FileType.image);
    if(res != null){
      setState(() {
        file = File(res.files.single.path!);
      });
    }
    controller.text = '';
  }

  uploadImage() async {
    try {
      final data = storage
          .ref()
          .child("images")
          .child(DateTime.now().millisecondsSinceEpoch.toString());
      uploadTask = data.putFile(file!);
      final snapshot = await uploadTask?.whenComplete(() => () {});
      url = (await snapshot?.ref.getDownloadURL())!;
      print(url);
    }
    on FirebaseException catch (e){
      Alert(context, e);
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: widget.size.width * 0.95,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upload Image',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 24),
                    ),
                    InkWell(child: Icon(Icons.highlight_remove_rounded, color: Colors.red,), onTap: (){
                      Navigator.pop(context);
                    },)
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                InkWell(
                  onTap: () {
                    pickFile();
                  },
                  child: Align(
                    alignment: AlignmentDirectional.center,
                    child: Container(
                      height: widget.size.height * 0.3,
                      width: widget.size.width * 0.9,
                      decoration: BoxDecoration(
                        color: kBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kGrey),
                      ),
                      child: Center(
                        child: (file == null) ? SvgPicture.asset('svgs/file.svg',
                            height: widget.size.height * 0.2,
                            width: widget.size.width * 0.2): Image.file(file!, fit: BoxFit.cover,),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                TextField(
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Type description',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  controller: controller,
                ),
                Spacer(),
                InkWell(
                  child: CustomButton(text: 'Upload', backgroundColor: kPrimaryColor, onPressed: (){
                    // uploadImage();
                    widget.onUpload(file!, controller.text);
                    Navigator.pop(context);
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
