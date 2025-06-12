import 'package:appwrite/appwrite.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

part 'mother_details_state.dart';

/// Cubit that manages the state and logic for fetching test data related to a mother.
///
/// `MotherDetailsCubit` interacts with the Appwrite database to retrieve a list of tests
/// associated with a given mother name. It emits loading, success, or failure states
/// based on the outcome of the fetch operation. The cubit is used to update the UI
/// with the relevant test data or error messages.
///
/// Example usage:
/// ```dart
/// final cubit = MotherDetailsCubit();
/// cubit.fetchTests('Jane Doe');
/// ```

class MotherDetailsCubit extends Cubit<MotherDetailsState> {
  MotherDetailsCubit() : super(MotherDetailsInitial());

  Future<void> fetchTests(String motherName) async {
    emit(MotherDetailsLoading());
    final client = GetIt.I<AppwriteService>().client;
    try {
      Databases databases = Databases(client);
      var result = await databases.listDocuments(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: AppConstants.testsCollectionId,
          queries: [
            Query.equal('motherName', motherName),
          ]);
      if (result.total > 0) {
        final testList = result.documents.map((doc) {
          return Test.fromMap(doc.data, doc.$id);
        }).toList();

        emit(MotherDetailsSuccess(testList));
      } else {
        emit(const MotherDetailsFailure("No data"));
      }
    } catch (e, s) {
      emit(MotherDetailsFailure("error -> $e"));
      if (kDebugMode) {
        print(e);
        print(s);
      }
    }
  }
}
