import 'package:fetosense_device_flutter/core/utils/date_format_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeExtension', () {
    final date = DateTime(2020, 5, 15);

    test('format without locale', () {
      final result = date.format('yyyy-MM-dd');
      expect(result, '2020-05-15');
    });

    test('format with locale', () async {
      final result = date.format('dd MMMM yyyy', 'en_US');
      expect(result.contains('2020'), true);
    });

    test('getMonth without locale', () {
      final result = date.getMonth('MMM');
      expect(result.length, 3);
    });

    test('getMonth with locale', () async {
      final result = date.getMonth('MMMM', 'en_US');
      expect(result.isNotEmpty, true);
    });

    test('getDate without locale', () {
      final result = date.getDate('dd');
      expect(result, '15');
    });

    test('getDate with locale', () async {
      final result = date.getDate('dd', 'en_US');
      expect(result, '15');
    });

    test('getDay without locale', () {
      final result = date.getDay('EEEE');
      expect(result.length, 3);
    });

    test('getDay with locale', () async {
      final result = date.getDay('EEEE', 'en_US');
      expect(result.length, 3);
    });

    test('getAge calculation', () {
      final current = DateTime.now();
      final date = DateTime(current.year - 30, current.month, current.day);
      final age = date.getAge();
      expect(age, greaterThanOrEqualTo(30));
    });

    test('getGestAge calculation', () {
      final past = DateTime.now().subtract(const Duration(days: 50));
      final gestAge = past.getGestAge();
      expect(gestAge, (50 / 7).floor());
    });
  });
}
