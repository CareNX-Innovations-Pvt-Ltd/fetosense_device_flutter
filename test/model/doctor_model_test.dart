import 'package:flutter_test/flutter_test.dart';
import 'package:fetosense_device_flutter/data/models/doctor_model.dart';

void main() {
  group('Doctor Model Tests', () {
    test('Default constructor initializes with 0 mothers and tests', () {
      final doctor = Doctor();
      expect(doctor.noOfMother, 0);
      expect(doctor.noOfTests, 0);
    });

    test('fromMap constructor initializes correctly', () {
      final Map<String, dynamic> data = {
        'noOfMother': 10,
        'noOfTests': 50,
        // Add other UserModel properties if needed for a complete test
      };
      final doctor = Doctor.fromMap(data, 'doctor123');

      expect(doctor.noOfMother, 10);
      expect(doctor.noOfTests, 50);
      // Add assertions for other UserModel properties if needed
    });

    test('fromMap constructor handles null values', () {
      final Map<String, dynamic> data = {
        'noOfMother': null,
        'noOfTests': null,
        // Add other UserModel properties with null if needed for a complete test
      };
      final doctor = Doctor.fromMap(data, 'doctor456');

      expect(doctor.noOfMother, null);
      expect(doctor.noOfTests, null);
      // Add assertions for other UserModel properties if needed
    });

    test('fromMap constructor handles missing values', () {
      final Map<String, dynamic> data = {
        // Missing noOfMother and noOfTests
        // Add other UserModel properties if needed for a complete test
      };
      final doctor = Doctor.fromMap(data, 'doctor789');

      expect(doctor.noOfMother, null);
      expect(doctor.noOfTests, null);
      // Add assertions for other UserModel properties if needed
    });
  });
}