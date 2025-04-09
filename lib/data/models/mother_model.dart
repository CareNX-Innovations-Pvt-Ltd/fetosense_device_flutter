import 'package:fetosense_device_flutter/data/models/user_model.dart';

class Mother extends UserModel {
  // String? name;
  // int? age;
  DateTime? lmp;
  DateTime? edd;

  // @override
  // int? noOfTests = 0;
  // String? deviceId;
  // @override
  // String? deviceName;
  // String? type;

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
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['lmp'] = lmp?.toIso8601String();
    data['edd'] = edd?.toIso8601String();
    return data;
  }
}
