import 'package:fetosense_device_flutter/core/constants/app_routes.dart';
import 'package:fetosense_device_flutter/core/utils/color_manager.dart';
import 'package:fetosense_device_flutter/core/utils/utilities.dart';
import 'package:fetosense_device_flutter/presentation/all_mothers/all_mothers_cubit.dart';
import 'package:fetosense_device_flutter/presentation/widgets/animated_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// A stateful widget that displays a searchable and filterable list of mothers.
///
/// The `AllMothersView` widget presents a dashboard with statistics (total registered mothers,
/// tests performed) and a data table listing all mothers, their ages, and gestational ages.
/// It features a search bar for filtering mothers by name or ID, and uses Bloc for state management.
///
/// Example usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(builder: (_) => const AllMothersView()));
/// ```

class AllMothersView extends StatefulWidget {
  final bool autoFocus;
  const AllMothersView({super.key, this.autoFocus = false});

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
              onPressed: () => context.pop(),
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
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Hero(
                  tag: 'search',
                  child: Material(
                    child: TextField(
                      autofocus: widget.autoFocus,
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Search Mother by name or id",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      style: const TextStyle(color: Colors.black),
                      onChanged: (query) =>
                          context.read<AllMothersCubit>().filterMothers(query),
                    ),
                  ),
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
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AllMothersFailure) {
                return Center(child: Text("Error: ${state.error}"));
              }
              if (state is AllMothersSuccess) {
                final mothers = state.mother;
                final totalTests = mothers.fold<int>(
                  0,
                      (sum, mother) => sum + (mother.noOfTests ?? 0),
                );

                if (mothers.isEmpty) {
                  return const Center(child: Text("No mothers found."));
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
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
                            SizedBox(height: 50.sp),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/heart.PNG',
                                  scale: 15,
                                  color: ColorManager.primaryButtonColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AnimatedCount(
                                      count: mothers.length,
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
                            SizedBox(height: 30.sp),
                            Row(
                              children: [
                                Image.asset('assets/tests.jpg', scale: 8),
                                const SizedBox(width: 10),
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
                    const VerticalDivider(
                      color: Colors.grey,
                      thickness: 2,
                      width: 20,
                    ),
                    Expanded(
                      flex: 7,
                      child: SingleChildScrollView(
                        child: DataTable(
                          showCheckboxColumn: false,
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
                          rows: mothers.map((mother) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  InkWell(
                                    onTap: () => context.push(
                                        AppRoutes.motherDetails,
                                        extra: mother),
                                    child: Text(
                                      mother.name ?? "Unknown",
                                      style: TextStyle(fontSize: 18.sp),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    mother.age?.toString() ?? "-",
                                    style: TextStyle(fontSize: 18.sp),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    "${Utilities.getGestationalAgeWeeks(mother.lmp ?? DateTime.now())}",
                                    style: TextStyle(fontSize: 18.sp),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
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
