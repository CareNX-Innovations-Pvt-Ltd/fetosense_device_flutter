// import 'package:url_launcher/url_launcher.dart';

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
}
