import 'package:appwrite/appwrite.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_device_flutter/data/models/mother_model.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../../core/utils/preferences.dart';

part 'all_mothers_state.dart';

/// A Cubit that manages the state of the mothers list in the application.
///
/// The `AllMothersCubit` is responsible for fetching, storing, and filtering
/// a list of `Mother` objects from the Appwrite database. It emits different
/// states based on the loading, success, or failure of data operations.
///
/// Example usage:
/// ```dart
/// final cubit = AllMothersCubit();
/// cubit.getMothersList();
/// cubit.filterMothers('search query');
/// ```

class AllMothersCubit extends Cubit<AllMothersState> {
  AllMothersCubit() : super(AllMothersInitial());

  List<MotherWithTest> _allRows = [];
  int _totalMothers = 0;
  int _totalTests = 0;

  Future<void> getMothersList() async {
    emit(AllMothersLoading());
    try {
      final databases = GetIt.I<Databases>();
      final prefs = GetIt.I<PreferenceHelper>();
      final user = prefs.getUser()!;

      final testsRes = await databases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.testsCollectionId,
        queries: [
          Query.equal('organizationId', user.organizationId),
          Query.orderDesc('createdOn'),
          Query.limit(200),
        ],
      );

      final tests = testsRes.documents
          .map((d) => Test.fromMap(d.data, d.$id))
          .where((t) => t.motherId != null)
          .toList();


      final motherIds = <String>{};
      for (final t in tests) {
        motherIds.add(t.motherId!);
      }

      final mothersRes = await databases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        queries: [
          Query.equal('type', 'mother'),
          Query.equal('organizationId', user.organizationId),
          Query.equal('documentId', motherIds.toList()),
          Query.orderDesc('\$createdAt'),
          Query.limit(2000)
        ],
      );

      final mothers = mothersRes.documents
          .map((d) => Mother.fromJson(d.data))
          .toList();

      final motherMap = {
        for (final m in mothers) m.documentId!: m
      };

      final List<MotherWithTest> rows = [];

      final usedMotherIds = <String>{};

      for (final test in tests) {
        final motherId = test.motherId!;
        if (usedMotherIds.contains(motherId)) continue;

        final mother = motherMap[motherId];
        if (mother == null) continue;

        rows.add(
          MotherWithTest(
            mother: mother,
            test: test,
          ),
        );

        usedMotherIds.add(motherId);
      }

      _allRows = rows;

      emit(
        AllMothersSuccess(
          AllMothersSummary(
            rows: _allRows,
            totalMothers: _totalMothers,
            totalTests: _totalTests,
          ),
        ),
      );
    } catch (e) {
      debugPrint('AllMothersCubit error: $e');
      emit(AllMothersFailure(e.toString()));
    }
  }

  getCount() async{
    final databases = GetIt.I<Databases>();
    final prefs = GetIt.I<PreferenceHelper>();
    final user = prefs.getUser()!;

    final mothersRes = await databases.listDocuments(
      databaseId: AppConstants.appwriteDatabaseId,
      collectionId: AppConstants.userCollectionId,
      queries: [
        Query.equal('type', 'mother'),
        Query.equal('organizationId', user.organizationId),
        Query.limit(2000)
      ],
    );

    _totalMothers = mothersRes.total;
    _totalTests = mothersRes.total;

  }

  void filterMothers(String query) {
    if (query.trim().isEmpty) {
      emit(
        AllMothersSuccess(
          AllMothersSummary(
            rows: _allRows,
            totalMothers: _totalMothers,
            totalTests: _totalTests,
          ),
        ),
      );
      return;
    }

    final q = query.toLowerCase();

    final filtered = _allRows.where((row) {
      return (row.mother.name ?? '').toLowerCase().contains(q) ||
          (row.mother.documentId ?? '').toLowerCase().contains(q);
    }).toList();

    emit(
      AllMothersSuccess(
        AllMothersSummary(
          rows: filtered,
          totalMothers: _totalMothers,
          totalTests: _totalTests,
        ),
      ),
    );
  }
}

class MotherWithTest {
  final Mother mother;
  final Test? test;

  MotherWithTest({
    required this.mother,
    this.test, //
  });
}

/// Summary object for AllMothers view
class AllMothersSummary {
  final List<MotherWithTest> rows;
  final int totalMothers;
  final int totalTests;

  AllMothersSummary({
    required this.rows,
    required this.totalMothers,
    required this.totalTests,
  });
}