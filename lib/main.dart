import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/themes/app_theme.dart';
import 'core/services/database_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/sharing_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  await _initServices();

  runApp(const AdaatApp());
}

/// Initialize all app services
Future<void> _initServices() async {
  // Database service
  Get.put(DatabaseService(), permanent: true);

  // Notification service
  final notificationService = NotificationService();
  await notificationService.init();
  Get.put(notificationService, permanent: true);

  // Sharing service
  Get.put(SharingService(), permanent: true);
}

class AdaatApp extends StatelessWidget {
  const AdaatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Adaat',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Routes
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,

      // Default transition
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}
