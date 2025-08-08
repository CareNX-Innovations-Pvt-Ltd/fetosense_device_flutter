import 'package:appwrite/appwrite.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_device_flutter/data/models/mother_model.dart';
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
  List<Mother> allMothers = [];

  Future<void> getMothersList() async {
    emit(AllMothersLoading());
    try {
      final client = GetIt.I<AppwriteService>().client;
      final database = GetIt.I<Databases>();
      final prefs = GetIt.I<PreferenceHelper>();
      final user = prefs.getUser();
      debugPrint('user -> ${user?.toJson()}');
      final result = await database.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        queries: [
          Query.equal('type', 'mother'),
          Query.equal('organizationName', user?.organizationName),
        ],
      );
      if (result.total > 0) {
        allMothers =
            result.documents.map((doc) => Mother.fromJson(doc.data)).toList();
        emit(AllMothersSuccess(allMothers));
      } else {
        emit(const AllMothersFailure('No Data'));
      }
    } catch (e) {
      debugPrint("error -> $e");
      emit(
        AllMothersFailure(
          e.toString(),
        ),
      );
    }
  }

  void filterMothers(String query) {
    if (query.isEmpty) {
      emit(AllMothersSuccess(allMothers));
      return;
    }

    final lowercaseQuery = query.toLowerCase().trim();
    final filteredMothers = allMothers.where((mother) {
      final name = mother.name?.toLowerCase() ?? '';
      return name.contains(lowercaseQuery);
    }).toList();

    if (filteredMothers.isEmpty) {
      emit(const AllMothersSuccess([]));
    } else {
      emit(AllMothersSuccess(filteredMothers));
    }
  }
}
