import 'user_model.dart';

class Mother extends UserModel {
  int? age;
  int? weight;
  DateTime? lmp;
  DateTime? edd;
  int? noOfTests = 0;
  String? deviceId;
  String? deviceName;

  Mother();

  int? getAge() {
    return age;
  }

  void setAge(int age) {
    this.age = age;
  }

  int? getWeight() {
    return weight;
  }

  void setWeight(int weight) {
    this.weight = weight;
  }

  DateTime? getLmp() {
    return lmp;
  }

  void setLmp(DateTime lmp) {
    this.lmp = lmp;
  }

  DateTime? getEdd() {
    return edd;
  }

  void setEdd(DateTime edd) {
    this.edd = edd;
  }

  int? getNoOfTests() {
    return noOfTests;
  }

  void setNoOfTests(int noOfTests) {
    this.noOfTests = noOfTests;
  }

  String? getDeviceId() {
    return deviceId;
  }

  void setDeviceId(String deviceID) {
    deviceId = deviceID;
  }

  String? getDeviceName() {
    return deviceName;
  }

  void setDeviceName(String deviceName) {
    this.deviceName = deviceName;
  }

  Mother.fromMap(Map<String, dynamic> super.snapshot, super.id)
      :
        age = snapshot['age'],
        weight = snapshot['weight'],
        lmp = snapshot['lmp']?.toDate() ?? DateTime.now(),
        edd = snapshot['edd']?.toDate() ?? DateTime.now(),
        noOfTests = snapshot['noOfTests'],
        deviceId = snapshot['deviceId'],
        deviceName = snapshot['deviceName'],
        super.fromMap();
}

/*  Mother.fromMap(Map snapshot,String id):
        type = snapshot['type']  ?? '',
        organizationId = snapshot['organizationId'] ?? '',
        organizationName = snapshot['organizationName'] ?? '',
        name = snapshot['name'] ?? '',
        email = snapshot['email'] ?? '',
        mobileNo = snapshot['mobileNo'] ?? '',
        uid = snapshot['uid'] ?? '',
        notificationToken = snapshot['notificationToken'] ?? '',
        documentId = snapshot['documentId'] ?? '',
        delete = snapshot['delete'] ?? '',
        createdOn = snapshot['createdOn'] ?? '',
        createdBy = snapshot['createdBy'] ?? '',
        associations = snapshot['associations'] ?? '';
}*/
