import 'package:fetosense_device_flutter/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel Tests', () {
    test('UserModel.withData should create a user model with provided data', () {
      final user = UserModel.withData(
        name: 'Test User',
        email: 'test@example.com',
        mobileNo: 1234567890,
        organizationId: 'org123',
        organizationName: 'Test Org',
        age: 30,
        delete: false,
        createdBy: 'creator',
        deviceId: 'device123',
        deviceName: 'Test Device',
        doctorId: 'doctor123',
        doctorName: 'Dr. Test',
        amcLog: [1, 2, 3],
        amcPayment: 100,
        amcStartDate: '2023-01-01',
        amcValidity: '2024-01-01',
        appVersion: '1.0.0',
        associations: {'key': 'value'},
        bulletin: {'title': 'news'},
        deviceCode: 'code123',
        isActive: true,
        lastSeenTime: 'now',
        modifiedTimeStamp: 'then',
        noOfMother: 1,
        noOfTests: 5,
        sync: 1,
        testAccount: false,
        type: 'patient',
        uid: 'user123',
        weight: 70.5,
        patientId: 'patient123',
        platformId: 'platform123',
        platformRegAt: 'later',
      );

      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.mobileNo, 1234567890);
      expect(user.organizationId, 'org123');
      expect(user.organizationName, 'Test Org');
      expect(user.age, 30);
      expect(user.delete, false);
      expect(user.createdBy, 'creator');
      expect(user.deviceId, 'device123');
      expect(user.deviceName, 'Test Device');
      expect(user.doctorId, 'doctor123');
      expect(user.doctorName, 'Dr. Test');
      expect(user.amcLog, [1, 2, 3]);
      expect(user.amcPayment, 100);
      expect(user.amcStartDate, '2023-01-01');
      expect(user.amcValidity, '2024-01-01');
      expect(user.appVersion, '1.0.0');
      expect(user.associations, {'key': 'value'});
      expect(user.bulletin, {'title': 'news'});
      expect(user.deviceCode, 'code123');
      expect(user.isActive, true);
      expect(user.lastSeenTime, 'now');
      expect(user.modifiedTimeStamp, 'then');
      expect(user.noOfMother, 1);
      expect(user.noOfTests, 5);
      expect(user.sync, 1);
      expect(user.testAccount, false);
      expect(user.type, 'patient');
      expect(user.uid, 'user123');
      expect(user.weight, 70.5);
      expect(user.patientId, 'patient123');
      expect(user.platformId, 'platform123');
      expect(user.platformRegAt, 'later');
    });

    test('UserModel.fromMap should create a user model from a map', () {
      final Map<String, dynamic> userData = {
        'type': 'patient',
        'organizationId': 'org123',
        'organizationName': 'Test Org',
        'name': 'Test User',
        'email': 'test@example.com',
        'mobileNo': 1234567890,
        'uid': 'user123',
        'delete': false,
        'createdOn': null,
        'createdBy': 'creator',
        'associations': '{"key": "value"}',
        'bulletin': '{"title": "news"}',
        'age': 30,
        'autoModifiedTimeStamp': null,
        'deviceId': 'device123',
        'deviceName': 'Test Device',
        'doctorId': 'doctor123',
        'doctorName': 'Dr. Test',
        'amcLog': [1, 2, 3],
        'amcPayment': 100,
        'amcStartDate': '2023-01-01',
        'amcValidity': '2024-01-01',
        'appVersion': '1.0.0',
        'deviceCode': 'code123',
        'isActive': true,
        'lastSeenTime': 'now',
        'modifiedAt': null,
        'modifiedTimeStamp': 'then',
        'noOfMother': 1,
        'noOfTests': 5,
        'sync': 1,
        'testAccount': false,
        'weight': 70.5,
        'patientId': 'patient123',
        'platformId': 'platform123',
        'platformRegAt': 'later',
      };

      final user = UserModel.fromMap(userData, 'user123');

      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.mobileNo, 1234567890);
      expect(user.organizationId, 'org123');
      expect(user.organizationName, 'Test Org');
      expect(user.age, 30);
      expect(user.delete, false);
      expect(user.createdBy, 'creator');
      expect(user.deviceId, 'device123');
      expect(user.deviceName, 'Test Device');
      expect(user.doctorId, 'doctor123');
      expect(user.doctorName, 'Dr. Test');
      expect(user.amcLog, [1, 2, 3]);
      expect(user.amcPayment, 100);
      expect(user.amcStartDate, '2023-01-01');
      expect(user.amcValidity, '2024-01-01');
      expect(user.appVersion, '1.0.0');
      expect(user.associations, {'key': 'value'});
      expect(user.bulletin, {'title': 'news'});
      expect(user.deviceCode, 'code123');
      expect(user.isActive, true);
      expect(user.lastSeenTime, 'now');
      expect(user.modifiedTimeStamp, 'then');
      expect(user.noOfMother, 1);
      expect(user.noOfTests, 5);
      expect(user.sync, 1);
      expect(user.testAccount, false);
      expect(user.type, 'patient');
      expect(user.uid, 'user123');
      expect(user.weight, 70.5);
      expect(user.patientId, 'patient123');
      expect(user.platformId, 'platform123');
      expect(user.platformRegAt, 'later');
    });

    test('UserModel.toJson should convert a user model to a map', () {
      final user = UserModel.withData(
        name: 'Test User',
        email: 'test@example.com',
        mobileNo: 1234567890,
        organizationId: 'org123',
        organizationName: 'Test Org',
        age: 30,
        delete: false,
        createdBy: 'creator',
        deviceId: 'device123',
        deviceName: 'Test Device',
        doctorId: 'doctor123',
        doctorName: 'Dr. Test',
        amcLog: [1, 2, 3],
        amcPayment: 100,
        amcStartDate: '2023-01-01',
        amcValidity: '2024-01-01',
        appVersion: '1.0.0',
        associations: {'key': 'value'},
        bulletin: {'title': 'news'},
        deviceCode: 'code123',
        isActive: true,
        lastSeenTime: 'now',
        modifiedTimeStamp: 'then',
        noOfMother: 1,
        noOfTests: 5,
        sync: 1,
        testAccount: false,
        type: 'patient',
        uid: 'user123',
        weight: 70.5,
        patientId: 'patient123',
        platformId: 'platform123',
        platformRegAt: 'later',
      );

      final json = user.toJson();

      expect(json['name'], 'Test User');
      expect(json['email'], 'test@example.com');
      expect(json['mobileNo'], 1234567890);
      expect(json['organizationId'], 'org123');
      expect(json['organizationName'], 'Test Org');
      expect(json['age'], 30);
      expect(json['delete'], false);
      expect(json['createdBy'], 'creator');
      expect(json['deviceId'], 'device123');
      expect(json['deviceName'], 'Test Device');
      expect(json['doctorId'], 'doctor123');
      expect(json['doctorName'], 'Dr. Test');
      expect(json['amcLog'], [1, 2, 3]);
      expect(json['amcPayment'], 100);
      expect(json['amcStartDate'], '2023-01-01');
      expect(json['amcValidity'], '2024-01-01');
      expect(json['appVersion'], '1.0.0');
      expect(json['associations'], '{"key":"value"}');
      expect(json['bulletin'], '{"title":"news"}');
      expect(json['deviceCode'], 'code123');
      expect(json['isActive'], true);
      expect(json['lastSeenTime'], 'now');
      expect(json['modifiedTimeStamp'], 'then');
      expect(json['noOfMother'], 1);
      expect(json['noOfTests'], 5);
      expect(json['sync'], 1);
      expect(json['testAccount'], false);
      expect(json['type'], 'patient');
      expect(json['uid'], 'user123');
      expect(json['weight'], 70.5);
      expect(json['patientId'], 'patient123');
      expect(json['platformId'], 'platform123');
      expect(json['platformRegAt'], 'later');
    });

    test('UserModel.fromJson should create a user model from a json map', () {
      final Map<String, dynamic> json = {
        'type': 'patient',
        'organizationId': 'org123',
        'organizationName': 'Test Org',
        'name': 'Test User',
        'email': 'test@example.com',
        'mobileNo': 1234567890,
        'uid': 'user123',
        'delete': false,
        'createdOn': null,
        'createdBy': 'creator',
        'associations': '{"key": "value"}',
        'bulletin': '{"title": "news"}',
        'age': 30,
        'autoModifiedTimeStamp': null,
        'deviceId': 'device123',
        'deviceName': 'Test Device',
        'doctorId': 'doctor123',
        'doctorName': 'Dr. Test',
        'amcLog': [1, 2, 3],
        'amcPayment': 100,
        'amcStartDate': '2023-01-01',
        'amcValidity': '2024-01-01',
        'appVersion': '1.0.0',
        'deviceCode': 'code123',
        'isActive': true,
        'lastSeenTime': 'now',
        'modifiedAt': null,
        'modifiedTimeStamp': 'then',
        'noOfMother': 1,
        'noOfTests': 5,
        'sync': 1,
        'testAccount': false,
        'weight': 70.5,
        'patientId': 'patient123',
        'platformId': 'platform123',
        'platformRegAt': 'later',
      };

      final user = UserModel.fromJson(json);

      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.mobileNo, 1234567890);
      expect(user.organizationId, 'org123');
      expect(user.organizationName, 'Test Org');
      expect(user.age, 30);
      expect(user.delete, false);
      expect(user.createdBy, 'creator');
      expect(user.deviceId, 'device123');
      expect(user.deviceName, 'Test Device');
      expect(user.doctorId, 'doctor123');
      expect(user.doctorName, 'Dr. Test');
      expect(user.amcLog, [1, 2, 3]);
      expect(user.amcPayment, 100);
      expect(user.amcStartDate, '2023-01-01');
      expect(user.amcValidity, '2024-01-01');
      expect(user.appVersion, '1.0.0');
      expect(user.associations, {'key': 'value'});
      expect(user.bulletin, {'title': 'news'});
      expect(user.deviceCode, 'code123');
      expect(user.isActive, true);
      expect(user.lastSeenTime, 'now');
      expect(user.modifiedTimeStamp, 'then');
      expect(user.noOfMother, 1);
      expect(user.noOfTests, 5);
      expect(user.sync, 1);
      expect(user.testAccount, false);
      expect(user.type, 'patient');
      expect(user.uid, 'user123');
      expect(user.weight, 70.5);
      expect(user.patientId, 'patient123');
      expect(user.platformId, 'platform123');
      expect(user.platformRegAt, 'later');
    });
  });
}