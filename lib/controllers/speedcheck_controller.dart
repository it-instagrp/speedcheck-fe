import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../background_service.dart';
import '../database_helper.dart';
import '../telemetry_model.dart';

class SpeedCheckController extends GetxController {
  final RxBool isLoggingRunning = false.obs;
  final RxBool isSyncing = false.obs;
  final RxInt unsyncedCount = 0.obs;
  final Rxn<TelemetryModel> latestTelemetry = Rxn<TelemetryModel>();
  final RxList<TelemetryModel> historyLogs = <TelemetryModel>[].obs;

  StreamSubscription? _serviceSubscription;

  @override
  void onInit() {
    super.onInit();
    checkServiceStatus();
    loadHistory();
    listenToServiceUpdates();
  }

  @override
  void onClose() {
    _serviceSubscription?.cancel();
    super.onClose();
  }

  // Check if background service is currently active
  Future<void> checkServiceStatus() async {
    final service = FlutterBackgroundService();
    final running = await service.isRunning();
    isLoggingRunning.value = running;

    final count = await DatabaseHelper.instance.getUnsyncedCount();
    unsyncedCount.value = count;
  }

  // Listen to telemetry updates streamed from the background service
  void listenToServiceUpdates() {
    final service = FlutterBackgroundService();

    _serviceSubscription = service.on('update').listen((event) {
      if (event != null) {
        final log = TelemetryModel.fromDbMap(Map<String, dynamic>.from(event));
        latestTelemetry.value = log;

        if (event.containsKey('unsynced_count')) {
          unsyncedCount.value = event['unsynced_count'] as int;
        }

        // Prepends the new log to history for real-time chart updating
        historyLogs.insert(0, log);
        if (historyLogs.length > 50) {
          historyLogs.removeLast(); // Keep memory usage low
        }
        historyLogs.refresh();
      }
    });
  }

  // Fetch recent log history from database
  Future<void> loadHistory() async {
    try {
      final logs = await DatabaseHelper.instance.getAllLogs(limit: 50);
      historyLogs.assignAll(logs);
      if (logs.isNotEmpty && latestTelemetry.value == null) {
        latestTelemetry.value = logs.first;
      }
      final count = await DatabaseHelper.instance.getUnsyncedCount();
      unsyncedCount.value = count;
    } catch (e) {
      print('loadHistory error: $e');
    }
  }

  // Request Fine Location and Notification permissions
  Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // Request Notification permission (Android 13+ requirement for foreground service)
    final notificationStatus = await Permission.notification.status;
    if (notificationStatus.isDenied) {
      final requestResult = await Permission.notification.request();
      if (requestResult.isDenied) {
        return false;
      }
    }

    return true;
  }

  // Toggle Background Service (Start/Stop Test)
  Future<bool> toggleService() async {
    final service = FlutterBackgroundService();
    final running = await service.isRunning();

    if (running) {
      // Stop the service
      service.invoke('stopService');
      isLoggingRunning.value = false;
      return false;
    } else {
      // Request permission first
      final hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) {
        throw Exception('Location permission is required to start logging.');
      }

      // Start the service
      final success = await service.startService();
      isLoggingRunning.value = success;
      return success;
    }
  }

  // Trigger manual synchronization of unsynced records
  Future<bool> syncData() async {
    if (isSyncing.value) return false;

    isSyncing.value = true;
    try {
      final success = await performSync();
      await loadHistory(); // Reload logs & count
      return success;
    } catch (e) {
      print('syncData error: $e');
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  // Clear local DB tables
  Future<void> clearAllData() async {
    await DatabaseHelper.instance.clearAllLogs();
    latestTelemetry.value = null;
    historyLogs.clear();
    unsyncedCount.value = 0;
  }
}
