
import 'doctorModel.dart';

class BabybeatAssociationModel {
  String? _organisationName;
  String? _organisationId;
  DoctorModel? _doctorModel;

  BabybeatAssociationModel();

  DoctorModel get doctorModel => _doctorModel ?? DoctorModel();
  set doctorModel(DoctorModel value) {
    _doctorModel = value;
  }

  String get organisationId => _organisationId ?? '';
  set organisationId(String value) {
    _organisationId = value;
  }

  String get organisationName => _organisationName ?? '';
  set organisationName(String value) {
    _organisationName = value;
  }

  BabybeatAssociationModel.fromMap(Map<String, dynamic> snapshot) {
    organisationId = snapshot['organisationId'];
    organisationName = snapshot['organisationName'];
    if (snapshot['doctor'] != null) {
      doctorModel = DoctorModel.fromMap(snapshot['doctor']);
    }
  }

  static Map<String, dynamic> toJson(BabybeatAssociationModel babybeatAssociationModel) {
    return {
      'organisationId': babybeatAssociationModel.organisationId.isEmpty ? null : babybeatAssociationModel.organisationId,
      'organisationName': babybeatAssociationModel.organisationName.isEmpty ? null : babybeatAssociationModel.organisationName,
      'doctor': babybeatAssociationModel._doctorModel != null
          ? DoctorModel.toJson(babybeatAssociationModel.doctorModel)
          : null,
    };
  }

  BabybeatAssociationModel.fromJson(Map<String, dynamic> json)
      : _organisationId = json['organisationId'],
        _organisationName = json['organisationName'],
        _doctorModel = json['doctor'] != null
            ? DoctorModel.fromJson(json['doctor'])
            : null;
}
