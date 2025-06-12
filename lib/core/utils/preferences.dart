import 'dart:convert';

import 'package:fetosense_device_flutter/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A singleton helper class for managing app preferences using [SharedPreferences].
///
/// This class provides methods to store and retrieve user settings, login state,
/// user data, app open time, update flags, and other key-value pairs persistently.
/// It must be initialized by calling [PreferenceHelper.init()] before use.
///
/// Example usage:
/// ```dart
/// await PreferenceHelper.init();
/// final prefs = PreferenceHelper();
/// prefs.setAutoLogin(true);
/// UserModel? user = prefs.getUser();
/// ```

class PreferenceHelper {
  static final PreferenceHelper _instance = PreferenceHelper._internal();
  static SharedPreferences? _prefs;

  PreferenceHelper._internal();

  factory PreferenceHelper() {
    return _instance;
  }

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const String autoLogin = "IsAutoLogin";
  static const String users = "users";
  static const String _APP_OPEN_AT = "AppOpenAt";
  static const String _IS_UPDATED = "IsUpdated";
  static const String _IS_FIRST_TIME = "FirstTime";

  SharedPreferences get _prefsInstance {
    if (_prefs == null) {
      throw Exception("PreferenceHelper not initialized. Call PreferenceHelper.init() first.");
    }
    return _prefs!;
  }

  void setAutoLogin(bool isAutoLogin) => _prefsInstance.setBool(autoLogin, isAutoLogin);
  bool getAutoLogin() => _prefsInstance.getBool(autoLogin) ?? false;

  void removeUser() => _prefsInstance.remove(users);

  Future<void> saveUser(UserModel user) async {
    String userJson = jsonEncode(user.toJson());
    await _prefsInstance.setString(users, userJson);
  }

  UserModel? getUser() {
    String? userJson = _prefsInstance.getString(users);
    if (userJson == null) return null;

    Map<String, dynamic> userMap = jsonDecode(userJson);
    return UserModel.fromJson(userMap);
  }

  void setAppOpenAt(int time) => _prefsInstance.setInt(_APP_OPEN_AT, time);
  int? getAppOpenAt() => _prefsInstance.getInt(_APP_OPEN_AT);

  void setLinkageFlag(bool isEnabled) => _prefsInstance.setBool("IsLinkage", isEnabled);
  bool getLinkageFlag() => _prefsInstance.getBool("IsLinkage") ?? false;

  void saveReadArticleList(List<String> articleIds, String weekKey) => _prefsInstance.setStringList(weekKey, articleIds);
  List<String>? getReadArticleList(String weekKey) => _prefsInstance.getStringList(weekKey);

  void setUpdate(bool isOpened) => _prefsInstance.setBool(_IS_UPDATED, isOpened);
  bool getUpdate() => _prefsInstance.getBool(_IS_UPDATED) ?? false;

  void setIsFirstTime(bool isFirst) => _prefsInstance.setBool(_IS_FIRST_TIME, isFirst);
  bool getIsFirstTime() => _prefsInstance.getBool(_IS_FIRST_TIME) ?? true;

  void setInt(String key, int value) => _prefsInstance.setInt(key, value);
  int? getInt(String key) => _prefsInstance.getInt(key);

  void setBool(String key, bool value) => _prefsInstance.setBool(key, value);
  bool? getBool(String key) => _prefsInstance.getBool(key);

  void setString(String key, String value) => _prefsInstance.setString(key, value);
  String? getString(String key) => _prefsInstance.getString(key);
}

