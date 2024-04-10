import 'package:flutter/material.dart';

class PrescriptionModel {
  String drug, dosage, duration, instruction, generalInstruction, id;

  PrescriptionModel({
    required this.dosage,
    required this.drug,
    required this.duration,
    required this.generalInstruction,
    required this.instruction,
    required this.id,
  });
}
