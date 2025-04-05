import 'package:shared_preferences/shared_preferences.dart';

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

  SharedPreferences get _prefsInstance {
    if (_prefs == null) {
      throw Exception("PreferenceHelper not initialized. Call PreferenceHelper.init() first.");
    }
    return _prefs!;
  }

  void setAutoLogin(bool isAutoLogin) => _prefsInstance.setBool(_IS_AUTO_LOGIN, isAutoLogin);
  bool getAutoLogin() => _prefsInstance.getBool(_IS_AUTO_LOGIN) ?? false;

  void removeUser() => _prefsInstance.remove(_USERS);

  void setDailyTipDay(int day) => _prefsInstance.setInt(_DAILY_TIP_DISPLAYED, day);
  int getDailyTipDay() => _prefsInstance.getInt(_DAILY_TIP_DISPLAYED) ?? 0;

  void setAppOpenAt(int time) => _prefsInstance.setInt(_APP_OPEN_AT, time);
  int? getAppOpenAt() => _prefsInstance.getInt(_APP_OPEN_AT);

  void setTempAddress(List<String> address) => _prefsInstance.setStringList(_TEMP_ADDRESS, address);
  List<String>? getTempAddress() => _prefsInstance.getStringList(_TEMP_ADDRESS);
  void clear() => _prefsInstance.remove(_TEMP_ADDRESS);

  void setWhatsAppEnabled(bool isEnabled) => _prefsInstance.setBool(_IS_WHATSAPP_ENABLED, isEnabled);
  bool getWhatsAppEnabled() => _prefsInstance.getBool(_IS_WHATSAPP_ENABLED) ?? false;

  void setFetosense(bool isEnabled) => _prefsInstance.setBool(_IS_FETOSENSE, isEnabled);
  bool getFetosense() => _prefsInstance.getBool(_IS_FETOSENSE) ?? false;

  void setLinkageFlag(bool isEnabled) => _prefsInstance.setBool("IsLinkage", isEnabled);
  bool getLinkageFlag() => _prefsInstance.getBool("IsLinkage") ?? false;

  void saveReadArticleList(List<String> articleIds, String weekKey) => _prefsInstance.setStringList(weekKey, articleIds);
  List<String>? getReadArticleList(String weekKey) => _prefsInstance.getStringList(weekKey);

  void setUpdate(bool isOpened) => _prefsInstance.setBool(_IS_UPDATED, isOpened);
  bool getUpdate() => _prefsInstance.getBool(_IS_UPDATED) ?? false;

  void setIsFirstTime(bool isFirst) => _prefsInstance.setBool(_IS_FIRST_TIME, isFirst);
  bool getIsFirstTime() => _prefsInstance.getBool(_IS_FIRST_TIME) ?? true;

  void setBabybeat(bool isEnabled) => _prefsInstance.setBool(_IS_BABYBEAT, isEnabled);
  bool getBabybeat() => _prefsInstance.getBool(_IS_BABYBEAT) ?? false;

  void setBaby(bool isEnabled) => _prefsInstance.setBool(_IS_BABY, isEnabled);
  bool getBaby() => _prefsInstance.getBool(_IS_BABY) ?? false;

  void setBabybeatOnBoarding(bool isEnabled) => _prefsInstance.setBool(_IS_BABYBEAT_ONBOARDING, isEnabled);
  bool getBabybeatOnBoarding() => _prefsInstance.getBool(_IS_BABYBEAT_ONBOARDING) ?? false;

  void setAnandiMaa(bool isEnabled) => _prefsInstance.setBool(_IS_ANANDI_MAA, isEnabled);
  bool getAnandiMaa() => _prefsInstance.getBool(_IS_ANANDI_MAA) ?? false;

  void setInt(String key, int value) => _prefsInstance.setInt(key, value);
  int? getInt(String key) => _prefsInstance.getInt(key);

  void setBool(String key, bool value) => _prefsInstance.setBool(key, value);
  bool? getBool(String key) => _prefsInstance.getBool(key);

  void setString(String key, String value) => _prefsInstance.setString(key, value);
  String? getString(String key) => _prefsInstance.getString(key);
}

