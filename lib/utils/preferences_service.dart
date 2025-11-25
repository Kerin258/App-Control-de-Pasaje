import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _keyBudget = 'budget';
  static const _keyIsStudent = 'isStudent';
  static const _keyOnboardingComplete = 'onboardingComplete';
  static const _keyUserName = 'userName';

  Future<void> saveBudget(double budget) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyBudget, budget);
  }

  Future<double> getBudget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyBudget) ?? 0.0;
  }

  Future<void> saveIsStudent(bool isStudent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsStudent, isStudent);
  }

  Future<bool> getIsStudent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsStudent) ?? false;
  }

  Future<void> setOnboardingComplete(bool complete) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingComplete, complete);
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName) ?? 'Usuario';
  }

  static const _keySurname = 'surname';
  static const _keyAge = 'age';
  static const _keyProfileImagePath = 'profileImagePath';

  Future<void> saveSurname(String surname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySurname, surname);
  }

  Future<String> getSurname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySurname) ?? '';
  }

  Future<void> saveAge(String age) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAge, age);
  }

  Future<String> getAge() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAge) ?? '';
  }

  Future<void> saveProfileImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfileImagePath, path);
  }

  Future<String?> getProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyProfileImagePath);
  }

  Future<void> saveShortcuts(String shortcutsJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('shortcuts', shortcutsJson);
  }

  Future<String?> getShortcuts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('shortcuts');
  }
}
