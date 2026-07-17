import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import '../controllers/speedcheck_controller.dart';
import '../telemetry_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SpeedCheckController());
    final toastification = Toastification();

    return Scaffold(
      backgroundColor: const Color(0xFF111318), // Midnight Dark background
      body: SafeArea(
        child: Column(
          children: [
            // 1. App Header
            _buildHeader(context, controller),

            // 2. Main Scrollable Dashboard
            Expanded(
              child: Obx(() {
                final log = controller.latestTelemetry.value;
                if (log == null) {
                  return _buildEmptyPlaceholder();
                }
                final tech = log.technology ?? 'Unknown';

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // GPS LOCATION & DEVICE
                      _buildSectionHeader(
                        Icons.location_searching_rounded,
                        'GPS LOCATION & DEVICE',
                      ),
                      const SizedBox(height: 8),
                      _buildGPSLocationDeviceCard(log),
                      const SizedBox(height: 12),

                      // 1. GENERAL & OPERATOR IDENTIFIERS
                      _buildSectionHeader(
                        Icons.settings_input_component_rounded,
                        'GENERAL & OPERATOR IDENTIFIERS',
                      ),
                      const SizedBox(height: 8),
                      _buildGeneralOperatorCard(log),
                      const SizedBox(height: 12),

                      // SIGNAL TELEMETRY SECTION
                      _buildSectionHeader(
                        Icons.rss_feed_rounded,
                        'SIGNAL TELEMETRY',
                        liveBadge: true,
                      ),
                      const SizedBox(height: 8),
                      _buildSignalTelemetryGrid(log),
                      const SizedBox(height: 12),

                      // SIGNAL QUALITY SECTION
                      _buildSignalQualityCard(log),
                      const SizedBox(height: 12),

                      // 2. 5G NR PARAMETERS
                      if (tech.contains('5G')) ...[
                        _buildSectionHeader(
                          Icons.settings_input_antenna_rounded,
                          '5G NR PARAMETERS',
                        ),
                        const SizedBox(height: 8),
                        _build5gNrCard(log),
                        const SizedBox(height: 12),
                      ],

                      // 3. 4G LTE PARAMETERS
                      if (tech == '4G' || tech.contains('NSA')) ...[
                        _buildSectionHeader(
                          Icons.settings_input_antenna_rounded,
                          '4G LTE PARAMETERS',
                        ),
                        const SizedBox(height: 8),
                        _build4gLteCard(log),
                        const SizedBox(height: 12),
                      ],

                      // 4. 3G WCDMA / UMTS PARAMETERS
                      if (tech == '3G') ...[
                        _buildSectionHeader(
                          Icons.settings_input_antenna_rounded,
                          '3G WCDMA / UMTS PARAMETERS',
                        ),
                        const SizedBox(height: 8),
                        _build3gWcdmaCard(log),
                        const SizedBox(height: 12),
                      ],

                      // 5. 2G GSM PARAMETERS
                      if (tech == '2G') ...[
                        _buildSectionHeader(
                          Icons.settings_input_antenna_rounded,
                          '2G GSM PARAMETERS',
                        ),
                        const SizedBox(height: 8),
                        _build2gGsmCard(log),
                        const SizedBox(height: 12),
                      ],

                      const SizedBox(height: 12),

                      // SPEED DIAGNOSTICS
                      if (log.downloadSpeed != null ||
                          log.uploadSpeed != null) ...[
                        _buildSectionHeader(
                          Icons.speed_rounded,
                          'SPEED DIAGNOSTICS',
                        ),
                        const SizedBox(height: 8),
                        _buildSpeedDiagnosticsCard(log),
                        const SizedBox(height: 12),
                      ],

                      // TELEMETRY EVENTS
                      _buildSectionHeader(
                        Icons.list_alt_rounded,
                        'TELEMETRY EVENTS',
                      ),
                      const SizedBox(height: 8),
                      _buildEventsCard(controller),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              }),
            ),

            // 3. Bottom Control Deck (Sync / Start Test)
            _buildControlDeck(context, controller, toastification),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1C20),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF3B494B), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.radar_rounded, color: Color(0xFF00F0FF), size: 48),
            SizedBox(height: 16),
            Text(
              '[ SYSTEM STATE: IDLE ]',
              style: TextStyle(
                color: Color(0xFF00F0FF),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'JetBrains Mono',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No diagnostic telemetry logs found. Trigger START TEST to begin background signal sampling.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF849495),
                fontSize: 12,
                fontFamily: 'Inter',
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryContainer(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF3B494B), width: 1),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildGeneralOperatorCard(TelemetryModel log) {
    final List<Widget> children = [];

    final regState = log.registeredState ?? 'serving';
    children.add(_buildRowDetail('Registered State', regState));
    children.add(
      _buildRowDetail('Carrier / Operator Name', log.carrierName ?? 'N/A'),
    );
    children.add(
      _buildRowDetail('Mobile Country Code (MCC)', log.mcc ?? 'N/A'),
    );
    children.add(
      _buildRowDetail('Mobile Network Code (MNC)', log.mnc ?? 'N/A'),
    );
    children.add(
      _buildRowDetail('Data Connection State', log.dataState ?? 'N/A'),
    );
    children.add(
      _buildRowDetail('Network Type / Mode', log.technology ?? 'N/A'),
    );

    return _buildCategoryContainer(children);
  }

  Widget _build5gNrCard(TelemetryModel log) {
    final List<Widget> children = [];

    children.add(
      _buildRowDetail(
        'SS-RSRP',
        log.ssRsrp != null ? '${log.ssRsrp} dBm' : 'N/A',
      ),
    );
    children.add(
      _buildRowDetail(
        'SS-RSRQ',
        log.ssRsrq != null ? '${log.ssRsrq} dB' : 'N/A',
      ),
    );
    children.add(
      _buildRowDetail(
        'SS-SINR',
        log.ssSinr != null ? '${log.ssSinr} dB' : 'N/A',
      ),
    );
    children.add(
      _buildRowDetail(
        'CSI-RSRP',
        log.csiRsrp != null ? '${log.csiRsrp} dBm' : 'N/A',
      ),
    );
    children.add(
      _buildRowDetail(
        'CSI-RSRQ',
        log.csiRsrq != null ? '${log.csiRsrq} dB' : 'N/A',
      ),
    );
    children.add(
      _buildRowDetail(
        'CSI-SINR',
        log.csiSinr != null ? '${log.csiSinr} dB' : 'N/A',
      ),
    );
    children.add(_buildRowDetail('NCI', log.nci ?? 'N/A'));
    children.add(
      _buildRowDetail('PCI', log.pci5g != null ? '${log.pci5g}' : 'N/A'),
    );
    children.add(
      _buildRowDetail('TAC', log.tac5g != null ? '${log.tac5g}' : 'N/A'),
    );

    final nrarfcnStr = log.nrarfcn != null ? '${log.nrarfcn}' : 'N/A';
    final bandStr = log.nrBand ?? 'N/A';
    final bwStr = log.nrBandwidth != null ? '${log.nrBandwidth} MHz' : 'N/A';
    final bwpStr = log.nrBwp != null ? '${log.nrBwp}' : 'N/A';

    children.add(_buildRowDetail('NRARFCN', nrarfcnStr));
    children.add(_buildRowDetail('Band', bandStr));
    children.add(_buildRowDetail('Bandwidth', bwStr));
    children.add(_buildRowDetail('BWP', bwpStr));
    children.add(
      _buildRowDetail('ASU Level', log.asu5g != null ? '${log.asu5g}' : 'N/A'),
    );
    children.add(
      _buildRowDetail('CQI', log.nrCqi != null ? '${log.nrCqi}' : 'N/A'),
    );
    children.add(
      _buildRowDetail(
        'CQI Table Index',
        log.nrCqiTableIndex != null ? '${log.nrCqiTableIndex}' : 'N/A',
      ),
    );

    return _buildCategoryContainer(children);
  }

  Widget _build4gLteCard(TelemetryModel log) {
    final List<Widget> children = [];

    children.add(
      _buildRowDetail('RSRP', log.rsrp4g != null ? '${log.rsrp4g} dBm' : 'N/A'),
    );
    children.add(
      _buildRowDetail('RSRQ', log.rsrq4g != null ? '${log.rsrq4g} dB' : 'N/A'),
    );
    children.add(
      _buildRowDetail('RSSI', log.rssi4g != null ? '${log.rssi4g} dBm' : 'N/A'),
    );
    children.add(
      _buildRowDetail(
        'RSSNR',
        log.rssnr4g != null ? '${log.rssnr4g} dB' : 'N/A',
      ),
    );
    children.add(
      _buildRowDetail('CQI', log.lteCqi != null ? '${log.lteCqi}' : 'N/A'),
    );
    children.add(
      _buildRowDetail(
        'Timing Advance (TA)',
        log.timingAdvance != null ? '${log.timingAdvance}' : 'N/A',
      ),
    );
    children.add(
      _buildRowDetail('CI', log.ci4g != null ? '${log.ci4g}' : 'N/A'),
    );
    children.add(
      _buildRowDetail('PCI', log.pci4g != null ? '${log.pci4g}' : 'N/A'),
    );
    children.add(
      _buildRowDetail('TAC', log.tac4g != null ? '${log.tac4g}' : 'N/A'),
    );
    children.add(
      _buildRowDetail(
        'EARFCN',
        log.earfcn4g != null ? '${log.earfcn4g}' : 'N/A',
      ),
    );
    children.add(_buildRowDetail('Band', log.lteBand ?? 'N/A'));
    children.add(
      _buildRowDetail(
        'Channel Bandwidth',
        log.lteBandwidth != null ? '${log.lteBandwidth} MHz' : 'N/A',
      ),
    );
    children.add(
      _buildRowDetail('ASU Level', log.asu4g != null ? '${log.asu4g}' : 'N/A'),
    );

    final distStr = log.calculatedDistance != null
        ? '${log.calculatedDistance!.toStringAsFixed(1)} m'
        : 'N/A';
    children.add(_buildRowDetail('Distance to Base Station', distStr));

    return _buildCategoryContainer(children);
  }

  Widget _build3gWcdmaCard(TelemetryModel log) {
    final List<Widget> children = [];

    children.add(
      _buildRowDetail('RSCP', log.rscp3g != null ? '${log.rscp3g} dBm' : 'N/A'),
    );
    children.add(
      _buildRowDetail('Ec/No', log.ecNo3g != null ? '${log.ecNo3g} dB' : 'N/A'),
    );
    children.add(
      _buildRowDetail('LAC', log.lac3g != null ? '${log.lac3g}' : 'N/A'),
    );
    children.add(
      _buildRowDetail('UCID', log.ucid3g != null ? '${log.ucid3g}' : 'N/A'),
    );
    children.add(
      _buildRowDetail('PSC', log.psc3g != null ? '${log.psc3g}' : 'N/A'),
    );
    children.add(
      _buildRowDetail(
        'UARFCN',
        log.uarfcn3g != null ? '${log.uarfcn3g}' : 'N/A',
      ),
    );
    children.add(
      _buildRowDetail('ASU Level', log.asu3g != null ? '${log.asu3g}' : 'N/A'),
    );

    return _buildCategoryContainer(children);
  }

  Widget _build2gGsmCard(TelemetryModel log) {
    final List<Widget> children = [];

    children.add(
      _buildRowDetail('RSSI', log.rssi2g != null ? '${log.rssi2g} dBm' : 'N/A'),
    );
    children.add(
      _buildRowDetail(
        'RxQual (BER)',
        log.rxQual2g != null ? '${log.rxQual2g}' : 'N/A',
      ),
    );
    children.add(
      _buildRowDetail('LAC', log.lac2g != null ? '${log.lac2g}' : 'N/A'),
    );
    children.add(
      _buildRowDetail('CID', log.cid2g != null ? '${log.cid2g}' : 'N/A'),
    );
    children.add(
      _buildRowDetail('BSIC', log.bsic2g != null ? '${log.bsic2g}' : 'N/A'),
    );
    children.add(
      _buildRowDetail('ARFCN', log.arfcn2g != null ? '${log.arfcn2g}' : 'N/A'),
    );
    children.add(
      _buildRowDetail('ASU Level', log.asu2g != null ? '${log.asu2g}' : 'N/A'),
    );

    return _buildCategoryContainer(children);
  }

  Widget _buildGPSLocationDeviceCard(TelemetryModel log) {
    final gpsCoord = log.latitude != null && log.longitude != null
        ? '${log.latitude!.toStringAsFixed(6)}, ${log.longitude!.toStringAsFixed(6)}'
        : 'Acquiring...';
    final gpsAccSpeed =
        '${log.accuracy?.toStringAsFixed(1) ?? "0"}m / ${((log.speed ?? 0.0) * 3.6).toInt()} km/h';
    final timeStr = log.timestamp.split('T').join(' ').substring(0, 19);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF3B494B), width: 1),
      ),
      child: Column(
        children: [
          _buildRowDetail('GPS Coordinates', gpsCoord),
          const SizedBox(height: 8),
          _buildRowDetail('GPS Accuracy / Speed', gpsAccSpeed),
          const SizedBox(height: 8),
          _buildRowDetail('Device Hardware', log.deviceModel),
          const SizedBox(height: 8),
          _buildRowDetail('OS Version', log.androidVersion),
          const SizedBox(height: 8),
          _buildRowDetail('IMEI / Android ID', log.imei ?? 'N/A'),
          const SizedBox(height: 8),
          _buildRowDetail('Logged Timestamp', timeStr),
        ],
      ),
    );
  }

  Widget _buildSpeedDiagnosticsCard(TelemetryModel log) {
    final down = log.downloadSpeed != null
        ? '${log.downloadSpeed!.toStringAsFixed(1)} Mbps'
        : 'N/A';
    final up = log.uploadSpeed != null
        ? '${log.uploadSpeed!.toStringAsFixed(1)} Mbps'
        : 'N/A';
    final pingJitter =
        '${log.ping?.toStringAsFixed(1) ?? "0"} ms / ${log.jitter?.toStringAsFixed(1) ?? "0"} ms';
    final loss = log.packetLoss != null
        ? '${log.packetLoss!.toStringAsFixed(1)}%'
        : 'N/A';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF3B494B), width: 1),
      ),
      child: Column(
        children: [
          _buildRowDetail('Download Speed', down),
          const SizedBox(height: 8),
          _buildRowDetail('Upload Speed', up),
          const SizedBox(height: 8),
          _buildRowDetail('Ping / Jitter', pingJitter),
          const SizedBox(height: 8),
          _buildRowDetail('Packet Loss', loss),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    IconData icon,
    String title, {
    bool liveBadge = false,
    String? infoLabel,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF00F0FF), size: 14),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF849495),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                fontFamily: 'JetBrains Mono',
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
        if (liveBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00F0FF), width: 1),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.fiber_manual_record,
                  color: Color(0xFF00F0FF),
                  size: 8,
                ),
                SizedBox(width: 4),
                Text(
                  'LIVE LINK',
                  style: TextStyle(
                    color: Color(0xFF00F0FF),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ],
            ),
          )
        else if (infoLabel != null)
          Text(
            infoLabel,
            style: const TextStyle(
              color: Color(0xFF00F0FF),
              fontSize: 9,
              fontFamily: 'JetBrains Mono',
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, SpeedCheckController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0C0E12),
        border: Border(bottom: BorderSide(color: Color(0xFF1A1C20), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(
                Icons.cell_tower_rounded,
                color: Color(0xFF00F0FF),
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                'SpeedCheck',
                style: TextStyle(
                  color: Color(0xFF00F0FF),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Hanken Grotesk',
                ),
              ),
            ],
          ),
          IconButton(
            tooltip: 'Clear DB History',
            icon: const Icon(
              Icons.delete_sweep_outlined,
              color: Color(0xFF849495),
            ),
            onPressed: () => _showClearDataDialog(context, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalTelemetryGrid(TelemetryModel? log) {
    final tech = log?.technology ?? 'Unknown';

    String label1 = 'SS-RSRP';
    String val1 = '${log?.ssRsrp ?? "N/A"}';
    String unit1 = 'DBM';
    Color col1 = const Color(0xFF00F0FF);

    String label2 = 'SS-SINR';
    String val2 = '${log?.ssSinr ?? "N/A"}';
    String unit2 = 'DB';
    Color col2 = const Color(0xFFFFABF3);

    String label3 = 'SS-RSRQ';
    String val3 = '${log?.ssRsrq ?? "N/A"}';
    String unit3 = 'DB';
    Color col3 = const Color(0xFFFFBA20);

    if (tech.contains('5G')) {
      label1 = 'SS-RSRP';
      val1 = log?.ssRsrp != null ? '${log?.ssRsrp}' : 'N/A';
      unit1 = 'DBM';

      label2 = 'SS-SINR';
      val2 = log?.ssSinr != null ? '${log?.ssSinr}' : 'N/A';
      unit2 = 'DB';

      label3 = 'SS-RSRQ';
      val3 = log?.ssRsrq != null ? '${log?.ssRsrq}' : 'N/A';
      unit3 = 'DB';
    } else if (tech == '4G') {
      label1 = 'RSRP';
      val1 = log?.rsrp4g != null ? '${log?.rsrp4g}' : 'N/A';
      unit1 = 'DBM';

      label2 = 'RSSNR';
      val2 = log?.rssnr4g != null ? '${log?.rssnr4g}' : 'N/A';
      unit2 = 'DB';

      label3 = 'RSRQ';
      val3 = log?.rsrq4g != null ? '${log?.rsrq4g}' : 'N/A';
      unit3 = 'DB';
    } else if (tech == '3G') {
      label1 = 'RSCP';
      val1 = log?.rscp3g != null ? '${log?.rscp3g}' : 'N/A';
      unit1 = 'DBM';

      label2 = 'Ec/No';
      val2 = log?.ecNo3g != null ? '${log?.ecNo3g}' : 'N/A';
      unit2 = 'DB';

      label3 = 'ASU LEVEL';
      val3 = log?.asu3g != null ? '${log?.asu3g}' : 'N/A';
      unit3 = 'ASU';
    } else if (tech == '2G') {
      label1 = 'RSSI';
      val1 = log?.rssi2g != null ? '${log?.rssi2g}' : 'N/A';
      unit1 = 'DBM';

      label2 = 'RxQual';
      val2 = log?.rxQual2g != null ? '${log?.rxQual2g}' : 'N/A';
      unit2 = 'RXQ';

      label3 = 'ASU LEVEL';
      val3 = log?.asu2g != null ? '${log?.asu2g}' : 'N/A';
      unit3 = 'ASU';
    }

    final nci =
        log?.nci ??
        log?.ci4g?.toString() ??
        log?.ucid3g?.toString() ??
        log?.cid2g?.toString() ??
        'N/A';

    String cellIdLabel = 'CELL ID';
    if (tech.contains('5G')) {
      cellIdLabel = 'NCI';
    } else if (tech == '4G') {
      cellIdLabel = 'CI';
    } else if (tech == '3G') {
      cellIdLabel = 'UCID';
    } else if (tech == '2G') {
      cellIdLabel = 'CID';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF3B494B), width: 1),
      ),
      child: Column(
        children: [
          // 3 Columns of values
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTelemetryGridItem(label1, val1, unit1, col1),
              _buildTelemetryGridItem(label2, val2, unit2, col2),
              _buildTelemetryGridItem(label3, val3, unit3, col3),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF3B494B), height: 1, thickness: 0.5),
          const SizedBox(height: 16),
          // Tech and Cell ID Wrap
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.language_rounded,
                      color: Color(0xFF00F0FF),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'TECHNOLOGY',
                      style: TextStyle(
                        color: Color(0xFF849495),
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tech,
                      style: const TextStyle(
                        color: Color(0xFF00F0FF),
                        fontSize: 12,
                        fontFamily: 'JetBrains Mono',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cell_tower_rounded,
                      color: Color(0xFF00F0FF),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cellIdLabel,
                      style: const TextStyle(
                        color: Color(0xFF849495),
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      nci,
                      style: const TextStyle(
                        color: Color(0xFF00F0FF),
                        fontSize: 12,
                        fontFamily: 'JetBrains Mono',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryGridItem(
    String label,
    String value,
    String unit,
    Color valColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF849495),
            fontSize: 10,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                color: valColor,
                fontSize: 32,
                fontFamily: 'JetBrains Mono',
                fontWeight: FontWeight.w500,
                letterSpacing: -0.05,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: const TextStyle(
                color: Color(0xFF849495),
                fontSize: 10,
                fontFamily: 'JetBrains Mono',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignalQualityCard(TelemetryModel? log) {
    final rsrp =
        log?.ssRsrp ?? log?.rsrp4g ?? log?.rscp3g ?? log?.rssi2g ?? -88;
    String quality = 'OPTIMAL';
    if (rsrp < -105) {
      quality = 'POOR';
    } else if (rsrp < -95) {
      quality = 'FAIR';
    }

    double progress = (rsrp + 140) / (140 - 44);
    progress = progress.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF3B494B), width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.bar_chart_rounded,
            color: Color(0xFF00F0FF),
            size: 18,
          ),
          const SizedBox(width: 8),
          const Text(
            'SIGNAL QUALITY',
            style: TextStyle(
              color: Color(0xFF849495),
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            quality,
            style: const TextStyle(
              color: Color(0xFFE2E2E8),
              fontSize: 14,
              fontFamily: 'Hanken Grotesk',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFF1E2024),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF00F0FF),
                ),
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF849495),
            fontSize: 12,
            fontFamily: 'Inter',
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFE2E2E8),
            fontSize: 13,
            fontFamily: 'JetBrains Mono',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEventsCard(SpeedCheckController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF3B494B), width: 1),
      ),
      child: Column(children: _buildTelemetryEvents(controller.historyLogs)),
    );
  }

  List<Widget> _buildTelemetryEvents(List<TelemetryModel> logs) {
    if (logs.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              'Awaiting background samples...',
              style: TextStyle(
                color: Color(0xFF849495),
                fontSize: 11,
                fontFamily: 'JetBrains Mono',
              ),
            ),
          ),
        ),
      ];
    }

    final List<Widget> rows = [];
    final limit = logs.length > 5 ? 5 : logs.length;
    for (int i = 0; i < limit; i++) {
      final log = logs[i];
      final timeStr = log.timestamp.split('T').join(' ').substring(11, 19);
      final rsrp = log.ssRsrp ?? log.rsrp4g ?? log.rscp3g ?? log.rssi2g ?? -88;

      String eventDesc = '';
      String statusText = '';
      Color statusColor = const Color(0xFF849495);

      if (i % 3 == 0) {
        final nci = log.nci ?? '38274910';
        eventDesc = 'NCI $nci Initialized';
        statusText = 'LOCKED';
        statusColor = const Color(0xFF00F0FF); // Cyan
      } else if (i % 3 == 1) {
        final acc = log.accuracy?.toStringAsFixed(1) ?? '15.3';
        eventDesc = 'GPS Fix: Accuracy ${acc}m';
        statusText = 'VALID';
        statusColor = const Color(0xFF849495); // Gray
      } else {
        final tech = log.technology ?? '5G SA';
        eventDesc = '$tech Handover: Success';
        statusText = '$rsrp dBm';
        statusColor = const Color(0xFF849495); // Gray
      }

      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    timeStr,
                    style: const TextStyle(
                      color: Color(0xFF849495),
                      fontSize: 12,
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '•',
                    style: TextStyle(color: Color(0xFF00F0FF), fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    eventDesc,
                    style: const TextStyle(
                      color: Color(0xFFE2E2E8),
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontFamily: 'JetBrains Mono',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
      if (i < limit - 1) {
        rows.add(
          const Divider(color: Color(0xFF1E2024), height: 12, thickness: 0.5),
        );
      }
    }
    return rows;
  }

  Widget _buildControlDeck(
    BuildContext context,
    SpeedCheckController controller,
    Toastification toastification,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Color(0xFF0C0E12),
        border: Border(top: BorderSide(color: Color(0xFF1A1C20), width: 1)),
      ),
      child: Row(
        children: [
          // SYNC Outlined button
          Expanded(
            flex: 2,
            child: Obx(() {
              final isSyncing = controller.isSyncing.value;
              return OutlinedButton.icon(
                onPressed: isSyncing
                    ? null
                    : () async {
                        final success = await controller.syncData();
                        toastification.show(
                          context: context,
                          type: success
                              ? ToastificationType.success
                              : ToastificationType.error,
                          style: ToastificationStyle.fillColored,
                          title: Text(
                            success ? 'Sync Successful' : 'Sync Failed',
                          ),
                          description: Text(
                            success
                                ? 'Telemetry logs pushed to API successfully.'
                                : 'Unable to connect to speedcheck.insagrp.com API.',
                          ),
                          autoCloseDuration: const Duration(seconds: 4),
                        );
                      },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF00F0FF), width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: isSyncing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF00F0FF),
                        ),
                      )
                    : const Icon(
                        Icons.sync_rounded,
                        color: Color(0xFF00F0FF),
                        size: 16,
                      ),
                label: const Text(
                  'SYNC',
                  style: TextStyle(
                    color: Color(0xFF00F0FF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              );
            }),
          ),
          const SizedBox(width: 12),

          // START TEST / STOP TEST solid button
          Expanded(
            flex: 3,
            child: Obx(() {
              final running = controller.isLoggingRunning.value;
              return ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final nowRunning = await controller.toggleService();
                    toastification.show(
                      context: context,
                      type: nowRunning
                          ? ToastificationType.success
                          : ToastificationType.warning,
                      style: ToastificationStyle.flatColored,
                      title: Text(
                        nowRunning ? 'Telemetry Started' : 'Telemetry Stopped',
                      ),
                      description: Text(
                        nowRunning
                            ? 'Continuous background logging is now active.'
                            : 'Background service has been terminated.',
                      ),
                      autoCloseDuration: const Duration(seconds: 4),
                    );
                  } catch (e) {
                    toastification.show(
                      context: context,
                      type: ToastificationType.error,
                      style: ToastificationStyle.flatColored,
                      title: const Text('Permission Required'),
                      description: Text(
                        e.toString().replaceAll('Exception: ', ''),
                      ),
                      autoCloseDuration: const Duration(seconds: 5),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: running
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF00F0FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: Icon(
                  running
                      ? Icons.stop_circle_outlined
                      : Icons.play_arrow_rounded,
                  color: running ? Colors.white : Colors.black,
                  size: 18,
                ),
                label: Text(
                  running ? 'STOP TEST' : 'START TEST',
                  style: TextStyle(
                    color: running ? Colors.white : Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(
    BuildContext context,
    SpeedCheckController controller,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2024),
        title: const Text(
          'Clear All Logs?',
          style: TextStyle(color: Color(0xFFE2E2E8)),
        ),
        content: const Text(
          'This will purge all local database telemetry records. Are you sure you want to proceed?',
          style: TextStyle(color: Color(0xFF849495)),
        ),
        actions: [
          TextButton(
            child: const Text(
              'CANCEL',
              style: TextStyle(
                color: Color(0xFF849495),
                fontFamily: 'JetBrains Mono',
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            child: const Text(
              'CLEAR',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'JetBrains Mono',
              ),
            ),
            onPressed: () async {
              await controller.clearAllData();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
