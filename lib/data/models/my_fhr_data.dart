
/// A data model representing fetal heart rate (FHR) and related monitoring values.
///
/// The `MyFhrData` class stores real-time readings from a fetal monitoring device,
/// including FHR channels, uterine contraction (toco), fetal movement (afm, fm),
/// signal quality flags, and device status indicators.
///
/// Example usage:
/// ```dart
/// final data = MyFhrData();
/// data.fhr1 = 140;
/// data.toco = 20;
/// print(data.fhrSignal);
/// ```

class MyFhrData {
  int fhr1 = 0;
  int fhr2 = 0;
  int toco = 0;
  int afm = 0;
  int fhrSignal = 0;
  int afmFlag = 0;
  int fmFlag = 0;
  int tocoFlag = 0;
  int docFlag = 0;
  int devicePower = 0;
  int isHaveFhr1 = 0;
  int isHaveFhr2 = 0;
  int isHaveToco = 0;
  int isHaveAfm = 0;

  MyFhrData();
}
