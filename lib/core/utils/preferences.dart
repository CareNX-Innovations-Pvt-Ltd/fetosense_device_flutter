
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHelper {
  static const String _IS_AUTO_LOGIN = "IsAutoLogin";
  static const String _USERS = "users";
  static const String _DAILY_TIP_DISPLAYED = "DailyTipDisplay";
  static const String _TEMP_ADDRESS = "TempAddress";
  static const String _IS_WHATSAPP_ENABLED = "IsWhatsappEnabled";
  static const String _IS_FETOSENSE = "IsFetosenseEnabled";
  static const String _APP_OPEN_AT = "AppOpenAt";
  static const String _IS_UPDATED = "IsUpdated";
  static const String _IS_FIRST_TIME = "FirstTime";
  static const String _IS_BABYBEAT = "IsBabybeat";
  static const String _IS_ANANDI_MAA = "IsAnandiMaa";
  static const String _IS_BABY = "IsBaby";
  static const String _IS_BABYBEAT_ONBOARDING = "IsBabybeatOnboarding";

  static setAutoLogin(bool isAutoLogin) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_IS_AUTO_LOGIN, isAutoLogin);
  }

  static getAutoLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_IS_AUTO_LOGIN) ?? false;
  }

  // static setUser(Users user) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   inspect(user);
  //
  //   debugPrint("Pref USER: "+user.toJson().toString());
  //   String value = json.encode(user);
  //   print("Peref USER: "+value);
  //   prefs.setString(_USERS, value);
  // }
  //
  // static Future<Users?> getUser() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var user = prefs.getString(_USERS);
  //
  //   if (user != null) {
  //     var map = json.decode(user);
  //     Users users = Users.fromJson(map);
  //     return users;
  //   }
  //   return null;
  // }

  static removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(_USERS);
  }

  static setDailyTipDay(int day) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(_DAILY_TIP_DISPLAYED, day);
  }

  static Future<int> getDailyTipDay() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_DAILY_TIP_DISPLAYED) ?? 0;
  }

  static setAppOpenAt(int time) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(_APP_OPEN_AT, time);
  }

  static Future<int?> getAppOpenAt() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_APP_OPEN_AT);
  }

  static setTempAddress(List<String> address) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(_TEMP_ADDRESS, address);
  }

  static clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(_TEMP_ADDRESS);
  }

  static Future<List<String>?> getTempAddress() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_TEMP_ADDRESS);
  }

  static setWhatsAppEnabled(bool isWhatsAppEnabled) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_IS_WHATSAPP_ENABLED, isWhatsAppEnabled);
  }

  static Future<bool> getWhatsAppEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_IS_WHATSAPP_ENABLED) ?? false;
  }

  static setFetosense(bool isFetosenseEnabled) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_IS_FETOSENSE, isFetosenseEnabled);
  }

  static Future<bool> getFetosense() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_IS_FETOSENSE) ?? false;
  }

  static setLinkageFlag(bool isLinkageEnabled) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("IsLinkage", isLinkageEnabled);
  }

  static Future<bool> getLinkageFlag() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("IsLinkage") ?? false;
  }

  static saveReadArticleList(
      List<String> articleIdList, String weekPrefKey) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(weekPrefKey, articleIdList);
  }

  static Future<List<String>?> getReadArticleList(String weekPrefKey) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(weekPrefKey);
  }

  static setUpdate(bool isOpened) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_IS_UPDATED, isOpened);
  }

  static Future<bool> getUpdate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_IS_UPDATED) ?? false;
  }

  static setIsFirstTime(bool isFirst) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_IS_FIRST_TIME, isFirst);
  }

  static Future<bool> getIsFirstTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_IS_FIRST_TIME) ?? true;
  }

  static setBabybeat(bool isBabybeat) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_IS_BABYBEAT, isBabybeat);
  }

  static Future<bool> getBabybeat() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_IS_BABYBEAT) ?? false;
  }

  static setBaby(bool isBabybeat) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_IS_BABY, isBabybeat);
  }

  static Future<bool> getBabybeatOnBoarding() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_IS_BABYBEAT_ONBOARDING) ?? false;
  }

  static setBabybeatOnBoarding(bool isBabybeatOnboarding) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_IS_BABYBEAT_ONBOARDING, isBabybeatOnboarding);
  }

  static Future<bool> getBaby() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_IS_BABY) ?? false;
  }

  static setAnandiMaa(bool isAnandiMaaEnabled) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_IS_ANANDI_MAA, isAnandiMaaEnabled);
  }

  static Future<bool> getAnandiMaa() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_IS_ANANDI_MAA) ?? false;
  }

  static setInt(String key, int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  static setBool(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future <bool?> getBool(String key)async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

}
