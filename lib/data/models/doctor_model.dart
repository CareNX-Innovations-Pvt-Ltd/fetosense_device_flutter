import 'package:fetosense_device_flutter/data/models/user_model.dart';

class Doctor extends UserModel {
  @override
  int? noOfMother = 0;
  @override
  int? noOfTests = 0;

  Doctor();

  Doctor.fromMap(super.snapshot, super.id)
      : noOfMother = snapshot['noOfMother'],
        noOfTests = snapshot['noOfTests'],
        super.fromMap();
}
