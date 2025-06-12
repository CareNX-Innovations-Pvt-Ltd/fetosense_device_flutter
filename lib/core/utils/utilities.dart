// import 'package:url_launcher/url_launcher.dart';

/// A utility class providing helper methods for common app functionalities.
///
/// This class includes static methods for:
/// - Launching phone dialer and email apps (currently commented out)
/// - Calculating gestational age in weeks from the last menstrual period
/// - Estimating the last menstrual period from gestational age in weeks
/// - Initializing screen size configuration using [ScreenUtil]
///
/// Example usage:
/// ```dart
/// int weeks = Utilities.getGestationalAgeWeeks(lmpDate);
/// DateTime lmp = Utilities.getLmpFromGestationalAgeWeeks(gestationalWeeks);
/// Utilities().setScreenUtil(context, width: 360, height: 690);
/// ```

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
 class Utilities {
  static launchPhone(String phone) async {
    // final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    // if ( await canLaunchUrl(phoneUri)) {
    //   await launchUrl(phoneUri);
    // }
  }

  static launchEmail(String email) async {
    // final Uri emailUri = Uri(scheme: 'mailto', path: email);
    // if (await canLaunchUrl(emailUri)) {
    //   await launchUrl(emailUri);
    // }
  }

  void setScreenUtil(BuildContext context, {double? width, double? height}) {
    ScreenUtil.init(context,designSize:Size(width!,height!));
  }

 static int getGestationalAgeWeeks(DateTime lastMenstrualPeriod) {
   DateTime today = DateTime.now();
   return (today.difference(lastMenstrualPeriod).inDays / 7).floor();
  }

  static DateTime getLmpFromGestationalAgeWeeks(int gestationalAgeWeeks) {
    DateTime today = DateTime.now();
    return today.subtract(Duration(days: gestationalAgeWeeks * 7));
  }

 }
