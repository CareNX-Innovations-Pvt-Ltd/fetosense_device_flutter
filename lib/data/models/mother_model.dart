import 'package:fetosense_device_flutter/data/models/user_model.dart';

/// Represents a mother user, extending [UserModel] with pregnancy-specific details.
///
/// The `Mother` class adds fields for last menstrual period (LMP), estimated due date (EDD),
/// and a document ID for database reference. It provides constructors for default and JSON
/// initialization, and overrides [toJson] for serialization.
///
/// Example usage:
/// ```dart
/// final mother = Mother.fromJson(jsonData);
/// print(mother.lmp);
/// print(mother.documentId);
/// Map<String, dynamic> json = mother.toJson();
/// ```

class Mother extends UserModel {
  DateTime? lmp;
  DateTime? edd;
  String? documentId;

  Mother();

  Mother.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    age = json['age'];
    lmp = DateTime.tryParse(json['lmp'] ?? '');
    deviceId = json['deviceId'];
    deviceName = json['deviceName'];
    type = json['type'];
    noOfTests = json['noOfTests'];
    deviceName = json['deviceName'];
    documentId = json['documentId'];
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['lmp'] = lmp?.toIso8601String();
    data['edd'] = edd?.toIso8601String();
    data['documentId'] = documentId;
    return data;
  }
}
