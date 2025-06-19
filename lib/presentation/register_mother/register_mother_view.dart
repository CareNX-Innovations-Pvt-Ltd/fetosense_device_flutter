import 'package:fetosense_device_flutter/core/constants/app_routes.dart';
import 'package:fetosense_device_flutter/core/utils/color_manager.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/register_mother/register_mother_cubit.dart';
import 'package:fetosense_device_flutter/presentation/widgets/date_picker_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

/// A stateful widget that provides a form for registering a new mother and associating her with a test.
///
/// `RegisterMotherView` displays input fields for the mother's name, phone number, age, patient ID (optional),
/// and LMP date. It validates user input and interacts with [RegisterMotherCubit] to save the mother and test data.
/// Navigation is handled based on the registration flow, either proceeding to test details or device connection screens.
///
/// Example usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => RegisterMotherView(test: test, previousRoute: route),
/// ));
/// ```

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
  bool showPatientId = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    test = widget.test;
    route = widget.previousRoute;
    context.read<RegisterMotherCubit>().loadDoctors();
    setState(() {
      showPatientId =
          GetIt.I<PreferenceHelper>().getBool(AppConstants.patientIdKey) ??
              false;
    });
  }

  @override
  Widget build(BuildContext context) {
    nameController.text = "Jena McArthy";
    phoneNumberController.text = '1010441000';
    ageController.text = '35';

    return BlocListener<RegisterMotherCubit, RegisterMotherState>(
      listener: (context, state) {
        if (state is RegisterMotherSuccess) {
          if (route == AppConstants.instantTest) {
            context.pushReplacement(AppRoutes.detailsView, extra: {'test': state.test});
          } else {
            context.pushReplacement(
              AppRoutes.dopplerConnectionView,
              extra: {
                'test': state.test,
                'route': AppConstants.registeredMother,
                'mother': state.mother,
              },
            );
          }
        }
      },
      child: SafeArea(
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: "Name",
                        ),
                        keyboardType: TextInputType.name,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? "Name is required"
                                : null,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: phoneNumberController,
                        decoration: const InputDecoration(
                            hintText: "Phone Number", counterText: ''),
                        maxLength: 10,
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                            value == null || value.length != 10
                                ? "Enter valid phone number"
                                : null,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: ageController,
                        decoration: const InputDecoration(
                          hintText: "Age",
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? "Age is required"
                                : null,
                      ),
                      const SizedBox(
                        height: 20,
                      ),

                      /// Doctor Dropdown
                      BlocBuilder<RegisterMotherCubit, RegisterMotherState>(
                        builder: (context, state) {
                          final cubit = context.read<RegisterMotherCubit>();
                          final doctors = cubit.doctors;

                          if (doctors.isEmpty) {
                            return const SizedBox(); // or CircularProgressIndicator
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Select Doctor',
                                border: UnderlineInputBorder(),
                              ),
                              value: cubit.selectedDoctorId,
                              items: doctors.map((doctor) {
                                final name = doctor['name'] ?? 'Unnamed';
                                final id = doctor['id']!;
                                return DropdownMenuItem<String>(
                                  value: id,
                                  child: Text(name), // 👈 Show only name
                                );
                              }).toList(),
                              onChanged: (value) {
                                context
                                    .read<RegisterMotherCubit>()
                                    .selectDoctor(value);
                              },
                            ),
                          );
                        },
                      ),

                      Visibility(
                        visible: showPatientId,
                        replacement: Container(),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: patientIdController,
                              decoration: const InputDecoration(
                                hintText: "Patient Id",
                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                      ? "Patient ID required"
                                      : null,
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
                            if (_formKey.currentState!.validate()) {
                              if (pickedDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Please select LMP date")),
                                );
                                return;
                              }

                              final cubit = context.read<RegisterMotherCubit>();

                              if (route == AppConstants.instantTest) {
                                cubit.saveTest(
                                  nameController.text,
                                  ageController.text,
                                  patientIdController.text,
                                  pickedDate,
                                  test,
                                  phoneNumberController.text,
                                  cubit.selectedDoctorName,
                                  cubit.selectedDoctorId,
                                );
                              } else {
                                cubit.saveMother(
                                  nameController.text,
                                  ageController.text,
                                  patientIdController.text,
                                  pickedDate,
                                  test,
                                  phoneNumberController.text,
                                  cubit.selectedDoctorName,
                                  cubit.selectedDoctorId,
                                );
                              }
                            }
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
        ),
      ),
    );
  }
}
