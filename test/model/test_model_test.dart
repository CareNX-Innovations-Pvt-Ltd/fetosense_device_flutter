import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test Model Tests', () {
    test('Test.withData constructor', () {
      final testModel = Test.withData(
        id: '1',
        documentId: 'doc1',
        motherId: 'm1',
        deviceId: 'd1',
        doctorId: 'doc1',
        weight: 70,
        gAge: 30,
        age: 25,
        fisherScore: 5,
        fisherScore2: 7,
        motherName: 'Mother 1',
        deviceName: 'Device 1',
        doctorName: 'Doctor 1',
        patientId: 'p1',
        organizationId: 'o1',
        organizationName: 'Org 1',
        bpmEntries: [120, 130, 140],
        bpmEntries2: [125, 135, 145],
        baseLineEntries: [130, 130, 130],
        movementEntries: [1, 0, 1],
        autoFetalMovement: [0, 1, 1],
        tocoEntries: [10, 20, 30],
        lengthOfTest: 20,
        averageFHR: 135,
        live: true,
        testByMother: false,
        testById: 'tester1',
        interpretationType: 'Type A',
        interpretationExtraComments: 'Comments',
        associations: {'key': 'value'},
        autoInterpretations: {'key2': 'value2'},
        delete: false,
        createdOn: DateTime(2023, 1, 1),
        createdBy: 'user1',
      );

      expect(testModel.id, '1');
      expect(testModel.documentId, 'doc1');
      expect(testModel.motherId, 'm1');
      expect(testModel.deviceId, 'd1');
      expect(testModel.doctorId, 'doc1');
      expect(testModel.weight, 70);
      expect(testModel.gAge, 30);
      expect(testModel.age, 25);
      expect(testModel.fisherScore, 5);
      expect(testModel.fisherScore2, 7);
      expect(testModel.motherName, 'Mother 1');
      expect(testModel.deviceName, 'Device 1');
      expect(testModel.doctorName, 'Doctor 1');
      expect(testModel.patientId, 'p1');
      expect(testModel.organizationId, 'o1');
      expect(testModel.organizationName, 'Org 1');
      expect(testModel.bpmEntries, [120, 130, 140]);
      expect(testModel.bpmEntries2, [125, 135, 145]);
      expect(testModel.baseLineEntries, [130, 130, 130]);
      expect(testModel.movementEntries, [1, 0, 1]);
      expect(testModel.autoFetalMovement, [0, 1, 1]);
      expect(testModel.tocoEntries, [10, 20, 30]);
      expect(testModel.lengthOfTest, 20);
      expect(testModel.averageFHR, 135);
      expect(testModel.live, true);
      expect(testModel.testByMother, false);
      expect(testModel.testById, 'tester1');
      expect(testModel.interpretationType, 'Type A');
      expect(testModel.interpretationExtraComments, 'Comments');
      expect(testModel.associations, {'key': 'value'});
      expect(testModel.autoInterpretations, {'key2': 'value2'});
      expect(testModel.delete, false);
      expect(testModel.createdOn, DateTime(2023, 1, 1));
      expect(testModel.createdBy, 'user1');
    });

    test('Test.fromMap factory method', () {
      final Map<String, dynamic> testMap = {
        'id': '1',
        'documentId': 'doc1',
        'motherId': 'm1',
        'deviceId': 'd1',
        'doctorId': 'doc1',
        'weight': 70,
        'gAge': 30,
        'age': 25,
        'fisherScore': 5,
        'fisherScore2': 7,
        'motherName': 'Mother 1',
        'deviceName': 'Device 1',
        'doctorName': 'Doctor 1',
        'patientId': 'p1',
        'organizationId': 'o1',
        'organizationName': 'Org 1',
        'bpmEntries': [120, 130, 140],
        'bpmEntries2': [125, 135, 145],
        'mhrEntries': [80, 90, 100],
        'spo2Entries': [95, 96, 97],
        'baseLineEntries': [130, 130, 130],
        'movementEntries': [1, 0, 1],
        'autoFetalMovement': [0, 1, 1],
        'tocoEntries': [10, 20, 30],
        'lengthOfTest': 20,
        'averageFHR': 135,
        'live': true,
        'testByMother': false,
        'testById': 'tester1',
        'interpretationType': 'Type A',
        'interpretationExtraComments': 'Comments',
        'association': '{"key":"value"}',
        'autoInterpretations': '{"key2":"value2"}',
        'delete': false,
        'createdOn': '2023-01-01T00:00:00.000Z',
        'createdBy': 'user1',
      };

      final testModel = Test.fromMap(testMap, '1');

      expect(testModel.id, '1');
      expect(testModel.documentId, 'doc1');
      expect(testModel.motherId, 'm1');
      expect(testModel.deviceId, 'd1');
      expect(testModel.doctorId, 'doc1');
      expect(testModel.weight, 70);
      expect(testModel.gAge, 30);
      expect(testModel.age, 25);
      expect(testModel.fisherScore, 5);
      expect(testModel.fisherScore2, 7);
      expect(testModel.motherName, 'Mother 1');
      expect(testModel.deviceName, 'Device 1');
      expect(testModel.doctorName, 'Doctor 1');
      expect(testModel.patientId, 'p1');
      expect(testModel.organizationId, 'o1');
      expect(testModel.organizationName, 'Org 1');
      expect(testModel.bpmEntries, [120, 130, 140]);
      expect(testModel.bpmEntries2, [125, 135, 145]);
      expect(testModel.mhrEntries, [80, 90, 100]);
      expect(testModel.spo2Entries, [95, 96, 97]);
      expect(testModel.baseLineEntries, [130, 130, 130]);
      expect(testModel.movementEntries, [1, 0, 1]);
      expect(testModel.autoFetalMovement, [0, 1, 1]);
      expect(testModel.tocoEntries, [10, 20, 30]);
      expect(testModel.lengthOfTest, 20);
      expect(testModel.averageFHR, 135);
      expect(testModel.live, true);
      expect(testModel.testByMother, false);
      expect(testModel.testById, 'tester1');
      expect(testModel.interpretationType, 'Type A');
      expect(testModel.interpretationExtraComments, 'Comments');
      expect(testModel.associations, {'key': 'value'});
      expect(testModel.autoInterpretations, {'key2': 'value2'});
      expect(testModel.delete, false);
      expect(testModel.createdOn, DateTime.parse('2023-01-01T00:00:00.000Z'));
      expect(testModel.createdBy, 'user1');
    });

    test('toJson method', () {
      final testModel = Test.withData(
        id: '1',
        documentId: 'doc1',
        motherId: 'm1',
        deviceId: 'd1',
        doctorId: 'doc1',
        weight: 70,
        gAge: 30,
        age: 25,
        fisherScore: 5,
        fisherScore2: 7,
        motherName: 'Mother 1',
        deviceName: 'Device 1',
        doctorName: 'Doctor 1',
        patientId: 'p1',
        organizationId: 'o1',
        organizationName: 'Org 1',
        bpmEntries: [120, 130, 140],
        bpmEntries2: [125, 135, 145],
        baseLineEntries: [130, 130, 130],
        movementEntries: [1, 0, 1],
        autoFetalMovement: [0, 1, 1],
        tocoEntries: [10, 20, 30],
        lengthOfTest: 20,
        averageFHR: 135,
        live: true,
        testByMother: false,
        testById: 'tester1',
        interpretationType: 'Type A',
        interpretationExtraComments: 'Comments',
        associations: {'key': 'value'},
        autoInterpretations: {'key2': 'value2'},
        delete: false,
        createdOn: DateTime(2023, 1, 1, 0, 0, 0, 0, 0),
        createdBy: 'user1',
      );

      final json = testModel.toJson();

      expect(json['documentId'], 'doc1');
      expect(json['motherId'], 'm1');
      expect(json['deviceId'], 'd1');
      expect(json['doctorId'], 'doc1');
      expect(json['weight'], 70);
      expect(json['gAge'], 30);
      // expect(json['age'], 25);
      expect(json['fisherScore'], 5);
      expect(json['fisherScore2'], 7);
      expect(json['motherName'], 'Mother 1');
      expect(json['deviceName'], 'Device 1');
      expect(json['doctorName'], 'Doctor 1');
      expect(json['patientId'], 'p1');
      expect(json['organizationId'], 'o1');
      expect(json['organizationName'], 'Org 1');
      expect(json['bpmEntries'], [120, 130, 140]);
      expect(json['bpmEntries2'], [125, 135, 145]);
      expect(json['baseLineEntries'], [130, 130, 130]);
      expect(json['movementEntries'], [1, 0, 1]);
      expect(json['autoFetalMovement'], [0, 1, 1]);
      expect(json['tocoEntries'], [10, 20, 30]);
      expect(json['lengthOfTest'], 20);
      expect(json['averageFHR'], 135);
      expect(json['live'], true);
      expect(json['testByMother'], false);
      expect(json['testById'], 'tester1');
      expect(json['interpretationType'], 'Type A');
      expect(json['interpretationExtraComments'], 'Comments');
      expect(json['association'], '{"key":"value"}');
      expect(json['autoInterpretations'], '{"key2":"value2"}');
      expect(json['delete'], false);
      expect(json['createdOn'], DateTime(2023, 1, 1).toIso8601String());
      expect(json['createdBy'], 'user1');
    });
  });
}