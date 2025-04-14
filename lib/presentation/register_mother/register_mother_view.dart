import 'package:appwrite/appwrite.dart';
import 'package:fetosense_device_flutter/core/constants/app_routes.dart';
import 'package:fetosense_device_flutter/core/utils/color_manager.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/network/dependency_injection.dart';
import 'package:fetosense_device_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/core/utils/utilities.dart';
import 'package:fetosense_device_flutter/data/models/mother_model.dart';
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
      showPatientId =
          GetIt.I<PreferenceHelper>().getBool(AppConstants.patientIdKey) ??
              false;
    });
  }

  Future<bool?> saveMother() async {
    Databases databases = Databases(client.client);
    try {
      final String motherName = nameController.text.trim();
      final int motherAge = int.parse(ageController.text);
      int gestationalAge = Utilities.getGestationalAgeWeeks(pickedDate!);
      Mother mother = Mother();
      mother.name = motherName;
      mother.age = motherAge;
      mother.lmp = pickedDate;
      mother.deviceName = test?.deviceName;
      mother.deviceId = test?.deviceId;
      mother.type = 'mother';
      test!.motherName = motherName;
      test!.age = motherAge;
      test!.gAge = gestationalAge;
      test!.patientId = patientIdController.text;
      await databases.createDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        documentId: ID.unique(),
        data: mother.toJson(),
      );

      debugPrint('Mother created successfully.');
      return true;
    } catch (e, s) {
      if (kDebugMode) {
        print('Error saving mother: $e');
        print(s);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save mother: ${e.toString()}')),
        );
      }
      return false;
    }
  }


  Future<void> saveTest() async {
    Databases databases = Databases(client.client);
    try {
      final String motherName = nameController.text.trim();
      final int motherAge = int.parse(ageController.text);
      final String patientId = patientIdController.text;

      Mother mother = Mother();
      mother.name = motherName;
      mother.age = motherAge;
      mother.lmp = pickedDate;
      mother.deviceName = test!.deviceName;
      mother.deviceId = test!.deviceId;
      mother.type = 'mother';
      mother.noOfTests = 1;

      await databases.createDocument(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: AppConstants.userCollectionId,
          documentId: ID.unique(),
          data: mother.toJson());

      debugPrint('Mother created successfully.');

      // Calculate gestational age
      int gestationalAge = Utilities.getGestationalAgeWeeks(pickedDate!);

      // Prepare and save test
      test!.motherName = motherName;
      test!.age = motherAge;
      test!.gAge = gestationalAge;
      test!.patientId = patientId;

      var testResult = await databases.createDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.testsCollectionId,
        documentId: ID.unique(),
        data: test!.toJson(),
      );

      if (testResult.$id.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test saved')),
        );
      }
    } catch (e, s) {
      if (kDebugMode) {
        print('Error saving test: $e');
        print(s);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save test: ${e.toString()}')),
        );
      }
    }
  }

  navigate() {
    if (route == AppConstants.instantTest) {
      saveTest();
      context.pushReplacement(AppRoutes.detailsView, extra: test);
    } else {
      saveMother().then((onValue){
        if(mounted){
          context.pushReplacement(AppRoutes.dopplerConnectionView,
              extra: {'test': test, 'route': AppConstants.registeredMother});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    nameController.text = "Alice Wonderland";
    phoneNumberController.text = '1010441000';
    ageController.text = '32';

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
                        hintText: "Phone Number", counterText: ''),
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
                    ),
                  ),
                  DatePickerTextField(
                    controller: lmpDateController,
                    label: "LMP Date",
                    onDateSelected: (DateTime date) {
                      if (kDebugMode) {
                        pickedDate = date;
                        print(pickedDate);
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
