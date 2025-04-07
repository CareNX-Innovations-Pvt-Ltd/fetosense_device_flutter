import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:fetosense_device_flutter/core/constants/app_routes.dart';
import 'package:fetosense_device_flutter/core/utils/color_manager.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/network/dependency_injection.dart';
import 'package:fetosense_device_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/widgets/date_picker_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class RegisterMotherView extends StatefulWidget {
  final Test? test;
  final String? previousRoute;

  const RegisterMotherView({super.key, this.test, this.previousRoute});

  @override
  State<RegisterMotherView> createState() => _RegisterMotherViewState();
}

class _RegisterMotherViewState extends State<RegisterMotherView> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController patientIdController = TextEditingController();
  TextEditingController lmpDateController = TextEditingController();
  Test? test;
  String? route;
  DateTime? pickedDate;
  AppwriteService client = ServiceLocator.appwriteService;
  bool showPatientId = false;

  @override
  void initState() {
    super.initState();
    test = widget.test;
    route = widget.previousRoute;
    setState(() {
      showPatientId = GetIt.I<PreferenceHelper>().getBool(AppConstants.patientIdKey) ?? false;
    });
  }

  int getGestationalAgeWeeks(DateTime lastMenstrualPeriod) {
    DateTime today = DateTime.now();
    return (today.difference(lastMenstrualPeriod).inDays / 7).floor();
  }

  saveTest() async {
    Databases databases = Databases(client.client);
    try {
      Document result = await databases.createDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.testCollectionId,
        documentId: ID.unique(),
        data: test!.toJson(),
      );
      if (result.data.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test saved'),
          ),
        );
      }
    } catch (e, s) {
      if (kDebugMode) {
        print(e);
        print(s);
      }
    }
  }


  navigate() {
    test!.motherName = nameController.text;
    test!.age = int.parse(ageController.text);
    test!.gAge = getGestationalAgeWeeks(pickedDate!);
    test!.patientId = patientIdController.text;
    if (route == AppConstants.instantTest) {
      context.pushReplacement(AppRoutes.detailsView, extra: test);
    } else {
      context.pushReplacement(AppRoutes.dopplerConnectionView,
          extra: {'test': test, 'route': AppConstants.registeredMother});
    }
  }

  @override
  Widget build(BuildContext context) {
    nameController.text = "testing";
    phoneNumberController.text = '1010441010';
    ageController.text= '32';

    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorManager.white,
        appBar: AppBar(
          title: const Text('New Mother Registration'),
          leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: "Name",
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: phoneNumberController,
                    decoration: const InputDecoration(
                      hintText: "Phone Number",
                      counterText: ''
                    ),
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: ageController,
                    decoration: const InputDecoration(
                      hintText: "Age",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Visibility(
                    visible: showPatientId,
                    replacement: Container(),
                    child: Column(
                    children: [
                      TextField(
                        controller: patientIdController,
                        decoration: const InputDecoration(
                          hintText: "Patient Id",
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),),
                  DatePickerTextField(
                    controller: lmpDateController,
                    label: "LMP Date",
                    onDateSelected: (DateTime date) {
                      if (kDebugMode) {
                        print(date);
                        pickedDate = date;
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll<Color>(
                          ColorManager.primaryButtonColor,
                        ),
                      ),
                      onPressed: () {
                        navigate();
                      },
                      child: const Text(
                        'Register Mother',
                        style: TextStyle(color: ColorManager.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
