import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/data/models/user_model.dart';

void main() {
  group('PreferenceHelper', () {
    late PreferenceHelper prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await PreferenceHelper.init();
      prefs = PreferenceHelper();
    });

    test('should set and get auto login flag', () {
      prefs.setAutoLogin(true);
      expect(prefs.getAutoLogin(), true);

      prefs.setAutoLogin(false);
      expect(prefs.getAutoLogin(), false);
    });

    test('should save and retrieve user data', () async {
      final user = UserModel()..name = 'Test User';
      user.email = 'test@example.com';

      await prefs.saveUser(user);

      final retrievedUser = prefs.getUser();
      expect(retrievedUser, isNotNull);
      // expect(retrievedUser!.id, '123');
      expect(retrievedUser?.name, 'Test User');
      expect(retrievedUser?.email, 'test@example.com');
    });

    test('should remove user data', () {
      prefs.removeUser();
      expect(prefs.getUser(), isNull);
    });

    test('should set and get app open time', () {
      prefs.setAppOpenAt(1234567890);
      expect(prefs.getAppOpenAt(), 1234567890);
    });

    test('should set and get linkage flag', () {
      prefs.setLinkageFlag(true);
      expect(prefs.getLinkageFlag(), true);

      prefs.setLinkageFlag(false);
      expect(prefs.getLinkageFlag(), false);
    });

    test('should save and retrieve read article list', () {
      final articles = ['article1', 'article2', 'article3'];
      prefs.saveReadArticleList(articles, 'week1');

      final retrievedArticles = prefs.getReadArticleList('week1');
      expect(retrievedArticles, isNotNull);
      expect(retrievedArticles, articles);
    });

    test('should set and get update flag', () {
      prefs.setUpdate(true);
      expect(prefs.getUpdate(), true);

      prefs.setUpdate(false);
      expect(prefs.getUpdate(), false);
    });

    test('should set and get first-time flag', () {
      prefs.setIsFirstTime(false);
      expect(prefs.getIsFirstTime(), false);

      prefs.setIsFirstTime(true);
      expect(prefs.getIsFirstTime(), true);
    });

    test('should set and get custom integer value', () {
      prefs.setInt('customKey', 42);
      expect(prefs.getInt('customKey'), 42);
    });

    test('should set and get custom boolean value', () {
      prefs.setBool('customBoolKey', true);
      expect(prefs.getBool('customBoolKey'), true);
    });

    test('should set and get custom string value', () {
      prefs.setString('customStringKey', 'testValue');
      expect(prefs.getString('customStringKey'), 'testValue');
    });
  });
}