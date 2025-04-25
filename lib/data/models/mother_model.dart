import 'package:fetosense_device_flutter/data/models/user_model.dart';

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
