import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'background_service.dart';
import 'database_helper.dart';
import 'utils/onboarding_helper.dart';
import 'views/main_navigation_view.dart';
import 'views/onboarding_view.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel serviceChannel = AndroidNotificationChannel(
  'speedcheck_service_channel',
  'SpeedCheck Background Service',
  description: 'Background telemetry collection',
  importance: Importance.low,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Notifications
  const androidInitializationSettings = AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );

  const initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
  );

  // Create notification channel
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(serviceChannel);

  // Initialize SQLite
  await DatabaseHelper.instance.database;

  // Initialize Background Service
  await initializeBackgroundService();

  // Check onboarding status
  final hasCompleted = await OnboardingHelper.isCompleted();

  runApp(SpeedCheckApp(showOnboarding: !hasCompleted));
}

class SpeedCheckApp extends StatelessWidget {
  final bool showOnboarding;
  const SpeedCheckApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        title: 'SpeedCheck',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.cyan,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF111318),
        ),
        home: showOnboarding
            ? const OnboardingView()
            : const MainNavigationView(),
      ),
    );
  }
}
