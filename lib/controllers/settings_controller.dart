import 'package:get/get.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../database_helper.dart';

class SettingsController extends GetxController {
  final recordFrequency = '10'.obs;
  final logStorageLocation = 'Documents/SpeedCheck/Logs'.obs;
  final logStorageFormat = 'SQLite'.obs;
  final logNamingConvention = 'speedcheck_log_TIMESTAMP'.obs;
  final autoPurgeLogs = true.obs;
  final syncOnlyWifi = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final db = DatabaseHelper.instance;
    recordFrequency.value = await db.getSetting('record_frequency', '10');
    logStorageLocation.value = await db.getSetting('log_storage_location', 'Documents/SpeedCheck/Logs');
    logStorageFormat.value = await db.getSetting('log_storage_format', 'SQLite');
    logNamingConvention.value = await db.getSetting('log_naming_convention', 'speedcheck_log_TIMESTAMP');
    autoPurgeLogs.value = (await db.getSetting('auto_purge_logs', 'true')) == 'true';
    syncOnlyWifi.value = (await db.getSetting('sync_only_wifi', 'false')) == 'true';
  }

  Future<void> updateSetting(String key, String value) async {
    final db = DatabaseHelper.instance;
    await db.setSetting(key, value);
    
    // Notify background service
    final service = FlutterBackgroundService();
    service.invoke('updateSettings');
  }

  Future<void> setRecordFrequency(String value) async {
    recordFrequency.value = value;
    await updateSetting('record_frequency', value);
  }

  Future<void> setLogStorageLocation(String value) async {
    logStorageLocation.value = value;
    await updateSetting('log_storage_location', value);
  }

  Future<void> setLogStorageFormat(String value) async {
    logStorageFormat.value = value;
    await updateSetting('log_storage_format', value);
  }

  Future<void> setLogNamingConvention(String value) async {
    logNamingConvention.value = value;
    await updateSetting('log_naming_convention', value);
  }

  Future<void> setAutoPurgeLogs(bool value) async {
    autoPurgeLogs.value = value;
    await updateSetting('auto_purge_logs', value.toString());
  }

  Future<void> setSyncOnlyWifi(bool value) async {
    syncOnlyWifi.value = value;
    await updateSetting('sync_only_wifi', value.toString());
  }
}
