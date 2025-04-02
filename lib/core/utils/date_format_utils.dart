import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Extension on DateTime to provide additional formatting utilities.
extension DateTimeExtension on DateTime {
  /// Formats the DateTime instance to a string based on the provided [pattern] and [locale].
  ///
  /// [pattern] - The date format pattern. Defaults to 'dd/MM/yyyy'.
  /// [locale] - The locale to use for formatting. Optional.
  ///
  /// Returns the formatted date as a [String].
  String format([String pattern = 'dd/MM/yyyy', String? locale]) {
    if (locale != null && locale.isNotEmpty) {
      initializeDateFormatting(locale);
    }
    return DateFormat(pattern, locale).format(this);
  }

  /// Gets the month of the DateTime instance as a string based on the provided [pattern] and [locale].
  ///
  /// [pattern] - The date format pattern for the month. Defaults to 'MMMM'.
  /// [locale] - The locale to use for formatting. Optional.
  ///
  /// Returns the month as a [String].
  String getMonth([String pattern = 'MMMM', String? locale]) {
    if (locale != null && locale.isNotEmpty) {
      initializeDateFormatting(locale);
    }
    return DateFormat(pattern, locale).format(this);
  }

  /// Gets the date of the DateTime instance as a string based on the provided [pattern] and [locale].
  ///
  /// [pattern] - The date format pattern for the date. Defaults to 'dd'.
  /// [locale] - The locale to use for formatting. Optional.
  ///
  /// Returns the date as a [String].
  String getDate([String pattern = 'dd', String? locale]) {
    if (locale != null && locale.isNotEmpty) {
      initializeDateFormatting(locale);
    }
    return DateFormat(pattern, locale).format(this);
  }

  /// Gets the day of the week of the DateTime instance as a string based on the provided [pattern] and [locale].
  ///
  /// [pattern] - The date format pattern for the day. Defaults to 'EEEE'.
  /// [locale] - The locale to use for formatting. Optional.
  ///
  /// Returns the day of the week as a [String].
  String getDay([String pattern = 'EEEE', String? locale]) {
    if (locale != null && locale.isNotEmpty) {
      initializeDateFormatting(locale);
    }
    return DateFormat(pattern, locale).format(this).toString().substring(0, 3);
  }

  /// Calculates the age based on the DateTime instance.
  ///
  /// Returns the age as an [int].
  int getAge() {
    DateTime endDate = DateTime.now();
    // '${(endDate.difference(DateTime.fromMillisecondsSinceEpoch(details['dateOfBirth'].seconds * 1000)).inDays ~/ 365)}',
    return ((endDate.year - year) * 12 + (endDate.month - month) + 1) ~/ 12;
  }

  /// Calculates the gestational age in weeks based on the DateTime instance.
  ///
  /// Returns the gestational age as an [int].
  int getGestAge() {
    final currentDate = DateTime.now();
    final differenceInDays = currentDate.difference(this).inDays;
    final weeksPassed = (differenceInDays / 7).floor(); // Calculate weeks
    return weeksPassed;
  }
}
