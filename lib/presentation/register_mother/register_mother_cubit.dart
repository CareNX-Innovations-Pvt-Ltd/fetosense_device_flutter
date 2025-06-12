import 'package:appwrite/appwrite.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_device_flutter/core/utils/utilities.dart';
import 'package:fetosense_device_flutter/data/models/mother_model.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

part 'register_mother_state.dart';

/// Cubit responsible for handling the registration and saving of mother and test data.
///
/// `RegisterMotherCubit` manages the state for registering a new mother and associating
/// her with a test. It interacts with the Appwrite database to create and update documents,
/// emitting loading, success, or failure states as appropriate. This cubit is used to
/// coordinate the registration flow and update the UI based on the outcome.
///
/// Example usage:
/// ```dart
/// final cubit = RegisterMotherCubit();
/// cubit.saveMother(name, age, patientId, pickedDate, test, mobile);
/// ```

class RegisterMotherCubit extends Cubit<RegisterMotherState> {
  RegisterMotherCubit() : super(RegisterMotherInitial());
  final client = GetIt.I<AppwriteService>().client;

  Future<void> saveTest(String name, String age, String patientId,
      DateTime? pickedDate, Test? test, String mobile) async {
    emit(RegisterMotherLoading());

    Databases databases = Databases(client);
    try {
      var id = ID.unique();
      Mother mother = Mother();
      mother.name = name;
      mother.age = int.parse(age);
      mother.lmp = pickedDate;
      mother.deviceName = test!.deviceName;
      mother.deviceId = test.deviceId;
      mother.type = 'mother';
      mother.noOfTests = 1;
      mother.mobileNo = int.parse(mobile);
      mother.organizationId = test.organizationId;
      mother.organizationName = test.organizationName;
      mother.documentId = id;

      await databases.createDocument(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: AppConstants.userCollectionId,
          documentId: id,
          data: mother.toJson());

      debugPrint('Mother created successfully.');

      int gestationalAge = Utilities.getGestationalAgeWeeks(pickedDate!);
      test.motherName = name;
      test.age = int.parse(age);
      test.gAge = gestationalAge;
      test.patientId = patientId;

      await databases.updateDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.testsCollectionId,
        documentId: test.documentId!,
        data: test.toJson(),
      );

      emit(RegisterMotherSuccess(test, mother));
    } catch (e, s) {
      if (kDebugMode) {
        print('Error saving test: $e');
        print(s);
        emit(RegisterMotherFailure(e.toString()));
      }
    }
  }

  Future<bool?> saveMother(String name, String age, String patientId,
      DateTime? pickedDate, Test? test, String mobile) async {
    Databases databases = Databases(client);
    try {
      var id = ID.unique();
      int gestationalAge = Utilities.getGestationalAgeWeeks(pickedDate!);
      Mother mother = Mother();
      mother.name = name;
      mother.age = int.parse(age);
      mother.lmp = pickedDate;
      mother.deviceName = test!.deviceName;
      mother.deviceId = test.deviceId;
      mother.type = 'mother';
      test.motherName = name;
      test.age = int.parse(age);
      test.gAge = gestationalAge;
      test.patientId = patientId;
      mother.documentId = id;

      await databases.createDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        documentId: id,
        data: mother.toJson(),
      );
      emit(RegisterMotherSuccess(test , mother));

      debugPrint('Mother created successfully.');
      return true;
    } catch (e, s) {
      if (kDebugMode) {
        print('Error saving mother: $e');
        print(s);
      }
      return false;
    }
  }
}
