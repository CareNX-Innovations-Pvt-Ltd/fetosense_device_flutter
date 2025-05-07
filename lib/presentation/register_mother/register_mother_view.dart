import 'package:fetosense_device_flutter/core/constants/app_routes.dart';
import 'package:fetosense_device_flutter/core/utils/color_manager.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/data/models/doctor_model.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/register_mother/register_mother_cubit.dart';
import 'package:fetosense_device_flutter/presentation/widgets/date_picker_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  bool showPatientId = false;
  final _formKey = GlobalKey<FormState>();
  Doctor? selectedDoctor;

  List<Doctor> doctorList = [];

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
    context.read<RegisterMotherCubit>().loadDoctors();
  }

  navigate(dynamic state) {
    if (route == AppConstants.instantTest) {
      context.read<RegisterMotherCubit>().saveTest(
            nameController.text,
            ageController.text,
            patientIdController.text,
            pickedDate,
            test,
            phoneNumberController.text,
            selectedDoctor!.uid ?? '',
            selectedDoctor!.name ?? '',
          );
      if (state is RegisterMotherSuccess) {
        context.pushReplacement(AppRoutes.detailsView, extra: state.test);
      }
    } else {
      context
          .read<RegisterMotherCubit>()
          .saveMother(
            nameController.text,
            ageController.text,
            patientIdController.text,
            pickedDate,
            test,
            phoneNumberController.text,
            selectedDoctor!.uid ?? '',
            selectedDoctor!.name ?? '',
          )
          .then((onValue) {
        if (mounted) {
          if (state is RegisterMotherSuccess) {
            context.pushReplacement(AppRoutes.dopplerConnectionView,
                extra: {'test': test, 'route': AppConstants.registeredMother});
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    nameController.text = "Jen";
    phoneNumberController.text = '1010441110';
    ageController.text = '30';

    return BlocListener<RegisterMotherCubit, RegisterMotherState>(
      listener: (context, state) {
        if (state is RegisterMotherSuccess) {
          if (route == AppConstants.instantTest) {
            context.pushReplacement(AppRoutes.detailsView, extra: state.test);
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
                        decoration: const InputDecoration(hintText: "Name"),
                        keyboardType: TextInputType.name,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? "Name is required"
                                : null,
                      ),
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: ageController,
                        decoration: const InputDecoration(hintText: "Age"),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? "Age is required"
                                : null,
                      ),
                      const SizedBox(height: 20),
                      Visibility(
                        visible: showPatientId,
                        replacement: Container(),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: patientIdController,
                              decoration:
                                  const InputDecoration(hintText: "Patient Id"),
                              keyboardType: TextInputType.text,
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                      ? "Patient ID required"
                                      : null,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      DatePickerTextField(
                        controller: lmpDateController,
                        label: "LMP Date",
                        onDateSelected: (DateTime date) {
                          pickedDate = date;
                          if (kDebugMode) print(pickedDate);
                        },
                      ),
                      const SizedBox(height: 20),

                      /// NEW: Doctor Dropdown
                      BlocBuilder<RegisterMotherCubit, RegisterMotherState>(
                        builder: (context, state) {
                          if (state is RegisterMotherDoctorLoaded) {
                            return DropdownButtonFormField<Doctor>(
                              value: selectedDoctor,
                              decoration: const InputDecoration(
                                  hintText: "Select Doctor"),
                              items: state.doctors.map((doctor) {
                                return DropdownMenuItem<Doctor>(
                                  value: doctor,
                                  child: Text(doctor.name ?? ''),
                                );
                              }).toList(),
                              onChanged: (value) {
                                print('id : ${value?.uid}');
                                print('id : ${value?.name}');
                                setState(() {
                                  selectedDoctor = value;
                                });
                              },
                            );
                          } else if (state is RegisterMotherLoading) {
                            return const CircularProgressIndicator();
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      const SizedBox(height: 40),
                      SizedBox(
                        height: 60,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                ColorManager.primaryButtonColor),
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
                                  selectedDoctor!.uid ?? '',
                                  selectedDoctor!.name ?? '',
                                );
                              } else {
                                cubit.saveMother(
                                  nameController.text,
                                  ageController.text,
                                  patientIdController.text,
                                  pickedDate,
                                  test,
                                  phoneNumberController.text,
                                  selectedDoctor!.uid ?? '',
                                  selectedDoctor!.name ?? '',
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
