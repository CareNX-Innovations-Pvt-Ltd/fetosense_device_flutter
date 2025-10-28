/// A simple data class representing a range with start (`from`) and end (`to`) indices.
///
/// The `MarkerIndices` class is used to store and manage a pair of integer indices,
/// typically representing a segment or marker range in a dataset. It provides
/// constructors for default and parameterized initialization, as well as getter
/// and setter methods for both indices.
///
/// Example usage:
/// ```dart
/// final marker = MarkerIndices.fromData(10, 20);
/// print(marker.getFrom()); // 10
/// print(marker.getTo());   // 20
/// marker.setFrom(15);
/// marker.setTo(25);
///

class MarkerIndices {
  MarkerIndices() {}
  MarkerIndices.fromData(int from, int to) {
    this.from = from;
    this.to = to;
  }

  int? from;
  int? to;

  void setFrom(int from) {
    this.from = from;
  }

  int getFrom() {
    return from!;
  }

  int getTo() {
    return to!;
  }

  void setTo(int to) {
    this.to = to;
  }

}
