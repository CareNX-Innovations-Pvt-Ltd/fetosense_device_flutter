import 'package:flutter_test/flutter_test.dart';
import 'package:fetosense_device_flutter/data/models/mother_model.dart';
import 'package:fetosense_device_flutter/data/models/user_model.dart';

void main() {
  group('Mother Model Tests', () {
    test('should create a Mother object using the default constructor', () {
      final mother = Mother();
      expect(mother, isA<Mother>());
      expect(mother, isA<UserModel>());
      expect(mother.lmp, isNull);
      expect(mother.edd, isNull);
      expect(mother.documentId, isNull);
    });

    test('should create a Mother object from JSON', () {
      final json = {
        'name': 'Test Mother',
        'age': 30,
        'lmp': '2023-10-26T00:00:00.000Z',
        'deviceId': 'device123',
        'deviceName': 'Device Name',
        'type': 'Mother',
        'noOfTests': 5,
        'documentId': 'doc456',
      };
      final mother = Mother.fromJson(json);

      expect(mother.name, 'Test Mother');
      expect(mother.age, 30);
      expect(mother.lmp, DateTime.parse('2023-10-26T00:00:00.000Z'));
      expect(mother.deviceId, 'device123');
      expect(mother.deviceName, 'Device Name');
      expect(mother.type, 'Mother');
      expect(mother.noOfTests, 5);
      expect(mother.documentId, 'doc456');
    });

    test('should create a Mother object from JSON with nullable fields missing', () {
      final json = {
        'name': 'Test Mother',
        'age': 30,
        'deviceId': 'device123',
        'deviceName': 'Device Name',
        'type': 'Mother',
        'noOfTests': 5,
      };
      final mother = Mother.fromJson(json);

      expect(mother.name, 'Test Mother');
      expect(mother.age, 30);
      expect(mother.lmp, isNull);
      expect(mother.deviceId, 'device123');
      expect(mother.deviceName, 'Device Name');
      expect(mother.type, 'Mother');
      expect(mother.noOfTests, 5);
      expect(mother.documentId, isNull);
    });

    test('should convert a Mother object to JSON', () {
      final mother = Mother()
        ..name = 'Test Mother'
        ..age = 30
        ..lmp = DateTime.parse('2023-10-26T00:00:00.000Z')
        ..edd = DateTime.parse('2024-07-26T00:00:00.000Z')
        ..deviceId = 'device123'
        ..deviceName = 'Device Name'
        ..type = 'Mother'
        ..noOfTests = 5
        ..documentId = 'doc456';

      final json = mother.toJson();

      expect(json['name'], 'Test Mother');
      expect(json['age'], 30);
      expect(json['lmp'], '2023-10-26T00:00:00.000Z');
      expect(json['edd'], '2024-07-26T00:00:00.000Z');
      expect(json['deviceId'], 'device123');
      expect(json['deviceName'], 'Device Name');
      expect(json['type'], 'Mother');
      expect(json['noOfTests'], 5);
      expect(json['documentId'], 'doc456');
    });

    test('should convert a Mother object to JSON with nullable fields being null', () {
      final mother = Mother()
        ..name = 'Test Mother'
        ..age = 30
        ..deviceId = 'device123'
        ..deviceName = 'Device Name'
        ..type = 'Mother'
        ..noOfTests = 5;

      final json = mother.toJson();

      expect(json['name'], 'Test Mother');
      expect(json['age'], 30);
      expect(json['lmp'], isNull);
      expect(json['edd'], isNull);
      expect(json['deviceId'], 'device123');
      expect(json['deviceName'], 'Device Name');
      expect(json['type'], 'Mother');
      expect(json['noOfTests'], 5);
      expect(json['documentId'], isNull);
    });
  });
}