import 'package:fetosense_device_flutter/core/utils/color_manager.dart';
import 'package:fetosense_device_flutter/core/utils/utilities.dart';
import 'package:fetosense_device_flutter/data/models/mother_model.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/mother_details/mother_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MotherDetailsPage extends StatefulWidget {
  final Mother mother;

  const MotherDetailsPage({super.key, required this.mother});

  @override
  State<MotherDetailsPage> createState() => _MotherDetailsPageState();
}

class _MotherDetailsPageState extends State<MotherDetailsPage> {
  Test? test;

  @override
  void initState() {
    super.initState();
    context.read<MotherDetailsCubit>().fetchTests(widget.mother.name ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final gAge =
        Utilities.getGestationalAgeWeeks(widget.mother.lmp ?? DateTime.now());
    final formattedLMP = widget.mother.lmp != null
        ? DateFormat.yMMMMd().format(widget.mother.lmp!)
        : 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mother Details'),
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: TextButton(
        //       onPressed: () {
        //         context.push(AppRoutes.dopplerConnectionView, extra: {
        //           'route': AppConstants.motherDetailsRoute,
        //           'test': Test(),
        //           'mother': widget.mother
        //         });
        //       },
        //       style: TextButton.styleFrom(
        //           backgroundColor: ColorManager.primaryButtonColor),
        //       child: const Text(
        //         '+ New Test',
        //         style: TextStyle(color: Colors.white, fontSize: 17),
        //       ),
        //     ),
        //   ),
        // ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(
              width: 300,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Avatar and Name
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.pink.shade100,
                      child: Text(
                        widget.mother.name?.substring(0, 1).toUpperCase() ??
                            '?',
                        style:
                            const TextStyle(fontSize: 40, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.mother.name ?? 'Unknown',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Patient ID: ${widget.mother.patientId ?? "N/A"}',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 20),

                    // Profile Info Cards
                    _buildInfoCard("Age", widget.mother.age?.toString() ?? "-"),
                    _buildInfoCard("Gestational Age", "$gAge weeks"),
                    _buildInfoCard("LMP", formattedLMP),
                    _buildInfoCard(
                        "Device", widget.mother.deviceName ?? "Unknown"),
                    _buildInfoCard(
                        "Device ID", widget.mother.deviceId ?? "N/A"),
                    _buildInfoCard("Total Tests",
                        (widget.mother.noOfTests ?? 0).toString()),

                    const SizedBox(height: 30),

                    // Add a button or additional test list view
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.receipt_long, color: Colors.white),
                      label: const Text(
                        "View Test History",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.primaryButtonColor,
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            const VerticalDivider(
              thickness: 2,
              color: Colors.grey,
              width: 20,
            ),
            BlocBuilder<MotherDetailsCubit, MotherDetailsState>(
              builder: (context, state) {
                if (state is MotherDetailsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MotherDetailsFailure) {
                  return Center(child: Text(state.failure));
                } else if (state is MotherDetailsSuccess) {
                  var tests = state.test;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: tests.length,
                      itemBuilder: (context, index) {
                        final test = tests[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text("Test #${index + 1}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text("Gestational Age: ${test.gAge} weeks"),
                                test.patientId!.isNotEmpty
                                    ? Text(
                                        "Patient ID: ${test.patientId ?? '-'}")
                                    : Container(),
                                Text("Device: ${test.deviceName ?? '-'}"),
                                Text("Date: ${test.createdOn}"),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ColorManager.primaryButtonColor.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade100.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
