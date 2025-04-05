import 'package:flutter/foundation.dart';

/// A model class representing a test.
class Test {
  String? id;
  String? documentId;
  String? motherId;
  String? deviceId;
  String? doctorId;

  int? weight;
  int? gAge;
  int? fisherScore;
  int? fisherScore2;

  String? motherName;
  String? deviceName;
  String? doctorName;
  String? patientId;
  int? age;

  String? organizationId;
  String? organizationName;

  String? imageLocalPath;
  String? imageFirePath;
  String? audioLocalPath;
  String? audioFirePath;
  bool? isImgSynced;
  bool? isAudioSynced;

  List<int>? bpmEntries;
  List<int>? bpmEntries2;
  List<int>? mhrEntries;
  List<int>? spo2Entries;
  List<int>? baseLineEntries;
  List<int>? movementEntries;
  List<int>? autoFetalMovement;
  List<int>? tocoEntries;
  int? lengthOfTest;
  int? averageFHR;

  bool? live;
  bool? testByMother;
  String? testById;
  String? interpretationType;
  String? interpretationExtraComments;

  Map<String, dynamic>? associations;
  Map<String, dynamic>? autoInterpretations;

  bool? delete = false;
  DateTime? createdOn;
  String? createdBy;

  /// Constructs a [Test] instance with the given data.
  Test.withData({
    this.id,
    this.documentId,
    this.motherId,
    this.deviceId,
    this.doctorId,
    this.weight,
    this.gAge,
    this.age,
    this.fisherScore,
    this.fisherScore2,
    this.motherName,
    this.deviceName,
    this.doctorName,
    this.patientId,
    this.organizationId,
    this.organizationName,
    this.imageLocalPath,
    this.imageFirePath,
    this.audioLocalPath,
    this.audioFirePath,
    this.isImgSynced,
    this.isAudioSynced,
    this.bpmEntries,
    this.bpmEntries2,
    this.baseLineEntries,
    this.movementEntries,
    this.autoFetalMovement,
    this.tocoEntries,
    this.lengthOfTest,
    this.averageFHR,
    this.live,
    this.testByMother,
    this.testById,
    this.interpretationType,
    this.interpretationExtraComments,
    this.associations,
    this.autoInterpretations,
    this.delete = false,
    this.createdOn,
    this.createdBy,
  });

  /// Constructs a [Test] instance with the given data.
  Test.data(
    this.id,
    this.motherId,
    this.deviceId,
    this.doctorId,
    this.weight,
    this.gAge,
    this.age,
    this.fisherScore,
    this.fisherScore2,
    this.motherName,
    this.deviceName,
    this.doctorName,
    this.patientId,
    this.organizationId,
    this.organizationName,
    this.imageLocalPath,
    this.imageFirePath,
    this.audioLocalPath,
    this.audioFirePath,
    this.isImgSynced,
    this.isAudioSynced,
    this.bpmEntries,
    this.bpmEntries2,
    this.mhrEntries,
    this.spo2Entries,
    this.baseLineEntries,
    this.movementEntries,
    this.autoFetalMovement,
    this.tocoEntries,
    this.lengthOfTest,
    this.averageFHR,
    this.live,
    this.testByMother,
    this.testById,
    this.interpretationType,
    this.interpretationExtraComments,
    this.associations,
    this.autoInterpretations,
    this.delete,
    this.createdOn,
    this.createdBy,
  );

  /// Constructs a [Test] instance from a map.
  ///
  /// [snapshot] is a map containing the test data.
  /// [id] is the unique identifier of the test.
  Test.fromMap(Map snapshot, String id)
      : id = snapshot['id'],
        documentId = snapshot['documentId'] ?? '',
        motherId = snapshot['motherId'],
        deviceId = snapshot['deviceId'],
        doctorId = snapshot['doctorId'],
        weight = snapshot['weight'],
        gAge = snapshot['gAge'],
        age = snapshot['age'],
        fisherScore = snapshot['fisherScore'],
        fisherScore2 = snapshot['fisherScore2'],
        motherName = snapshot['motherName'],
        deviceName = snapshot['deviceName'],
        doctorName = snapshot['doctorName'],
        patientId = snapshot['patientId'],
        organizationId = snapshot['organizationId'],
        organizationName = snapshot['organizationName'],
        imageLocalPath = snapshot['imageLocalPath'],
        imageFirePath = snapshot['imageFirePath'],
        audioLocalPath = snapshot['audioLocalPath'],
        audioFirePath = snapshot['audioFirePath'],
        isImgSynced = snapshot['isImgSynced'],
        isAudioSynced = snapshot['isAudioSynced'],
        bpmEntries = snapshot['bpmEntries'] != null
            ? snapshot['bpmEntries'].cast<int>()
            : <int>[],
        bpmEntries2 = snapshot['bpmEntries2'] != null
            ? snapshot['bpmEntries2'].cast<int>()
            : <int>[],
        mhrEntries = snapshot['mhrEntries'] != null
            ? snapshot['mhrEntries'].cast<int>()
            : <int>[],
        spo2Entries = snapshot['spo2Entries'] != null
            ? snapshot['spo2Entries'].cast<int>()
            : <int>[],
        baseLineEntries = snapshot['baseLineEntries'] != null
            ? snapshot['baseLineEntries'].cast<int>()
            : <int>[],
        movementEntries = snapshot['movementEntries'] != null
            ? snapshot['movementEntries'].cast<int>()
            : <int>[],
        autoFetalMovement = snapshot['autoFetalMovement'] != null
            ? snapshot['autoFetalMovement'].cast<int>()
            : <int>[],
        tocoEntries = snapshot['tocoEntries'] != null
            ? snapshot['tocoEntries'].cast<int>()
            : <int>[],
        lengthOfTest = snapshot['lengthOfTest'],
        averageFHR = snapshot['averageFHR'],
        live = snapshot['live'] ?? false,
        testByMother = snapshot['testByMother'],
        testById = snapshot['testById'],
        interpretationType = snapshot['interpretationType'],
        interpretationExtraComments = snapshot['interpretationExtraComments'],
        associations = snapshot['association'] ?? <String, dynamic>{},
        autoInterpretations = snapshot['autoInterpretations'] ?? <String, dynamic>{},
        delete = snapshot['delete'],
        createdOn = snapshot['createdOn'].toDate(),
        createdBy = snapshot['createdBy'];

  /// Default constructor for the [Test] class.
  Test();

  /// Gets the organization name.
  ///
  /// Returns the organization name as a [String].
  String? getOrganizationName() {
    return organizationName;
  }

  /// Sets the organization name.
  ///
  /// [organizationName] is the new organization name to be set.
  void setOrganizationName(String organizationName) {
    this.organizationName = organizationName;
  }

  /// Gets the organization ID.
  ///
  /// Returns the organization ID as a [String].
  String? getOrganizationId() {
    return organizationId;
  }

  /// Sets the organization ID.
  ///
  /// [organizationId] is the new organization ID to be set.
  void setOrganizationId(String organizationId) {
    this.organizationId = organizationId;
  }

  /// Gets the document ID.
  ///
  /// Returns the document ID as a [String].
  String? getDocumentId() {
    return id;
  }

  /// Sets the document ID.
  ///
  /// [documentId] is the new document ID to be set.
  void setDocumentId(String documentId) {
    id = documentId;
  }

  /// Gets the creation date.
  ///
  /// Returns the creation date as a [DateTime].
  DateTime? getCreatedOn() {
    return createdOn;
  }

  /// Sets the creation date.
  ///
  /// [createdOn] is the new creation date to be set.
  void setCreatedOn(DateTime createdOn) {
    this.createdOn = createdOn;
  }

  /// Gets the creator.
  ///
  /// Returns the creator as a [String].
  String? getCreatedBy() {
    return createdBy;
  }

  /// Sets the creator.
  ///
  /// [createdBy] is the new creator to be set.
  void setCreatedBy(String createdBy) {
    this.createdBy = createdBy;
  }

  /// Checks if the test is deleted.
  ///
  /// Returns `true` if the test is deleted, `false` otherwise.
  bool? isDelete() {
    return delete;
  }

  /// Sets the delete status.
  ///
  /// [delete] is the new delete status to be set.
  void setDelete(bool delete) {
    this.delete = delete;
  }

  /// Checks if the test is live.
  ///
  /// Returns `true` if the test is live, `false` otherwise.
  bool? isLive() {
    return live;
  }

  /// Sets the live status.
  ///
  /// [live] is the new live status to be set.
  void setLive(bool live) {
    this.live = live;
  }

  /// Gets the associations.
  ///
  /// Returns the associations as a [Map].
  Map<String, String>? getAssociations() {
    return associations as Map<String, String>?;
  }

  /// Sets the associations.
  ///
  /// [associations] is the new associations to be set.
  void setAssociations(Map<String, String> associations) {
    this.associations = associations;
  }

  /// Gets the automatic interpretations.
  ///
  /// Returns the automatic interpretations as a [Map].
  Map<String, String>? getautoInterpretations() {
    return autoInterpretations as Map<String, String>?;
  }

  /// Sets the automatic interpretations.
  ///
  /// [autoInterpretations] is the new automatic interpretations to be set.
  void setautoInterpretations(Map<String, String> autoInterpretations) {
    this.autoInterpretations = autoInterpretations;
  }

  /// Converts the [Test] instance to a JSON map.
  ///
  /// Returns a map containing the test data.
  Map<String, Object?> toJson() {
    return {
      'documentId': documentId,
      'motherId': motherId,
      'deviceId': deviceId,
      'doctorId': doctorId,
      'weight': weight,
      'gAge': gAge,
      'fisherScore': fisherScore,
      'fisherScore2': fisherScore2,
      'motherName': motherName,
      'deviceName': deviceName,
      'doctorName': doctorName,
      'patientId': patientId,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'audioLocalPath': audioLocalPath,
      'bpmEntries': bpmEntries,
      'bpmEntries2': bpmEntries2,
      'mhrEntries': mhrEntries,
      'spo2Entries': spo2Entries,
      'baseLineEntries': baseLineEntries,
      'movementEntries': movementEntries,
      'autoFetalMovement': autoFetalMovement,
      'tocoEntries': tocoEntries,
      'lengthOfTest': lengthOfTest,
      'averageFHR': averageFHR,
      'live': live ?? false,
      'testByMother': testByMother,
      'testById': testById,
      'interpretationType': interpretationType,
      'interpretationExtraComments': interpretationExtraComments,
      'association': associations.toString(),
      'autoInterpretations': autoInterpretations.toString(),
      'type': "test",
      'delete': delete,
      'createdOn': createdOn!.millisecondsSinceEpoch,
      'createdBy': createdBy,
    };
  }

  void printDetails() {
    if (kDebugMode) {
      print('Test Details:');
      print('ID: $id');
      print('Document ID: $documentId');
      print('Mother ID: $motherId');
      print('Device ID: $deviceId');
      print('Doctor ID: $doctorId');
      print('Weight: $weight');
      print('Gestational Age: $gAge');
      print('Age: $age');
      print('Fisher Score 1: $fisherScore');
      print('Fisher Score 2: $fisherScore2');
      print('Mother Name: $motherName');
      print('Device Name: $deviceName');
      print('Doctor Name: $doctorName');
      print('Patient ID: $patientId');
      print('Organization ID: $organizationId');
      print('Organization Name: $organizationName');
      print('Image Local Path: $imageLocalPath');
      print('Image Fire Path: $imageFirePath');
      print('Audio Local Path: $audioLocalPath');
      print('Audio Fire Path: $audioFirePath');
      print('Is Image Synced: $isImgSynced');
      print('Is Audio Synced: $isAudioSynced');
      print('BPM Entries: $bpmEntries');
      print('BPM Entries 2: $bpmEntries2');
      print('MHR Entries: $mhrEntries');
      print('SPO2 Entries: $spo2Entries');
      print('Baseline Entries: $baseLineEntries');
      print('Movement Entries: $movementEntries');
      print('Auto Fetal Movement: $autoFetalMovement');
      print('TOCO Entries: $tocoEntries');
      print('Length of Test: $lengthOfTest');
      print('Average FHR: $averageFHR');
      print('Live: $live');
      print('Test By Mother: $testByMother');
      print('Test By ID: $testById');
      print('Interpretation Type: $interpretationType');
      print('Interpretation Extra Comments: $interpretationExtraComments');
      print('Associations: $associations');
      print('Auto Interpretations: $autoInterpretations');
      print('Deleted: $delete');
      print('Created On: $createdOn');
      print('Created By: $createdBy');
    }
  }

}
