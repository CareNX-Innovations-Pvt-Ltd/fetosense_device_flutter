import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:fetosense_device_flutter/core/utils/date_format_utils.dart';

void main() {
  group('DateTimeExtension', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2023, 10, 15); // Example date
    });

    test('format should return formatted date', () {
      expect(testDate.format('dd/MM/yyyy'), '15/10/2023');
      expect(testDate.format('yyyy-MM-dd'), '2023-10-15');
    });

    test('getMonth should return month name', () {
      expect(testDate.getMonth(), 'October');
      expect(testDate.getMonth('MMM'), 'Oct');
    });

    test('getDate should return day of the month', () {
      expect(testDate.getDate(), '15');
    });

    test('getDay should return day of the week abbreviation', () {
      expect(testDate.getDay(), 'Sun');
    });

    test('getAge should calculate correct age', () {
      final birthDate = DateTime(2000, 10, 15);
      expect(birthDate.getAge(), 24); // Assuming current year is 2023
    });

    test('getGestAge should calculate correct gestational age in weeks', () {
      final conceptionDate = DateTime(2023, 1, 1);
      expect(conceptionDate.getGestAge(), 133); // Assuming current date is 2023-10-15
    });
  });
}