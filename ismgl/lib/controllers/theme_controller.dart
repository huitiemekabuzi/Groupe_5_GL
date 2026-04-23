import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/core/services/storage_service.dart';

class ThemeController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final currentTheme = ThemeMode.light.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme() {
    final saved = _storage.getTheme();
    if (saved == 'dark') {
      currentTheme.value = ThemeMode.dark;
    } else {
      currentTheme.value = ThemeMode.light;
    }
  }

  void toggleTheme() {
    if (currentTheme.value == ThemeMode.light) {
      currentTheme.value = ThemeMode.dark;
      _storage.saveTheme('dark');
    } else {
      currentTheme.value = ThemeMode.light;
      _storage.saveTheme('light');
    }
  }

  bool get isDark => currentTheme.value == ThemeMode.dark;
}