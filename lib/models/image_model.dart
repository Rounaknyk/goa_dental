import 'package:flutter/material.dart';
import 'dart:io';

class ImageModel{
  String? description, url;
  File? file;
  bool isPdf;

  ImageModel({this.description = '', required this.url, this.file, this.isPdf = false});
}