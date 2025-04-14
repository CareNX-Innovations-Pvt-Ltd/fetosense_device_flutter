import 'package:fetosense_device_flutter/core/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    Utilities().setScreenUtil(
      context,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
    );
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('About'),
          leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Center(
              child: Image.asset(
                'assets/splash.jpg',
                height: 0.4.sw,
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Privacy Policy', style: TextStyle(fontSize: 18),),
                Text('Terms & Conditions', style: TextStyle(fontSize: 18),),
                Text('Website', style: TextStyle(fontSize: 18),),
                Text('Contact Us', style: TextStyle(fontSize: 18),),
              ],
            )
          ],
        ),
      ),
    );
  }
}
