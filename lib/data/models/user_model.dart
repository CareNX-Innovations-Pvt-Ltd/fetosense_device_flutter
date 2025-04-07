
class UserModel {
  String? type;
  String? organizationId;
  String? organizationName;
  String? organizationIdBabyBeat;
  String? organizationNameBabyBeat;
  String? name;
  String? email;
  String? mobileNo;
  String? uid;
  String? notificationToken;
  String? documentId;
  bool delete = false;
  DateTime? createdOn;
  String? createdBy;
  Map? associations;
  Map? babyBeatAssociation;

  UserModel.withData(
      {type,
      organizationId,
      organizationName,
      organizationIdBabyBeat,
      organizationNameBabyBeat,
      name,
      email,
      mobileNo,
      uid,
      notificationToken,
      documentId,
      delete = false,
      createdOn,
      createdBy,
      associations, babyBeatAssociation});

  UserModel.fromMap(Map snapshot, String id)
      : type = snapshot['type'] ?? '',
        organizationId = snapshot['organizationId'] ?? '',
        organizationName = snapshot['organizationName'] ?? '',
        organizationIdBabyBeat = snapshot['organizationIdBabyBeat'] ?? '',
        organizationNameBabyBeat = snapshot['organizationNameBabyBeat'] ?? '',
        name = snapshot['name'] ?? '',
        email = snapshot['email'] ?? '',
        mobileNo = snapshot['mobileNo'] ?? '',
        uid = snapshot['uid'] ?? '',
        notificationToken = snapshot['notificationToken'] ?? '',
        documentId = snapshot['documentId'] ?? '',
        delete = snapshot['delete'] ?? false,
        createdOn = snapshot['createdOn']?.toDate(),
        createdBy = snapshot['createdBy'] ?? '',
        associations = snapshot['associations'],
        babyBeatAssociation = snapshot['babyBeatAssociation'];

  UserModel();

/*
  User({this.name,
    this.email,
    this.createdOn,
    this.createdBy,
    this.uid,
})
*/

  String? getType() {
    return type;
  }

  void setType(String type) {
    this.type = type;
  }

  String? getOrganizationName() {
    return organizationName;
  }

  void setOrganizationName(String organizationName) {
    this.organizationName = organizationName;
  }

  String? getOrganizationId() {
    return organizationId;
  }

  void setOrganizationId(String organizationId) {
    this.organizationId = organizationId;
  }

  String? getOrganizationNameBabyBeat() {
    return organizationNameBabyBeat;
  }

  void setOrganizationNameBabyBeat(String organizationName) {
    organizationNameBabyBeat = organizationName;
  }

  String? getOrganizationIdBabyBeat() {
    return organizationIdBabyBeat;
  }

  void setOrganizationIdBabyBeat(String organizationId) {
    organizationIdBabyBeat = organizationId;
  }

  String? getName() {
    return name;
  }

  void setName(String name) {
    this.name = name;
  }

  String? getEmail() {
    return email;
  }

  void setEmail(String email) {
    this.email = email;
  }

  String? getMobileNo() {
    return mobileNo;
  }

  void setMobileNo(String mobileNo) {
    this.mobileNo = mobileNo;
  }

  String? getUid() {
    return uid;
  }

  void setUid(String uid) {
    this.uid = uid;
  }

  String? getNotificationToken() {
    return notificationToken;
  }

  void setNotificationToken(String notificationToken) {
    this.notificationToken = notificationToken;
  }

  String? getDocumentId() {
    return documentId;
  }

  void setDocumentId(String documentId) {
    this.documentId = documentId;
  }

  DateTime? getCreatedOn() {
    return createdOn;
  }

  void setCreatedOn(DateTime createdOn) {
    this.createdOn = createdOn;
  }

  String? getCreatedBy() {
    return createdBy;
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

  Map<String, Object?> toJson() {
    return {
      'type': type,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'organizationIdBabyBeat': organizationIdBabyBeat,
      'organizationNameBabyBeat': organizationNameBabyBeat,
      'name': name,
      'email': email,
      'mobileNo': mobileNo,
      'uid': uid,
      'notificationToken': notificationToken,
      'documentId': documentId,
      'delete': delete,
      'createdOn': createdOn,
      'createdBy': createdBy,
      'associations': associations,
      'babyBeatAssociation': babyBeatAssociation
    };
  }

  factory UserModel.fromJson(Map<String, Object> doc) {
    UserModel user = new UserModel.withData(
        type: doc['type'],
        organizationId: doc['organizationId'],
        organizationName: doc['organizationName'],
        organizationIdBabyBeat: doc['organizationIdBabyBeat'],
        organizationNameBabyBeat: doc['organizationNameBabyBeat'],
        name: doc['name'],
        email: doc['email'],
        mobileNo: doc['mobileNo'],
        uid: doc['uid'],
        notificationToken: doc['notificationToken'],
        documentId: doc['documentId'],
        delete: doc['delete'],
        createdOn: doc['createdOn'],
        createdBy: doc['createdBy'],
        associations: doc['associations'],
        babyBeatAssociation: doc['babyBeatAssociation']);
    return user;
  }

}
