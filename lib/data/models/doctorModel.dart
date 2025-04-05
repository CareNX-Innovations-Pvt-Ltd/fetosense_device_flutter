class DoctorModel {
  String? _fullName;
  String? _phoneNo;
  String? _designation;

  DoctorModel();

  String get fullName => _fullName ?? '';

  set fullName(String value) {
    _fullName = value;
  }

  String get phoneNo => _phoneNo ?? '';

  set phoneNo(String value) {
    _phoneNo = value;
  }

  String get designation => _designation ?? '';

  set designation(String value) {
    _designation = value;
  }

  DoctorModel.fromMap(Map<String, dynamic> snapshot) {
    fullName = snapshot['fullName'];
    phoneNo = snapshot['phoneNo'];
    designation = snapshot['designation'];
  }

  static Map<String, dynamic> toJson(DoctorModel doctorModel) {
    return {
      'phoneNo': doctorModel.phoneNo.isEmpty ? null : doctorModel.phoneNo,
      'fullName': doctorModel.fullName.isEmpty ? null : doctorModel.fullName,
      'designation':
          doctorModel.designation.isEmpty ? null : doctorModel.designation,
    };
  }

  DoctorModel.fromJson(Map<String, dynamic> json)
      : _phoneNo = json['phoneNo'],
        _designation = json['designation'],
        _fullName = json['fullName'];
}
