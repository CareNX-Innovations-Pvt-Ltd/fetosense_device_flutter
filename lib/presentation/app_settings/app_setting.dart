import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/utils/color_manager.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/core/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:preferences/preferences.dart';

/// A stateful widget that displays the application settings page.
///
/// The `AppSetting` widget provides a user interface for configuring various
/// preferences such as test duration, FHR alerts, patient ID, Fisher Score,
/// printing options, and more. It uses preference dialogs and switches to
/// allow users to customize the app's behavior and appearance. Changes are
/// persisted using the `PreferenceHelper`.
///
/// Example usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(builder: (_) => const AppSetting()));
/// ```

class AppSetting extends StatefulWidget {
  const AppSetting({super.key});

  @override
  State<AppSetting> createState() => _AppSettingState();
}

class _AppSettingState extends State<AppSetting> {
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
          title: const Text(
            'Settings',
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Colors.black87),
          ),
          leading: IconButton(
            iconSize: 35,
            icon: const Icon(
              Icons.arrow_back,
              size: 30,
              color: Colors.teal,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        backgroundColor: ColorManager.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/tests.jpg',
                      scale: 10,
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(
                      'Test',
                      style: TextStyle(fontSize: 20.sp),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                PreferenceDialogLink(
                  'Default test duration',
                  desc: GetIt.I<PreferenceHelper>().getString(AppConstants.defaultTestDurationKey) ?? '20 min',
                  dialog: PreferenceDialog(
                    [
                      RadioPreference(
                        '10 min',
                        '10 min',
                        AppConstants.defaultTestDurationKey,
                        onSelect: () => setState(() {
                          GetIt.I<PreferenceHelper>().setString(
                              AppConstants.defaultTestDurationKey, '10 min');
                        }),
                      ),
                      RadioPreference(
                        '20 min',
                        '20 min',
                        AppConstants.defaultTestDurationKey,
                        selected: true,
                        onSelect: () => setState(() {
                          GetIt.I<PreferenceHelper>().setString(
                              AppConstants.defaultTestDurationKey, '20 min');
                        }),
                      ),
                      RadioPreference(
                        '30 min',
                        '30 min',
                        AppConstants.defaultTestDurationKey,
                        onSelect: () => setState(() {
                          GetIt.I<PreferenceHelper>().setString(
                              AppConstants.defaultTestDurationKey, '30 min');
                        }),
                      ),
                      RadioPreference(
                        '40 min',
                        '40 min',
                        AppConstants.defaultTestDurationKey,
                        onSelect: () => setState(() {
                          GetIt.I<PreferenceHelper>().setString(
                              AppConstants.defaultTestDurationKey, '40 min');
                        }),
                      ),
                      RadioPreference(
                        '60 min',
                        '60 min',
                        AppConstants.defaultTestDurationKey,
                        onSelect: () => setState(() {
                          GetIt.I<PreferenceHelper>().setString(
                              AppConstants.defaultTestDurationKey, '60 min');
                        }),
                      ),
                      RadioPreference(
                        'No fixed duration',
                        'No fixed duration',
                        AppConstants.defaultTestDurationKey,
                        onSelect: () => setState(() {
                          GetIt.I<PreferenceHelper>().setString(
                              AppConstants.defaultTestDurationKey,
                              'No fixed duration');
                        }),
                      ),
                    ],
                    title: 'Default test duration',
                    cancelText: 'Cancel',
                    submitText: 'Save',
                    onlySaveOnSubmit: true,
                  ),
                ),
                SwitchPreference(
                  "FHR Alerts",
                  AppConstants.fhrAlertsKey,
                  desc:
                      'Tachycardial (> 160 bpm) and Bradycardia (<110 bpm) will be alerted.',
                  onEnable: () => setState(() {
                    GetIt.I<PreferenceHelper>().setBool(AppConstants.fhrAlertsKey, true);
                  }),
                  onDisable: () => setState(() {
                    GetIt.I<PreferenceHelper>().setBool(AppConstants.fhrAlertsKey, false);
                  }),
                ),
                SwitchPreference(
                  "Use Manual Movement Marker",
                  AppConstants.movementMarkerKey,
                ),
                SwitchPreference(
                  "Enable Patient ID",
                  AppConstants.patientIdKey,
                  desc:
                      'Patient ID field will be disable on mother registration form',
                  onEnable: () => setState(() {
                    GetIt.I<PreferenceHelper>().setBool(AppConstants.patientIdKey, true);
                  }),
                  onDisable: () => setState(() {
                    GetIt.I<PreferenceHelper>().setBool(AppConstants.patientIdKey, false);
                  }),
                ),
                SwitchPreference(
                  "Show Fisher Score",
                  AppConstants.fisherScoreKey,
                ),
                // SwitchPreference(
                //   "Twin reading",
                //   AppConstants.twinReadingKey,
                //   onEnable: (){
                //     setState(() {
                //       GetIt.I<PreferenceHelper>().setBool(AppConstants.twinReadingKey, true);
                //     });
                //   },
                //   onDisable: (){
                //     setState(() {
                //       GetIt.I<PreferenceHelper>().setBool(AppConstants.twinReadingKey, false);
                //     });
                //   },
                // ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(),
                const SizedBox(
                  height: 10,
                ),
                /* Row(
                  children: [
                    const Icon(Icons.share),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(
                      'Sharing',
                      style: TextStyle(fontSize: 20.sp),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                PreferenceDialogLink(
                  'Default email to share with',
                  desc: 'Not set',
                  dialog: PreferenceDialog(
                    [
                      TextFieldPreference(
                        'enter email',
                        AppConstants.emailKey,
                        autofocus: true,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                    title: 'Default email to share with',
                    cancelText: 'Cancel',
                    submitText: 'Save',
                    onlySaveOnSubmit: true,
                  ),
                ),
                SwitchPreference(
                  "Share audio",
                  AppConstants.shareAudioKey,
                  desc:
                      'Audio clip will be shared to mother via SMS and QRCode.',
                ),
                SwitchPreference(
                  "Share report",
                  AppConstants.shareReportKey,
                  desc:
                      'Report will be shared to the mother via SMS and QRCode.',
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(),
                const SizedBox(
                  height: 10,
                ),*/
                Row(
                  children: [
                    const Icon(Icons.print),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(
                      'Printing',
                      style: TextStyle(fontSize: 20.sp),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                PreferenceDialogLink(
                  'Default print scale',
                  desc: '1 cm/min',
                  dialog: PreferenceDialog(
                    [
                      RadioPreference(
                        '1 cm/min',
                        1,
                        AppConstants.defaultPrintScaleKey,
                      ),
                      RadioPreference(
                        '3 cm/min',
                        3,
                        AppConstants.defaultPrintScaleKey,
                      ),
                    ],
                    title: 'Default print scale',
                    cancelText: 'Cancel',
                    submitText: 'Save',
                    onlySaveOnSubmit: true,
                  ),
                ),
                SwitchPreference(
                  "Doctor's comment",
                  AppConstants.doctorCommentKey,
                  desc: 'Comments by doctor will not be printed.',
                ),
                SwitchPreference(
                  "Auto interpretation",
                  AppConstants.autoInterpretationsKey,
                  desc: 'Interpretation will not be printed.',
                  onChange: () {
                    setState(() {});
                  },
                ),
                PreferenceHider([
                  SwitchPreference(
                    "Highlight patterns",
                    AppConstants.highlightPatternsKey,
                    desc:
                        'Identified patterns such as accelerations decelerations will not be highlighted on the print.',
                  ),
                ], '!${AppConstants.autoInterpretationsKey}'),
                SwitchPreference(
                  "Display logo",
                  AppConstants.displayLogoKey,
                  desc: 'Logo will not be displayed on the print.',
                  defaultVal: false,
                  onEnable: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
