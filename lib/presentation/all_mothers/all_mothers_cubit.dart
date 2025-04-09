import 'package:appwrite/appwrite.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_device_flutter/data/models/mother_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

part 'all_mothers_state.dart';

class AllMothersCubit extends Cubit<AllMothersState> {
  AllMothersCubit() : super(AllMothersInitial());
  List<Mother> allMothers = [];
  Future<void> getMothersList() async {
    emit(AllMothersLoading());
    try {
      final client = GetIt.I<AppwriteService>().client;
      final database = Databases(client);

      final result = await database.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        queries: [
          Query.equal('type', 'mother'),
        ],
      );

      if (result.total > 0) {
        final mothersList =
            result.documents.map((doc) => Mother.fromJson(doc.data)).toList();
        emit(AllMothersSuccess(mothersList));
      } else {
        emit(const AllMothersFailure('No Data'));
      }
    } catch (e) {
      debugPrint("error -> $e");
      emit(AllMothersFailure(e.toString()));
    }
  }

  void filterMothers(String query) {
    if (query.isEmpty) {
      getMothersList();
      emit(AllMothersSuccess(allMothers));
    } else {
      final filtered = allMothers.where((mother) {
        final name = mother.name?.toLowerCase() ?? "";
        final id = mother.deviceId?.toLowerCase() ?? "";
        final search = query.toLowerCase();
        return name.contains(search) || id.contains(search);
      }).toList();
      emit(AllMothersSuccess(filtered));
    }
  }
}
