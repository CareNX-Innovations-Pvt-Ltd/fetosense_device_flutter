import 'package:fetosense_device_flutter/core/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  @override
  Widget build(BuildContext context) {
    Utilities().setScreenUtil(
      context,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
    );
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            const Icon(
              Icons.notifications_active_outlined,
              size: 70,
            ),
            Text(
              'No notifications yet.',
              style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.bold),
            ),
            Text(
              'We\'ll keep you posted.',
              style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ));
  }
}
