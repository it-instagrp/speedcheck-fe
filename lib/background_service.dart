import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'constants.dart';
import 'database_helper.dart';
import 'telemetry_model.dart';
import 'speed_test_helper.dart';

const String cellChannelName = 'com.instagrp.speedcheck/cell_info';
const MethodChannel cellChannel = MethodChannel(cellChannelName);

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false, // User starts explicitly
      isForegroundMode: true,
      notificationChannelId: 'speedcheck_service_channel',
      initialNotificationTitle: 'SpeedCheck Service Active',
      initialNotificationContent: 'Monitoring telemetry in background...',
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

// Convert LTE EARFCN to Band Name
String getLteBand(int? earfcn) {
  if (earfcn == null) return 'N/A';
  if (earfcn >= 0 && earfcn <= 599) return 'B1';
  if (earfcn >= 600 && earfcn <= 1199) return 'B2';
  if (earfcn >= 1200 && earfcn <= 1949) return 'B3';
  if (earfcn >= 1950 && earfcn <= 2399) return 'B4';
  if (earfcn >= 2400 && earfcn <= 2649) return 'B5';
  if (earfcn >= 2750 && earfcn <= 3449) return 'B7';
  if (earfcn >= 3450 && earfcn <= 3799) return 'B8';
  if (earfcn >= 6150 && earfcn <= 6449) return 'B20';
  if (earfcn >= 9210 && earfcn <= 9659) return 'B28';
  if (earfcn >= 37750 && earfcn <= 38249) return 'B38';
  if (earfcn >= 38650 && earfcn <= 39649) return 'B40';
  if (earfcn >= 39650 && earfcn <= 41589) return 'B41';
  return 'B$earfcn';
}

// Convert NR NRARFCN to Band Name
String getNrBand(int? nrarfcn, List<dynamic>? systemBands) {
  if (systemBands != null && systemBands.isNotEmpty) {
    return 'n${systemBands.join(", n")}';
  }
  if (nrarfcn == null) return 'N/A';
  if (nrarfcn >= 422000 && nrarfcn <= 434000) return 'n1';
  if (nrarfcn >= 361000 && nrarfcn <= 376000) return 'n3';
  if (nrarfcn >= 173800 && nrarfcn <= 178800) return 'n5';
  if (nrarfcn >= 185000 && nrarfcn <= 189000) return 'n8';
  if (nrarfcn >= 151600 && nrarfcn <= 160600) return 'n28';
  if (nrarfcn >= 499200 && nrarfcn <= 537999) return 'n41';
  if (nrarfcn >= 620000 && nrarfcn <= 680000) return 'n77';
  if (nrarfcn >= 620000 && nrarfcn <= 653333) return 'n78';
  return 'n$nrarfcn';
}

// Derived Metrics Formulas
double? calculateDistance(int? ta) {
  if (ta == null || ta <= 0) return null;
  return ta * 78.12; // in meters
}

double? calculateDominanceMargin(
  int? servingRsrp,
  List<Map<String, dynamic>> neighbors,
  String? tech,
) {
  if (servingRsrp == null || neighbors.isEmpty) return null;
  int? maxNeighborRsrp;
  for (final neigh in neighbors) {
    if (neigh['tech'] == tech) {
      final rsrpVal = neigh['rsrp'] as int?;
      if (rsrpVal != null) {
        if (maxNeighborRsrp == null || rsrpVal > maxNeighborRsrp) {
          maxNeighborRsrp = rsrpVal;
        }
      }
    }
  }
  if (maxNeighborRsrp == null) return null;
  return (servingRsrp - maxNeighborRsrp).toDouble();
}

int calculatePpi(
  int? servingRsrp,
  List<Map<String, dynamic>> neighbors,
  String? tech,
) {
  if (servingRsrp == null) return 1;
  int count = 1; // serving cell itself
  for (final neigh in neighbors) {
    if (neigh['tech'] == tech) {
      final rsrpVal = neigh['rsrp'] as int?;
      if (rsrpVal != null && rsrpVal >= (servingRsrp - 6)) {
        count++;
      }
    }
  }
  return count;
}

Future<int> calculatePingPongIndex(String? currentCellId) async {
  if (currentCellId == null) return 0;
  try {
    final lastLogs = await DatabaseHelper.instance.getAllLogs(limit: 5);
    if (lastLogs.length < 3) return 0;

    final cellIds = [currentCellId];
    for (final log in lastLogs) {
      if (log.cellId != null) {
        cellIds.add(log.cellId!);
      }
    }

    int handovers = 0;
    for (int i = 1; i < cellIds.length; i++) {
      if (cellIds[i] != cellIds[i - 1]) {
        handovers++;
      }
    }
    return handovers;
  } catch (_) {
    return 0;
  }
}

double? calculateRfAsymmetry(int? rsrp, int? rssi) {
  if (rsrp == null || rssi == null) return null;
  return (rsrp - rssi).toDouble();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Load device metadata
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String model = 'Unknown';
  String osVersion = 'Unknown';
  bool isPhysicalDevice = true;
  try {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      model = '${androidInfo.brand} ${androidInfo.model}';
      osVersion = 'Android ${androidInfo.version.release}';
      isPhysicalDevice = androidInfo.isPhysicalDevice;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      model = iosInfo.utsname.machine;
      osVersion = 'iOS ${iosInfo.systemVersion}';
      isPhysicalDevice = iosInfo.isPhysicalDevice;
    }
  } catch (e) {
    print('Failed to get device info: $e');
  }

  Timer.periodic(const Duration(seconds: COLLECTION_FREQUENCY_SECONDS), (
    timer,
  ) async {
    try {
      // 1. Connectivity Type
      final connectivityResult = await Connectivity().checkConnectivity();
      String networkTypeStr = 'None';
      if (connectivityResult.contains(ConnectivityResult.wifi)) {
        networkTypeStr = 'WiFi';
      } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
        networkTypeStr = 'Cellular';
      }

      // Run Active Speed Diagnostics if connected to a valid network
      SpeedTestResult? speedResult;
      if (networkTypeStr != 'None') {
        try {
          speedResult = await SpeedTestHelper.runTest(useSimulation: false);
        } catch (e) {
          print('Speed test execution error: $e');
        }
      }

      // 2. GPS Positioning Fallbacks
      double? lat;
      double? lng;
      double? accuracy;
      double? gpsSpeed;
      try {
        Position? position;
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 4),
          );
        } catch (_) {
          position = await Geolocator.getLastKnownPosition();
        }

        if (position != null) {
          lat = position.latitude;
          lng = position.longitude;
          accuracy = position.accuracy;
          gpsSpeed = position.speed;
        }
      } catch (e) {
        print('GPS acquisition error: $e');
      }

      // 3. Telemetry Channel Pull
      Map<dynamic, dynamic>? nativeCellInfo;

      if (Platform.isAndroid) {
        try {
          final result = await cellChannel.invokeMethod('getCellInfo');
          if (result is Map) {
            nativeCellInfo = result;
          }
        } catch (e) {
          print('MethodChannel telephony error: $e');
        }
      }

      final String? carrier = nativeCellInfo?['carrierName'] as String?;
      final String? tech = nativeCellInfo?['technology'] as String?;
      final String? mcc = nativeCellInfo?['mcc'] as String?;
      final String? mnc = nativeCellInfo?['mnc'] as String?;
      final String? dataState = nativeCellInfo?['dataState'] as String?;
      final String? regState = nativeCellInfo?['registeredState'] as String?;
      final String? imei = nativeCellInfo?['imei'] as String?;

      // Parse Neighbors
      List<Map<String, dynamic>> neighbors = [];
      if (nativeCellInfo?['neighbors'] is List) {
        final List rawList = nativeCellInfo?['neighbors'] as List;
        neighbors = rawList
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }

      // Extract specific technology configurations
      int? ssRsrp,
          ssRsrq,
          ssSinr,
          csiRsrp,
          csiRsrq,
          csiSinr,
          pci5g,
          tac5g,
          nrarfcn,
          nrBandwidth,
          nrBwp,
          asu5g,
          nrCqi,
          nrCqiTableIndex;
      String? nci, nrBand;

      int? rsrp4g,
          rsrq4g,
          rssi4g,
          rssnr4g,
          lteCqi,
          timingAdvance,
          ci4g,
          pci4g,
          tac4g,
          earfcn4g,
          lteBandwidth,
          asu4g;
      String? lteBand;

      int? rscp3g, ecNo3g, lac3g, ucid3g, psc3g, uarfcn3g, asu3g;
      int? rssi2g, rxQual2g, lac2g, cid2g, bsic2g, arfcn2g, asu2g;

      String? activeCellId;
      int? activeRsrp;

      if (tech != null) {
        if (tech.contains('5G')) {
          activeCellId = nativeCellInfo?['nci']?.toString();
          nci = activeCellId;
          pci5g = nativeCellInfo?['pci'] as int?;
          tac5g = nativeCellInfo?['tac'] as int?;
          nrarfcn = nativeCellInfo?['nrarfcn'] as int?;

          final bandsList = nativeCellInfo?['bands'] as List?;
          nrBand = getNrBand(nrarfcn, bandsList);
          nrBandwidth = nativeCellInfo?['nrBandwidth'] as int?;
          nrBwp = nativeCellInfo?['nrBwp'] as int?;

          ssRsrp = nativeCellInfo?['ssRsrp'] as int?;
          ssRsrq = nativeCellInfo?['ssRsrq'] as int?;
          ssSinr = nativeCellInfo?['ssSinr'] as int?;
          csiRsrp = nativeCellInfo?['csiRsrp'] as int?;
          csiRsrq = nativeCellInfo?['csiRsrq'] as int?;
          csiSinr = nativeCellInfo?['csiSinr'] as int?;
          asu5g = nativeCellInfo?['asuLevel'] as int?;
          activeRsrp = ssRsrp ?? csiRsrp;

          final cqiList = nativeCellInfo?['cqiReport'] as List?;
          if (cqiList != null && cqiList.isNotEmpty) {
            nrCqi = cqiList.first as int?;
          }
          nrCqiTableIndex = nativeCellInfo?['cqiTableIndex'] as int?;
        } else if (tech == '4G') {
          activeCellId = nativeCellInfo?['ci']?.toString();
          ci4g = nativeCellInfo?['ci'] as int?;
          pci4g = nativeCellInfo?['pci'] as int?;
          tac4g = nativeCellInfo?['tac'] as int?;
          earfcn4g = nativeCellInfo?['earfcn'] as int?;
          lteBand = getLteBand(earfcn4g);

          final rawBw = nativeCellInfo?['bandwidth'] as int?;
          lteBandwidth = rawBw != null ? (rawBw / 1000).round() : null;

          rsrp4g = nativeCellInfo?['rsrp'] as int?;
          rsrq4g = nativeCellInfo?['rsrq'] as int?;
          rssi4g = nativeCellInfo?['rssi'] as int?;
          rssnr4g = nativeCellInfo?['rssnr'] as int?;
          asu4g = nativeCellInfo?['asuLevel'] as int?;
          timingAdvance = nativeCellInfo?['timingAdvance'] as int?;
          lteCqi = nativeCellInfo?['cqi'] as int?;
          activeRsrp = rsrp4g;
          activeCellId ??= ci4g?.toString();
        } else if (tech == '3G') {
          activeCellId =
              nativeCellInfo?['ucid']?.toString() ??
              nativeCellInfo?['cellId']?.toString();
          ucid3g = nativeCellInfo?['ucid'] as int?;
          psc3g = nativeCellInfo?['psc'] as int?;
          lac3g = nativeCellInfo?['lac'] as int?;
          uarfcn3g = nativeCellInfo?['uarfcn'] as int?;

          rscp3g = nativeCellInfo?['rscp'] as int?;
          ecNo3g = nativeCellInfo?['ecNo'] as int?;
          asu3g = nativeCellInfo?['asuLevel'] as int?;
          activeRsrp = rscp3g;
          activeCellId ??= ucid3g?.toString();
        } else if (tech == '2G') {
          activeCellId =
              nativeCellInfo?['cid']?.toString() ??
              nativeCellInfo?['cellId']?.toString();
          cid2g = nativeCellInfo?['cid'] as int?;
          bsic2g = nativeCellInfo?['bsic'] as int?;
          lac2g = nativeCellInfo?['lac'] as int?;
          arfcn2g = nativeCellInfo?['arfcn'] as int?;

          rssi2g = nativeCellInfo?['rssi'] as int?;
          final ber = nativeCellInfo?['bitErrorRate'] as int?;
          rxQual2g = ber;
          asu2g = nativeCellInfo?['asuLevel'] as int?;
          activeRsrp = rssi2g;
          activeCellId ??= cid2g?.toString();
        }
      }

      // 4. Calculate Derived KPIs
      final double? dist = calculateDistance(timingAdvance);
      final double? domMargin = calculateDominanceMargin(
        activeRsrp,
        neighbors,
        tech,
      );
      final int ppiVal = calculatePpi(activeRsrp, neighbors, tech);
      final String ppiStateStr = ppiVal >= 4 ? 'Polluted' : 'Clean';
      final int pingPong = await calculatePingPongIndex(activeCellId);

      double? asymmetry;
      if (tech == '4G') {
        asymmetry = calculateRfAsymmetry(rsrp4g, rssi4g);
      }

      // 6. Build Model using active runtime performance statistics
      final telemetry = TelemetryModel(
        timestamp: DateTime.now().toIso8601String(),
        latitude: lat,
        longitude: lng,
        accuracy: accuracy,
        speed: gpsSpeed,
        carrierName: carrier,
        networkType: networkTypeStr,
        technology: tech,
        mcc: mcc,
        mnc: mnc,
        dataState: dataState,
        registeredState: regState,
        imei: imei,

        // 5G NR
        ssRsrp: ssRsrp,
        ssRsrq: ssRsrq,
        ssSinr: ssSinr,
        csiRsrp: csiRsrp,
        csiRsrq: csiRsrq,
        csiSinr: csiSinr,
        nci: nci,
        pci5g: pci5g,
        tac5g: tac5g,
        nrarfcn: nrarfcn,
        nrBand: nrBand,
        nrBandwidth: nrBandwidth,
        nrBwp: nrBwp,
        asu5g: asu5g,
        nrCqi: nrCqi,
        nrCqiTableIndex: nrCqiTableIndex,

        // 4G LTE
        rsrp4g: rsrp4g,
        rsrq4g: rsrq4g,
        rssi4g: rssi4g,
        rssnr4g: rssnr4g,
        lteCqi: lteCqi,
        timingAdvance: timingAdvance,
        ci4g: ci4g,
        pci4g: pci4g,
        tac4g: tac4g,
        earfcn4g: earfcn4g,
        lteBand: lteBand,
        lteBandwidth: lteBandwidth,
        asu4g: asu4g,
        calculatedDistance: dist,

        // 3G WCDMA
        rscp3g: rscp3g,
        ecNo3g: ecNo3g,
        lac3g: lac3g,
        ucid3g: ucid3g,
        psc3g: psc3g,
        uarfcn3g: uarfcn3g,
        asu3g: asu3g,

        // 2G GSM
        rssi2g: rssi2g,
        rxQual2g: rxQual2g,
        lac2g: lac2g,
        cid2g: cid2g,
        bsic2g: bsic2g,
        arfcn2g: arfcn2g,
        asu2g: asu2g,

        neighborCells: neighbors,
        ppi: ppiVal,
        ppiState: ppiStateStr,
        dominanceMargin: domMargin,
        pingPongIndex: pingPong,
        rfAsymmetryIndex: asymmetry,

        // Populated KPIs matching schema constraints
        downloadSpeed: speedResult?.downloadSpeed,
        uploadSpeed: speedResult?.uploadSpeed,
        ping: speedResult?.ping,
        jitter: speedResult?.jitter,
        packetLoss: speedResult?.packetLoss,
        deviceModel: model,
        androidVersion: osVersion,
        synced: false,
      );

      // Save database log
      final insertedId = await DatabaseHelper.instance.insertLog(telemetry);

      // Auto Sync if connected
      bool syncSuccessful = false;
      if (networkTypeStr != 'None') {
        syncSuccessful = await performSync();
      }

      final unsyncedCount = await DatabaseHelper.instance.getUnsyncedCount();

      // Emit parameters map to dashboard isolate
      final Map<String, dynamic> updateData = telemetry.toDbMap();
      updateData['id'] = insertedId;
      updateData['unsynced_count'] = unsyncedCount;
      updateData['sync_success'] = syncSuccessful;

      service.invoke('update', updateData);

      // Update Foreground persistent notification info
      if (service is AndroidServiceInstance) {
        String networkSummary = networkTypeStr == 'Cellular'
            ? '$tech ($carrier)'
            : networkTypeStr;
        service.setForegroundNotificationInfo(
          title: 'SpeedCheck Telemetry Active',
          content: 'Net: $networkSummary | Unsynced: $unsyncedCount',
        );
      }
    } catch (e) {
      print('Background collect loop error: $e');
    }
  });
}

// Global sync execution
Future<bool> performSync() async {
  try {
    final dbHelper = DatabaseHelper.instance;
    final unsynced = await dbHelper.getUnsyncedLogs();
    if (unsynced.isEmpty) return true;

    // Build JSON file contents
    final List<Map<String, dynamic>> logsJson = unsynced
        .map((log) => log.toJson())
        .toList();
    final String jsonContent = jsonEncode(logsJson);

    // Save JSON to temporary path
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
      p.join(
        tempDir.path,
        'speedcheck_log_${DateTime.now().millisecondsSinceEpoch}.json',
      ),
    );
    await tempFile.writeAsString(jsonContent);

    // Multipart upload
    final uri = Uri.parse('$API_BASE_URL$API_SYNC_ENDPOINT');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath(
        'log',
        tempFile.path,
        filename: p.basename(tempFile.path),
      ),
    );

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 15),
    );
    final response = await http.Response.fromStream(streamedResponse);

    // Cleanup file
    if (await tempFile.exists()) {
      await tempFile.delete();
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<int> ids = unsynced.map((log) => log.id!).toList();
      await dbHelper.markLogsAsSynced(ids);
      return true;
    } else {
      print(
        'Multipart sync failed: ${response.statusCode} -> ${response.body}',
      );
      return false;
    }
  } catch (e) {
    print('performSync error: $e');
    return false;
  }
}
