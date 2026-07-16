import 'dart:convert';

class TelemetryModel {
  final int? id;
  final String timestamp;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final double? speed;
  final String? carrierName;
  final String? networkType; // WiFi, Cellular, None
  final String? technology;  // 2G, 3G, 4G, 5G SA, 5G NSA, Unknown
  
  // General Identifiers
  final String? mcc;
  final String? mnc;
  final String? dataState;
  final String? registeredState; // serving
  final String? imei;
  
  // 5G NR Parameters
  final int? ssRsrp;
  final int? ssRsrq;
  final int? ssSinr;
  final int? csiRsrp;
  final int? csiRsrq;
  final int? csiSinr;
  final String? nci;
  final int? pci5g;
  final int? tac5g;
  final int? nrarfcn;
  final String? nrBand;
  final int? nrBandwidth;
  final int? nrBwp;
  final int? asu5g;
  final int? nrCqi;
  final int? nrCqiTableIndex;

  // 4G LTE Parameters
  final int? rsrp4g;
  final int? rsrq4g;
  final int? rssi4g;
  final int? rssnr4g;
  final int? lteCqi;
  final int? timingAdvance;
  final int? ci4g;
  final int? pci4g;
  final int? tac4g;
  final int? earfcn4g;
  final String? lteBand;
  final int? lteBandwidth;
  final int? asu4g;
  final double? calculatedDistance;
  
  // 3G WCDMA Parameters
  final int? rscp3g;
  final int? ecNo3g;
  final int? lac3g;
  final int? ucid3g;
  final int? psc3g;
  final int? uarfcn3g;
  final int? asu3g;

  // 2G GSM Parameters
  final int? rssi2g;
  final int? rxQual2g;
  final int? lac2g;
  final int? cid2g;
  final int? bsic2g;
  final int? arfcn2g;
  final int? asu2g;

  // Neighbor Cells & Derived Metrics
  final List<Map<String, dynamic>> neighborCells;
  final int? ppi;
  final String? ppiState;
  final double? dominanceMargin;
  final int? pingPongIndex;
  final double? rfAsymmetryIndex;

  // Speed test parameters
  final double? downloadSpeed;
  final double? uploadSpeed;
  final double? ping;
  final double? jitter;
  final double? packetLoss;
  
  final String deviceModel;
  final String androidVersion;
  final bool synced;

  TelemetryModel({
    this.id,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.speed,
    this.carrierName,
    this.networkType,
    this.technology,
    this.mcc,
    this.mnc,
    this.dataState,
    this.registeredState,
    this.imei,
    this.ssRsrp,
    this.ssRsrq,
    this.ssSinr,
    this.csiRsrp,
    this.csiRsrq,
    this.csiSinr,
    this.nci,
    this.pci5g,
    this.tac5g,
    this.nrarfcn,
    this.nrBand,
    this.nrBandwidth,
    this.nrBwp,
    this.asu5g,
    this.nrCqi,
    this.nrCqiTableIndex,
    this.rsrp4g,
    this.rsrq4g,
    this.rssi4g,
    this.rssnr4g,
    this.lteCqi,
    this.timingAdvance,
    this.ci4g,
    this.pci4g,
    this.tac4g,
    this.earfcn4g,
    this.lteBand,
    this.lteBandwidth,
    this.asu4g,
    this.calculatedDistance,
    this.rscp3g,
    this.ecNo3g,
    this.lac3g,
    this.ucid3g,
    this.psc3g,
    this.uarfcn3g,
    this.asu3g,
    this.rssi2g,
    this.rxQual2g,
    this.lac2g,
    this.cid2g,
    this.bsic2g,
    this.arfcn2g,
    this.asu2g,
    required this.neighborCells,
    this.ppi,
    this.ppiState,
    this.dominanceMargin,
    this.pingPongIndex,
    this.rfAsymmetryIndex,
    this.downloadSpeed,
    this.uploadSpeed,
    this.ping,
    this.jitter,
    this.packetLoss,
    required this.deviceModel,
    required this.androidVersion,
    this.synced = false,
  });

  // Convert model to JSON map for SQLite DB
  Map<String, dynamic> toDbMap() {
    return {
      if (id != null) 'id': id,
      'timestamp': timestamp,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'speed': speed,
      'carrier_name': carrierName,
      'network_type': networkType,
      'technology': technology,
      'mcc': mcc,
      'mnc': mnc,
      'data_state': dataState,
      'registered_state': registeredState,
      'imei': imei,
      'ss_rsrp': ssRsrp,
      'ss_rsrq': ssRsrq,
      'ss_sinr': ssSinr,
      'csi_rsrp': csiRsrp,
      'csi_rsrq': csiRsrq,
      'csi_sinr': csiSinr,
      'nci': nci,
      'pci_5g': pci5g,
      'tac_5g': tac5g,
      'nrarfcn': nrarfcn,
      'nr_band': nrBand,
      'nr_bandwidth': nrBandwidth,
      'nr_bwp': nrBwp,
      'asu_5g': asu5g,
      'nr_cqi': nrCqi,
      'nr_cqi_table_index': nrCqiTableIndex,
      'rsrp_4g': rsrp4g,
      'rsrq_4g': rsrq4g,
      'rssi_4g': rssi4g,
      'rssnr_4g': rssnr4g,
      'lte_cqi': lteCqi,
      'timing_advance': timingAdvance,
      'ci_4g': ci4g,
      'pci_4g': pci4g,
      'tac_4g': tac4g,
      'earfcn_4g': earfcn4g,
      'lte_band': lteBand,
      'lte_bandwidth': lteBandwidth,
      'asu_4g': asu4g,
      'calculated_distance': calculatedDistance,
      'rscp_3g': rscp3g,
      'ec_no_3g': ecNo3g,
      'lac_3g': lac3g,
      'ucid_3g': ucid3g,
      'psc_3g': psc3g,
      'uarfcn_3g': uarfcn3g,
      'asu_3g': asu3g,
      'rssi_2g': rssi2g,
      'rx_qual_2g': rxQual2g,
      'lac_2g': lac2g,
      'cid_2g': cid2g,
      'bsic_2g': bsic2g,
      'arfcn_2g': arfcn2g,
      'asu_2g': asu2g,
      'neighbor_cells': jsonEncode(neighborCells),
      'ppi': ppi,
      'ppi_state': ppiState,
      'dominance_margin': dominanceMargin,
      'ping_pong_index': pingPongIndex,
      'rf_asymmetry_index': rfAsymmetryIndex,
      'download_speed': downloadSpeed,
      'upload_speed': uploadSpeed,
      'ping': ping,
      'jitter': jitter,
      'packet_loss': packetLoss,
      'device_model': deviceModel,
      'android_version': androidVersion,
      'synced': synced ? 1 : 0,
    };
  }

  // Read model from SQLite DB row
  factory TelemetryModel.fromDbMap(Map<String, dynamic> map) {
    List<Map<String, dynamic>> decodedNeighbors = [];
    try {
      if (map['neighbor_cells'] != null) {
        final decoded = jsonDecode(map['neighbor_cells'] as String);
        if (decoded is List) {
          decodedNeighbors = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
    } catch (_) {}

    return TelemetryModel(
      id: map['id'] as int?,
      timestamp: map['timestamp'] as String,
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      accuracy: map['accuracy'] != null ? (map['accuracy'] as num).toDouble() : null,
      speed: map['speed'] != null ? (map['speed'] as num).toDouble() : null,
      carrierName: map['carrier_name'] as String?,
      networkType: map['network_type'] as String?,
      technology: map['technology'] as String?,
      mcc: map['mcc'] as String?,
      mnc: map['mnc'] as String?,
      dataState: map['data_state'] as String?,
      registeredState: map['registered_state'] as String?,
      imei: map['imei'] as String?,
      ssRsrp: map['ss_rsrp'] as int?,
      ssRsrq: map['ss_rsrq'] as int?,
      ssSinr: map['ss_sinr'] as int?,
      csiRsrp: map['csi_rsrp'] as int?,
      csiRsrq: map['csi_rsrq'] as int?,
      csiSinr: map['csi_sinr'] as int?,
      nci: map['nci'] as String?,
      pci5g: map['pci_5g'] as int?,
      tac5g: map['tac_5g'] as int?,
      nrarfcn: map['nrarfcn'] as int?,
      nrBand: map['nr_band'] as String?,
      nrBandwidth: map['nr_bandwidth'] as int?,
      nrBwp: map['nr_bwp'] as int?,
      asu5g: map['asu_5g'] as int?,
      nrCqi: map['nr_cqi'] as int?,
      nrCqiTableIndex: map['nr_cqi_table_index'] as int?,
      rsrp4g: map['rsrp_4g'] as int?,
      rsrq4g: map['rsrq_4g'] as int?,
      rssi4g: map['rssi_4g'] as int?,
      rssnr4g: map['rssnr_4g'] as int?,
      lteCqi: map['lte_cqi'] as int?,
      timingAdvance: map['timing_advance'] as int?,
      ci4g: map['ci_4g'] as int?,
      pci4g: map['pci_4g'] as int?,
      tac4g: map['tac_4g'] as int?,
      earfcn4g: map['earfcn_4g'] as int?,
      lteBand: map['lte_band'] as String?,
      lteBandwidth: map['lte_bandwidth'] as int?,
      asu4g: map['asu_4g'] as int?,
      calculatedDistance: map['calculated_distance'] != null ? (map['calculated_distance'] as num).toDouble() : null,
      rscp3g: map['rscp_3g'] as int?,
      ecNo3g: map['ec_no_3g'] as int?,
      lac3g: map['lac_3g'] as int?,
      ucid3g: map['ucid_3g'] as int?,
      psc3g: map['psc_3g'] as int?,
      uarfcn3g: map['uarfcn_3g'] as int?,
      asu3g: map['asu_3g'] as int?,
      rssi2g: map['rssi_2g'] as int?,
      rxQual2g: map['rx_qual_2g'] as int?,
      lac2g: map['lac_2g'] as int?,
      cid2g: map['cid_2g'] as int?,
      bsic2g: map['bsic_2g'] as int?,
      arfcn2g: map['arfcn_2g'] as int?,
      asu2g: map['asu_2g'] as int?,
      neighborCells: decodedNeighbors,
      ppi: map['ppi'] as int?,
      ppiState: map['ppi_state'] as String?,
      dominanceMargin: map['dominance_margin'] != null ? (map['dominance_margin'] as num).toDouble() : null,
      pingPongIndex: map['ping_pong_index'] as int?,
      rfAsymmetryIndex: map['rf_asymmetry_index'] != null ? (map['rf_asymmetry_index'] as num).toDouble() : null,
      downloadSpeed: map['download_speed'] != null ? (map['download_speed'] as num).toDouble() : null,
      uploadSpeed: map['upload_speed'] != null ? (map['upload_speed'] as num).toDouble() : null,
      ping: map['ping'] != null ? (map['ping'] as num).toDouble() : null,
      jitter: map['jitter'] != null ? (map['jitter'] as num).toDouble() : null,
      packetLoss: map['packet_loss'] != null ? (map['packet_loss'] as num).toDouble() : null,
      deviceModel: map['device_model'] as String? ?? 'Unknown',
      androidVersion: map['android_version'] as String? ?? 'Unknown',
      synced: map['synced'] == 1,
    );
  }

  // Convert model to API payload JSON format
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'speed': speed,
      'carrier_name': carrierName,
      'network_type': networkType,
      'technology': technology,
      'mcc': mcc,
      'mnc': mnc,
      'data_state': dataState,
      'registered_state': registeredState,
      'imei': imei,
      'ss_rsrp': ssRsrp,
      'ss_rsrq': ssRsrq,
      'ss_sinr': ssSinr,
      'csi_rsrp': csiRsrp,
      'csi_rsrq': csiRsrq,
      'csi_sinr': csiSinr,
      'nci': nci,
      'pci_5g': pci5g,
      'tac_5g': tac5g,
      'nrarfcn': nrarfcn,
      'nr_band': nrBand,
      'nr_bandwidth': nrBandwidth,
      'nr_bwp': nrBwp,
      'asu_5g': asu5g,
      'nr_cqi': nrCqi,
      'nr_cqi_table_index': nrCqiTableIndex,
      'rsrp_4g': rsrp4g,
      'rsrq_4g': rsrq4g,
      'rssi_4g': rssi4g,
      'rssnr_4g': rssnr4g,
      'lte_cqi': lteCqi,
      'timing_advance': timingAdvance,
      'ci_4g': ci4g,
      'pci_4g': pci4g,
      'tac_4g': tac4g,
      'earfcn_4g': earfcn4g,
      'lte_band': lteBand,
      'lte_bandwidth': lteBandwidth,
      'asu_4g': asu4g,
      'calculated_distance': calculatedDistance,
      'rscp_3g': rscp3g,
      'ec_no_3g': ecNo3g,
      'lac_3g': lac3g,
      'ucid_3g': ucid3g,
      'psc_3g': psc3g,
      'uarfcn_3g': uarfcn3g,
      'asu_3g': asu3g,
      'rssi_2g': rssi2g,
      'rx_qual_2g': rxQual2g,
      'lac_2g': lac2g,
      'cid_2g': cid2g,
      'bsic_2g': bsic2g,
      'arfcn_2g': arfcn2g,
      'asu_2g': asu2g,
      'neighbor_cells': neighborCells,
      'ppi': ppi,
      'ppi_state': ppiState,
      'dominance_margin': dominanceMargin,
      'ping_pong_index': pingPongIndex,
      'rf_asymmetry_index': rfAsymmetryIndex,
      'download_speed': downloadSpeed,
      'upload_speed': uploadSpeed,
      'ping': ping,
      'jitter': jitter,
      'packet_loss': packetLoss,
      'device_model': deviceModel,
      'android_version': androidVersion,
    };
  }

  int? get rsrp {
    if (technology == null) return null;
    if (technology!.contains('5G')) return ssRsrp ?? csiRsrp;
    if (technology == '4G') return rsrp4g;
    if (technology == '3G') return rscp3g;
    if (technology == '2G') return rssi2g;
    return null;
  }

  int? get rsrq {
    if (technology == null) return null;
    if (technology!.contains('5G')) return ssRsrq ?? csiRsrq;
    if (technology == '4G') return rsrq4g;
    if (technology == '3G') return ecNo3g;
    return null;
  }

  int? get rssi {
    if (technology == null) return null;
    if (technology == '4G') return rssi4g;
    if (technology == '2G') return rssi2g;
    return null;
  }

  int? get rssnr {
    if (technology == null) return null;
    if (technology!.contains('5G')) return ssSinr ?? csiSinr;
    if (technology == '4G') return rssnr4g;
    return null;
  }

  int? get asuLevel {
    if (technology == null) return null;
    if (technology!.contains('5G')) return asu5g;
    if (technology == '4G') return asu4g;
    if (technology == '3G') return asu3g;
    if (technology == '2G') return asu2g;
    return null;
  }

  String? get cellId {
    if (technology == null) return null;
    if (technology!.contains('5G')) return nci;
    if (technology == '4G') return ci4g?.toString();
    if (technology == '3G') return ucid3g?.toString();
    if (technology == '2G') return cid2g?.toString();
    return null;
  }

  int? get pci {
    if (technology == null) return null;
    if (technology!.contains('5G')) return pci5g;
    if (technology == '4G') return pci4g;
    if (technology == '3G') return psc3g;
    return null;
  }

  int? get tac {
    if (technology == null) return null;
    if (technology!.contains('5G')) return tac5g;
    if (technology == '4G') return tac4g;
    if (technology == '3G') return lac3g;
    if (technology == '2G') return lac2g;
    return null;
  }

  int? get earfcn {
    if (technology == null) return null;
    if (technology!.contains('5G')) return nrarfcn;
    if (technology == '4G') return earfcn4g;
    if (technology == '3G') return uarfcn3g;
    if (technology == '2G') return arfcn2g;
    return null;
  }
}
