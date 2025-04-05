import 'package:appwrite/appwrite.dart';
import 'package:equatable/equatable.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/network/dependency_injection.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    try {
      var client = ServiceLocator.appwriteService.client;
      final databases = Databases(client);
      final prefs = GetIt.I<PreferenceHelper>();
      final result = await databases.listDocuments(
        databaseId: AppConstants.misDatabase,
        collectionId: AppConstants.misUserCollection,
        queries: [
          Query.equal('email', email),
        ],
      );

      if (result.total > 0) {
        prefs.setAutoLogin(true);
        emit(LoginSuccess());
      } else {
        emit(const LoginFailure("User not found"));
      }
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
