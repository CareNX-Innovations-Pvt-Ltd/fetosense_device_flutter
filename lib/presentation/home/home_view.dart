import 'package:fetosense_device_flutter/core/constants/app_routes.dart';
import 'package:fetosense_device_flutter/core/utils/color_manager.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/network/dependency_injection.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ServiceLocator.bluetoothServiceHelper.disconnect();
    ServiceLocator.bluetoothServiceHelper.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorManager.white,
        appBar: AppBar(
          title: const Text(
            'Fetosense',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.push(AppRoutes.allMothersView);
              },
              child: const Text(
                "All Mothers",
                style: TextStyle(
                  fontSize: 17,
                  color: ColorManager.primaryButtonColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            IconButton(
              onPressed: () {
                context.push(AppRoutes.notificationView);
              },
              icon: const Icon(Icons.notifications),
            ),
            IconButton(
              onPressed: () {
                context.push(AppRoutes.appSettingsView);
              },
              icon: const Icon(Icons.settings),
            ),
            PopupMenuButton<String>(
              color: ColorManager.white,
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (kDebugMode) {
                  print("Selected: $value");
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: "Option 1",
                  child: const Text("About"),
                  onTap: () {
                    context.push(AppRoutes.aboutView);
                  },
                ),
                PopupMenuItem(
                  value: "Option 3",
                  child: const Text("Sign Out"),
                  onTap: () {
                    GetIt.I<PreferenceHelper>().removeUser();
                    GetIt.I<PreferenceHelper>().setAutoLogin(false);
                    context.pushReplacement(AppRoutes.login);
                  },
                ),
              ],
            ),
          ],
        ),
        body: Center(
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'search',
                  child: Material(
                    child: TextField(
                      onTap: () {
                        context.push(AppRoutes.allMothersView, extra: true);
                      },
                      controller: textEditingController,
                      decoration: InputDecoration(
                        hintText: "Search for mother's name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            context.pushNamed(AppRoutes.dopplerConnectionView,
                                extra: {
                                  'test': Test(),
                                  'route': AppConstants.instantTest
                                });
                          },
                        text: 'START INSTANT TEST ',
                        style: const TextStyle(
                          color: ColorManager.primaryButtonColor,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const WidgetSpan(
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: ColorManager.primaryButtonColor,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            context.pushNamed(AppRoutes.registerMother, extra: {
                              'test': Test(),
                              'route': AppConstants.homeRoute
                            });
                          },
                        text: 'CLICK HERE TO REGISTER NEW MOTHER ',
                        style: const TextStyle(
                          color: ColorManager.primaryButtonColor,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const WidgetSpan(
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: ColorManager.primaryButtonColor,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: Image.asset('assets/whatsapp.PNG'),
              ),
              const SizedBox(
                width: 8,
              ),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'For queries chat with us on ',
                      style: TextStyle(
                        fontSize: 15,
                        color: ColorManager.primaryButtonColor,
                      ),
                    ),
                    TextSpan(
                      text: '+91 9326775598',
                      style: TextStyle(
                        color: Colors.blue,
                        // decoration: TextDecoration.underline,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: ' you can even give us a call.',
                      style: TextStyle(
                        fontSize: 15,
                        color: ColorManager.primaryButtonColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  OverlayEntry? _overlayEntry;

  void _toggleMenu(BuildContext context, GlobalKey key) {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry(context, key);
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  OverlayEntry _createOverlayEntry(BuildContext context, GlobalKey key) {
    RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    Offset position = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _toggleMenu(context, key);
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            top: position.dy + renderBox.size.height,
            right: 16,
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text("Option 1"),
                      onTap: () {},
                    ),
                    ListTile(
                      title: const Text("Option 2"),
                      onTap: () {},
                    ),
                    ListTile(
                      title: const Text("Option 3"),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
