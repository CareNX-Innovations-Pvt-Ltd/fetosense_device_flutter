import 'package:fetosense_device_flutter/core/color_manager.dart';
import 'package:fetosense_device_flutter/presentation/widgets/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterMotherView extends StatefulWidget {
  const RegisterMotherView({super.key});

  @override
  State<RegisterMotherView> createState() => _RegisterMotherViewState();
}

class _RegisterMotherViewState extends State<RegisterMotherView> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController lmpDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: phoneNumberController,
                  decoration: const InputDecoration(
                    hintText: "Phone Number",
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(
                    hintText: "Age",
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                // TextField(
                //   controller: lmpDateController,
                //   decoration: const InputDecoration(
                //     hintText: "LMP Date",
                //   ),
                // ),
                DatePickerTextField(
                  controller: lmpDateController,
                  label: "LMP Date",
                  onDateSelected: (DateTime date) {
                    print(date);
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
                    onPressed: () {},
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
    );
  }
}
