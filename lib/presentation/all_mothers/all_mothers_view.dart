import 'package:fetosense_device_flutter/core/utils/color_manager.dart';
import 'package:fetosense_device_flutter/core/utils/utilities.dart';
import 'package:fetosense_device_flutter/presentation/all_mothers/all_mothers_cubit.dart';
import 'package:fetosense_device_flutter/presentation/widgets/animated_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AllMothersView extends StatefulWidget {
  const AllMothersView({super.key});

  @override
  State<AllMothersView> createState() => _AllMothersViewState();
}

class _AllMothersViewState extends State<AllMothersView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AllMothersCubit>().getMothersList();
  }

  @override
  Widget build(BuildContext context) {
    Utilities().setScreenUtil(context,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width);
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: AppBar(
            leading: IconButton(
              onPressed: () {
                context.pop();
              },
              icon: const Icon(Icons.arrow_back),
            ),
            title: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                height: 45,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: "Search Mother by name or id",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  style: const TextStyle(color: Colors.black),
                  onChanged: (query) {
                    context.read<AllMothersCubit>().filterMothers(query);
                  },
                ),

              ),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: BlocBuilder<AllMothersCubit, AllMothersState>(
            builder: (context, state) {
              if (state is AllMothersLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (state is AllMothersFailure) {
                return Center(child: Text("Error: ${state.error}"));
              }
              if (state is AllMothersSuccess) {
                final mothers = state.mother;
                final totalTests = state.mother.fold<int>(
                  0,
                  (sum, mother) => sum + (mother.noOfTests ?? 0),
                );
                if (mothers.isEmpty) {
                  return const Center(child: Text("No mothers found."));
                }

                final rows = mothers.map((mother) {
                  return {
                    "All mothers": mother.name ?? "Unknown",
                    "AGE": mother.age ?? "-",
                    "GEST": Utilities.getGestationalAgeWeeks(mother.lmp ?? DateTime.now()),
                  };
                }).toList();

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 250.sp,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              "Total",
                              style: TextStyle(
                                fontSize: 30.sp,
                                fontWeight: FontWeight.bold,
                                color: ColorManager.primaryButtonColor,
                              ),
                            ),
                            SizedBox(
                              height: 50.sp,
                            ),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/heart.PNG',
                                  scale: 15,
                                  color: ColorManager.primaryButtonColor,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AnimatedCount(
                                      count: state.mother.length,
                                      style: TextStyle(
                                        fontSize: 35.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Registered Mothers",
                                      style: TextStyle(
                                          fontSize: 20.sp, color: Colors.grey),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(
                              height: 30.sp,
                            ),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/tests.jpg',
                                  scale: 8,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AnimatedCount(
                                      count: totalTests,
                                      style: TextStyle(
                                        fontSize: 35.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Tests Performed",
                                      style: TextStyle(
                                          fontSize: 20.sp, color: Colors.grey),
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.sp,
                    ),
                    VerticalDivider(
                      color: Colors.grey,
                      thickness: 2,
                      width: 20.sp, // Space around the divider
                    ),
                    SizedBox(
                      width: 10.sp,
                    ),
                    Expanded(
                      child: DataTable(
                        columns: [
                          DataColumn(
                            label: Text(
                              'All mothers',
                              style: TextStyle(
                                fontSize: 25.sp,
                                fontWeight: FontWeight.bold,
                                color: ColorManager.primaryButtonColor,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'AGE',
                              style: TextStyle(
                                fontSize: 25.sp,
                                fontWeight: FontWeight.bold,
                                color: ColorManager.primaryButtonColor,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'GEST',
                              style: TextStyle(
                                fontSize: 25.sp,
                                fontWeight: FontWeight.bold,
                                color: ColorManager.primaryButtonColor,
                              ),
                            ),
                          ),
                        ],
                        rows: rows.map((row) {
                          return DataRow(cells: [
                            DataCell(
                              Text(
                                row["All mothers"].toString(),
                                style: TextStyle(fontSize: 18.sp),
                              ),
                            ),
                            DataCell(
                              Text(
                                row["AGE"].toString(),
                                style: TextStyle(fontSize: 18.sp),
                              ),
                            ),
                            DataCell(
                              Text(
                                row["GEST"].toString(),
                                style: TextStyle(fontSize: 18.sp),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ],
                );
              }
              return const Center(child: Text("Error: No data available"));
            },
          ),
        ),
      ),
    );
  }
}
