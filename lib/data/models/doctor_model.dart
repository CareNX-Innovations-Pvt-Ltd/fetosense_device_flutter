import 'package:fetosense_device_flutter/data/models/user_model.dart';

/// Represents a doctor user, extending [UserModel] with additional properties.
///
/// This class adds fields to track the number of mothers and tests associated
/// with the doctor. It provides a default constructor and a constructor for
/// initializing from a map (typically from a database or API).
///
/// Example usage:
/// ```dart
/// final doctor = Doctor.fromMap(snapshot, id);
/// print(doctor.noOfMother);
/// print(doctor.noOfTests);
/// ```

class Doctor extends UserModel {
  int? noOfMother = 0;
  int? noOfTests = 0;

  Doctor();

  Doctor.fromMap(super.snapshot, super.id)
      : noOfMother = snapshot['noOfMother'],
        noOfTests = snapshot['noOfTests'],
        super.fromMap();
}
