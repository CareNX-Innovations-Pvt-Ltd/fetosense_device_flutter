import 'package:fetosense_device_flutter/core/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// A stateless widget that displays the About page of the application.
///
/// The `AboutView` widget presents information about the app, including a logo image
/// and quick links such as Privacy Policy, Terms & Conditions, Website, and Contact Us.
/// It uses a responsive layout with `ScreenUtil` for scaling and provides a back button
/// in the app bar to return to the previous screen.
///
/// Example usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutView()));
/// ```

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
            const Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              children: [
                Text('Privacy Policy', style: TextStyle(fontSize: 18)),
                Text('Terms & Conditions', style: TextStyle(fontSize: 18)),
                Text('Website', style: TextStyle(fontSize: 18)),
                Text('Contact Us', style: TextStyle(fontSize: 18)),
              ],
            )

          ],
        ),
      ),
    );
  }
}
