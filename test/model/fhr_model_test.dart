import 'package:fetosense_device_flutter/data/models/my_fhr_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MyFhrData', () {
    test('should have default values', () {
      final data = MyFhrData();
      expect(data.fhr1, 0);
      expect(data.fhr2, 0);
      expect(data.toco, 0);
      expect(data.afm, 0);
      expect(data.fhrSignal, 0);
      expect(data.afmFlag, 0);
      expect(data.fmFlag, 0);
      expect(data.tocoFlag, 0);
      expect(data.docFlag, 0);
      expect(data.devicePower, 0);
      expect(data.isHaveFhr1, 0);
      expect(data.isHaveFhr2, 0);
      expect(data.isHaveToco, 0);
      expect(data.isHaveAfm, 0);
    });
  });
}