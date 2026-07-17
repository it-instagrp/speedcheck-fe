import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'telemetry_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('speedcheck.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE speedcheck_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        accuracy REAL,
        speed REAL,
        carrier_name TEXT,
        network_type TEXT,
        technology TEXT,
        mcc TEXT,
        mnc TEXT,
        data_state TEXT,
        registered_state TEXT,
        imei TEXT,
        ss_rsrp INTEGER,
        ss_rsrq INTEGER,
        ss_sinr INTEGER,
        csi_rsrp INTEGER,
        csi_rsrq INTEGER,
        csi_sinr INTEGER,
        nci TEXT,
        pci_5g INTEGER,
        tac_5g INTEGER,
        nrarfcn INTEGER,
        nr_band TEXT,
        nr_bandwidth INTEGER,
        nr_bwp INTEGER,
        asu_5g INTEGER,
        nr_cqi INTEGER,
        nr_cqi_table_index INTEGER,
        rsrp_4g INTEGER,
        rsrq_4g INTEGER,
        rssi_4g INTEGER,
        rssnr_4g INTEGER,
        lte_cqi INTEGER,
        timing_advance INTEGER,
        ci_4g INTEGER,
        pci_4g INTEGER,
        tac_4g INTEGER,
        earfcn_4g INTEGER,
        lte_band TEXT,
        lte_bandwidth INTEGER,
        asu_4g INTEGER,
        calculated_distance REAL,
        rscp_3g INTEGER,
        ec_no_3g INTEGER,
        lac_3g INTEGER,
        ucid_3g INTEGER,
        psc_3g INTEGER,
        uarfcn_3g INTEGER,
        asu_3g INTEGER,
        rssi_2g INTEGER,
        rx_qual_2g INTEGER,
        lac_2g INTEGER,
        cid_2g INTEGER,
        bsic_2g INTEGER,
        arfcn_2g INTEGER,
        asu_2g INTEGER,
        neighbor_cells TEXT,
        ppi INTEGER,
        ppi_state TEXT,
        dominance_margin REAL,
        ping_pong_index INTEGER,
        rf_asymmetry_index REAL,
        download_speed REAL,
        upload_speed REAL,
        ping REAL,
        jitter REAL,
        packet_loss REAL,
        device_model TEXT,
        android_version TEXT,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS speedcheck_logs');
      await _createDB(db, newVersion);
    } else if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
    }
  }

  // Insert a new telemetry record
  Future<int> insertLog(TelemetryModel log) async {
    final db = await instance.database;
    return await db.insert('speedcheck_logs', log.toDbMap());
  }

  // Fetch all collected logs (newest first)
  Future<List<TelemetryModel>> getAllLogs({int? limit}) async {
    final db = await instance.database;
    final result = await db.query(
      'speedcheck_logs',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return result.map((json) => TelemetryModel.fromDbMap(json)).toList();
  }

  // Fetch only unsynced logs
  Future<List<TelemetryModel>> getUnsyncedLogs() async {
    final db = await instance.database;
    final result = await db.query(
      'speedcheck_logs',
      where: 'synced = 0',
      orderBy: 'timestamp ASC',
    );
    return result.map((json) => TelemetryModel.fromDbMap(json)).toList();
  }

  // Get total count of unsynced logs
  Future<int> getUnsyncedCount() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM speedcheck_logs WHERE synced = 0'
    );
    if (result.isNotEmpty) {
      return result.first['count'] as int;
    }
    return 0;
  }

  // Bulk mark logs as synced
  Future<int> markLogsAsSynced(List<int> ids) async {
    if (ids.isEmpty) return 0;
    final db = await instance.database;
    return await db.update(
      'speedcheck_logs',
      {'synced': 1},
      where: 'id IN (${ids.join(',')})',
    );
  }

  // Clear all synced logs (to free up space)
  Future<int> clearSyncedLogs() async {
    final db = await instance.database;
    return await db.delete(
      'speedcheck_logs',
      where: 'synced = 1',
    );
  }

  // Reset database (for testing)
  Future<int> clearAllLogs() async {
    final db = await instance.database;
    return await db.delete('speedcheck_logs');
  }

  // Get a setting value, returning a default if not found
  Future<String> getSetting(String key, String defaultValue) async {
    try {
      final db = await instance.database;
      final maps = await db.query(
        'settings',
        columns: ['value'],
        where: 'key = ?',
        whereArgs: [key],
      );
      if (maps.isNotEmpty) {
        return maps.first['value'] as String;
      }
    } catch (e) {
      print('Error getting setting $key: $e');
    }
    return defaultValue;
  }

  // Set a setting value
  Future<void> setSetting(String key, String value) async {
    try {
      final db = await instance.database;
      await db.insert(
        'settings',
        {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error setting $key: $e');
    }
  }

  // Purge logs older than X days
  Future<int> purgeLogsOlderThan(int days) async {
    try {
      final db = await instance.database;
      final cutoff = DateTime.now().subtract(Duration(days: days)).toIso8601String();
      return await db.delete(
        'speedcheck_logs',
        where: 'timestamp < ?',
        whereArgs: [cutoff],
      );
    } catch (e) {
      print('Error purging logs: $e');
      return 0;
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
