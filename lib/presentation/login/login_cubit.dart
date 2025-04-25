
import 'package:appwrite/appwrite.dart';
import 'package:equatable/equatable.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/network/dependency_injection.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/data/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  Future<void> login(String email, String password) async {
    emit(LoginLoading());

    try {
      final client = ServiceLocator.appwriteService.client;
      final databases = Databases(client);
      final prefs = GetIt.I<PreferenceHelper>();

      /// 🔍 Primary query: user collection
      var result = await databases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        queries: [
          Query.equal('email', email),
        ],
      );

      /// 📄 Try primary user
      if (result.total > 0) {
        debugPrint('inside 1st if ');
        final userDoc = result.documents.first;

        final user = UserModel.fromMap(userDoc.data, userDoc.$id);
        await prefs.saveUser(user);
        prefs.setAutoLogin(true);
        emit(LoginSuccess());
        return;
      } else {
        debugPrint('inside 1st else ');
        var getUserFromMis = await databases.listDocuments(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: AppConstants.userCollectionId,
          queries: [
            Query.equal('email', email),
          ],
        );

        if (getUserFromMis.total > 0) {

          debugPrint('inside 2nd if ');

          final userDoc = getUserFromMis.documents.first;

          /// ✅ Optional: filter unknown fields
          final safeData = Map<String, dynamic>.from(userDoc.data)
            ..removeWhere((key, _) => !UserModel().toJson().keys.contains(key));

          debugPrint('data from cubit --> $safeData');

          final user = UserModel.fromMap(safeData, userDoc.$id);

          debugPrint('user data is updated --> $user');

          await prefs.saveUser(user);
          prefs.setAutoLogin(true);
          emit(LoginSuccess());
        } else {
          debugPrint('inside 2nd else ');
          final temp = email.split('@').first;

          /// 🔁 Fallback: try device collection
          final result = await databases.listDocuments(
            databaseId: AppConstants.appwriteDatabaseId,
            collectionId: AppConstants.deviceCollectionId,
            queries: [
              Query.equal('deviceCode', temp),
            ],
          );

          if (result.total > 0) {
            final deviceDoc = result.documents.first;
            debugPrint('device document data  --> ${deviceDoc.data}');
            final allowedKeys = UserModel().toJson().keys;

            final safeData = Map<String, dynamic>.from(deviceDoc.data)
              ..removeWhere((key, _) => !allowedKeys.contains(key));

            debugPrint('Filtered data for UserModel --> $safeData');

            safeData['email'] = email;
            safeData['type'] = "device";
            safeData['organizationName'] = deviceDoc.data['hospitalName'];

            final user = UserModel.fromMap(safeData, deviceDoc.$id);

            await databases.createDocument(
              databaseId: AppConstants.appwriteDatabaseId,
              collectionId: AppConstants.userCollectionId,
              documentId: ID.unique(),
              data: user.toJson(),
            );

            await prefs.saveUser(user);
            prefs.setAutoLogin(true);

            emit(LoginSuccess());
          } else {
            emit(const LoginFailure("User not found in any collection"));
          }
        }
      }
    } catch (e) {
      debugPrint("error -> $e");
      emit(LoginFailure("Login failed: ${e.toString()}"));
    }
  }
}
