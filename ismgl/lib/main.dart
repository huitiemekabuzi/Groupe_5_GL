// ignore_for_file: avoid_print

import 'package:ismgl/app/app_messenger.dart';
import 'package:ismgl/app/initialization.dart';
import 'package:ismgl/app/routes/app_pages.dart';
import 'package:ismgl/app/routes/app_routes.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await AppInitialization.initialize();
  runApp(const MyApp());
  try {
    FlutterNativeSplash.remove();
  } catch (e) {
    // Web can throw if splash assets were not generated yet.
    print('⚠️ Splash remove ignored: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'ISMGL',
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        themeMode: themeController.currentTheme.value,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        initialRoute: AppRoutes.splash,
        getPages: AppPages.pages,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('fr', 'FR')],
        locale: const Locale('fr', 'FR'),
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        enableLog: true,
        logWriterCallback: (text, {bool isError = false}) {
          if (isError) {
            print('🔴 GETX ERROR: $text');
          } else {
            print('🔵 GETX INFO: $text');
          }
        },
        popGesture: false,
      ),
    );
  }
}