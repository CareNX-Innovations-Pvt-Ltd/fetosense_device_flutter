import 'babybeatAssociation_model.dart';

class FetosenseTest {
  String? documentId;
  String? motherId;
  String? fetosenseId;
  int? gAge;
  String? motherName;
  int? lengthOfTest;
  int? averageFHR;
  bool? live;
  bool? testByMother;
  String? testById;
  bool? shareReport;

  String? organizationId;
  String? organizationName;

  bool delete = false;
  DateTime? createdOn;
  DateTime? edd;
  DateTime? lmp;
  String? createdBy;
  Map? associations;

  BabybeatAssociationModel? babybeatAssociation;
  String? deviceName;

  FetosenseTest.withData(
      {documentId,
      motherId,
      gAge,
      motherName,
      lengthOfTest,
      averageFHR,
      live,
      testByMother,
      testById,
      organizationId,
      organizationName,
      delete = false,
      createdOn,
      createdBy,
      edd,
      lmp,
      shareReport,
      associations,
      babybeatAssociation,
      deviceName});

  FetosenseTest.data(
      this.motherId,
      this.gAge,
      this.motherName,
      this.lengthOfTest,
      this.averageFHR,
      this.live,
      this.testByMother,
      this.testById,
      this.organizationId,
      this.organizationName,
      this.delete,
      this.createdOn,
      this.createdBy,
      this.edd,
      this.lmp,
      this.shareReport,
      this.associations,
      this.babybeatAssociation,
      this.deviceName);

  FetosenseTest.fromMap(Map snapshot)
      : documentId = snapshot['documentId'] ?? '',
        fetosenseId = snapshot['motherId'],
        gAge = snapshot['gAge'],
        motherName = snapshot['motherName'],
        lengthOfTest = snapshot['lengthOfTest'],
        averageFHR = snapshot['averageFHR'],
        live = snapshot['live'] ?? false,
        testByMother = snapshot['testByMother'],
        testById = snapshot['testById'],
        deviceName = snapshot['deviceName'] ?? null,
        organizationId = snapshot['organizationId'] ?? null,
        organizationName = snapshot['organizationName'] ?? null,
        delete = snapshot['delete'],
        createdOn = snapshot['createdOn'] != null
            ? snapshot['createdOn'] is String
                ? DateTime.parse(snapshot['createdOn'])
                : snapshot['createdOn']
            : new DateTime.now(),
        createdBy = snapshot['createdBy'],
        edd = snapshot['edd'] != null
            ? snapshot['edd'] is String
                ? DateTime.parse(snapshot['edd'])
                : snapshot['edd']
            : null,
        lmp = snapshot['lmp'] != null
            ? snapshot['lmp'] is String
                ? DateTime.parse(snapshot['lmp'])
                : snapshot['lmp']
            : null,
        shareReport = snapshot['shareReport'],
        associations = snapshot['association'],
        babybeatAssociation = snapshot['babyBeatAssociation'] != null
            ? BabybeatAssociationModel.fromJson(snapshot['babyBeatAssociation'])
            : null;

  FetosenseTest.fromSnapshot(Map snapshot)
      : documentId = snapshot['documentId'] ?? '',
        fetosenseId = snapshot['motherId'],
        gAge = snapshot['gAge'],
        motherName = snapshot['motherName'],
        lengthOfTest = snapshot['lengthOfTest'],
        averageFHR = snapshot['averageFHR'],
        live = snapshot['live'] ?? false,
        shareReport = snapshot['shareReport'] ?? null,
        testByMother = snapshot['testByMother'],
        testById = snapshot['testById'],
        deviceName = snapshot['deviceName'] ?? null,
        organizationId = snapshot['organizationId'] ?? null,
        organizationName = snapshot['organizationName'] ?? null,
        delete = snapshot['delete'],
        createdOn = snapshot['createdOn']?.toDate(),
        createdBy = snapshot['createdBy'],
        associations = snapshot['association'],
        babybeatAssociation = snapshot['babyBeatAssociation'] != null
            ? BabybeatAssociationModel.fromJson(snapshot['babyBeatAssociation'])
            : null;

  Map<String, Object> toJson() {
    return {
      'documentId': documentId!,
      'fetosenseId': fetosenseId ?? '',
      'motherId': motherId ?? '',
      'gAge': gAge!,
      'motherName': motherName!,
      'lengthOfTest': lengthOfTest!,
      'averageFHR': averageFHR!,
      'live': live ?? false,
      'shareReport': shareReport ?? false,
      'testByMother': testByMother!,
      'testById': testById ?? '',
      'deviceName': deviceName!,
      'organizationId': organizationId!,
      'organizationName': organizationName!,
      'delete': delete,
      'createdOn': createdOn!,
      'createdBy': createdBy!,
      'association': associations!,
      'babyBeatAssociation': BabybeatAssociationModel.toJson(
          babybeatAssociation ?? BabybeatAssociationModel())
    };
  }

  FetosenseTest();

  String getOrganizationName() {
    return organizationName!;
  }

  void setOrganizationName(String organizationName) {
    this.organizationName = organizationName;
  }

  String getOrganizationId() {
    return organizationId!;
  }

  void setOrganizationId(String organizationId) {
    this.organizationId = organizationId;
  }

  String getDocumentId() {
    return documentId!;
  }

  void setDocumentId(String documentId) {
    this.documentId = documentId;
  }

  BabybeatAssociationModel get babybeatAssociations => babybeatAssociation!;

  set babybeatAssociations(BabybeatAssociationModel value) {
    babybeatAssociation = value;
  }

  DateTime getCreatedOn() {
    return createdOn!;
  }

  void setCreatedOn(DateTime createdOn) {
    this.createdOn = createdOn;
  }

  String getCreatedBy() {
    return createdBy!;
  }

  void setCreatedBy(String createdBy) {
    this.createdBy = createdBy;
  }

  bool isDelete() {
    return delete;
  }

  void setDelete(bool delete) {
    this.delete = delete;
  }

  bool isLive() {
    return live!;
  }

  void setLive(bool _live) {
    this.live = _live;
  }

  bool isShareReport() {
    return shareReport!;
  }

  void setShareReport(bool shareReport) {
    this.shareReport = shareReport;
  }

  Map association() {
    return associations!;
  }

  void setAssociation(Map associations) {
    this.associations = associations;
  }
}
