import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:prashant/config/theme.dart';
import 'package:prashant/config/app_routes.dart';
import 'package:prashant/config/supabase_options.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  logger.i('🚀 App starting...');
  
  // Global error handler
  FlutterError.onError = (FlutterErrorDetails details) {
    logger.e('❌ Flutter Error: ${details.exception}');
    logger.e('Stack: ${details.stack}');
  };
  
  // Async error handler
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.e('❌ Platform Error: $error');
    return true;
  };
  
  // Initialize Supabase with timeout
  try {
    logger.i('🔐 Initializing Supabase...');
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () async {
        logger.e('⏱️ Supabase init timeout');
        return Supabase.instance;
      },
    );
    logger.i('✅ Supabase ready');
  } catch (e, stack) {
    logger.e('❌ Supabase error: $e');
    logger.e('Stack: $stack');
  }
  
  try {
    logger.i('🎬 Launching app...');
    runApp(const MyApp());
  } catch (e) {
    logger.e('❌ App launch error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Prashant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      getPages: AppRoutes.routes,
      initialRoute: AppRoutes.splash,
    );
  }
}
