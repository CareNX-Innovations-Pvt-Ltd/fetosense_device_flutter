import 'package:flutter_test/flutter_test.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('should have correct instantTest value', () {
      expect(AppConstants.instantTest, 'instant-test');
    });

    test('should have correct registeredMother value', () {
      expect(AppConstants.registeredMother, 'registered');
    });

    test('should have correct testRoute value', () {
      expect(AppConstants.testRoute, 'test-route');
    });

    test('should have correct homeRoute value', () {
      expect(AppConstants.homeRoute, 'home-route');
    });

    test('should have correct appwriteProjectId value', () {
      expect(AppConstants.appwriteProjectId, '684c18890002a74fff23');
    });

    test('should have correct appwriteEndpoint value', () {
      expect(AppConstants.appwriteEndpoint, 'http://20.6.93.31/v1');
    });

    test('should have correct appwriteDatabaseId value', () {
      expect(AppConstants.appwriteDatabaseId, '684c19ee00122a8eec2a');
    });

    test('should have correct userCollectionId value', () {
      expect(AppConstants.userCollectionId, '684c19fa00162a9cbc57');
    });

    test('should have correct deviceCollectionId value', () {
      expect(AppConstants.deviceCollectionId, '684c1a0200383bd0527c');
    });

    test('should have correct testsCollectionId value', () {
      expect(AppConstants.testsCollectionId, '684c1a13001f5e7a17c5');
    });

    test('should have correct defaultTestDurationKey value', () {
      expect(AppConstants.defaultTestDurationKey, 'defaultTestDurationKey');
    });

    test('should have correct emailKey value', () {
      expect(AppConstants.emailKey, 'emailKey');
    });

    test('should have correct defaultPrintScaleKey value', () {
      expect(AppConstants.defaultPrintScaleKey, 'scale');
    });
  });
}