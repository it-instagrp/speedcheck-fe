import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import '../constants.dart';
import '../controllers/speedcheck_controller.dart';
import '../telemetry_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SpeedCheckController());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // Deep Slate
              Color(0xFF1E1E2F), // Dark Violet
              Color(0xFF090D16), // Dark Obsidian
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. App Header
              _buildHeader(context, controller),

              // 2. Main Scrollable Dashboard
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      // Service Running Stats Banner
                      Obx(() => _buildStatusBanner(controller)),
                      const SizedBox(height: 16),

                      // Live Vitals HUD
                      Obx(
                        () => _buildLiveTelemetryHUD(
                          controller.latestTelemetry.value,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Charts Section
                      Obx(() => _buildChartsSection(controller)),
                      const SizedBox(height: 16),

                      // Recent Logs List
                      Obx(() => _buildLogsHistorySection(controller)),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // 3. Bottom Control Deck
              _buildControlDeck(context, controller),
            ],
          ),
        ),
      ),
    );
  }

  // Header UI with title, app logo style, and DB controls
  Widget _buildHeader(BuildContext context, SpeedCheckController controller) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.speed, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'SpeedCheck',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Insta ICT Solutions Pvt Ltd',
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            tooltip: 'Clear DB History',
            icon: Icon(
              Icons.delete_sweep_outlined,
              color: Colors.white.withOpacity(0.6),
            ),
            onPressed: () => _showClearDataDialog(context, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(SpeedCheckController controller) {
    final running = controller.isLoggingRunning.value;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: running
            ? Colors.green.withOpacity(0.08)
            : Colors.amber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: running
              ? Colors.green.withOpacity(0.2)
              : Colors.amber.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            running ? Icons.sensors : Icons.sensors_off,
            color: running ? Colors.green : Colors.amber,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              running
                  ? 'Continuous logging running at $COLLECTION_FREQUENCY_SECONDS seconds frequency'
                  : 'Logger is currently idle. Press START to record telemetry',
              style: TextStyle(
                color: running ? Colors.greenAccent : Colors.amberAccent,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dashboard HUD showing speed, signal, connectivity, and GPS
  Widget _buildLiveTelemetryHUD(TelemetryModel? log) {
    if (log == null) {
      return _buildGlassCard(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.query_stats, color: Colors.white24, size: 48),
              SizedBox(height: 12),
              Text(
                'No Active Telemetry Data',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Press Start Test to gather cellular metrics.',
                style: TextStyle(color: Colors.white30, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    final List<Widget> techWidgets = [];
    techWidgets.add(_buildInfoRow('Carrier Name', log.carrierName ?? 'N/A'));
    techWidgets.add(_buildInfoRow('Network Mode', log.networkType ?? 'N/A'));
    techWidgets.add(_buildInfoRow('Data State', log.dataState ?? 'N/A'));
    if (log.mcc != null || log.mnc != null) {
      techWidgets.add(
        _buildInfoRow('MCC / MNC', '${log.mcc ?? "N/A"} / ${log.mnc ?? "N/A"}'),
      );
    }

    final tech = log.technology;
    if (tech != null) {
      if (tech.contains('5G')) {
        techWidgets.add(_buildInfoRow('NCI (5G Cell ID)', log.nci ?? 'N/A'));
        techWidgets.add(
          _buildInfoRow(
            'PCI / TAC',
            '${log.pci5g ?? "N/A"} / ${log.tac5g ?? "N/A"}',
          ),
        );
        techWidgets.add(
          _buildInfoRow(
            'NRARFCN / Band',
            '${log.nrarfcn ?? "N/A"} / ${log.nrBand ?? "N/A"}',
          ),
        );
        techWidgets.add(
          _buildInfoRow(
            'SS-RSRP / SS-RSRQ',
            '${log.ssRsrp ?? "N/A"} dBm / ${log.ssRsrq ?? "N/A"} dB',
          ),
        );
        techWidgets.add(
          _buildInfoRow(
            'SS-SINR',
            log.ssSinr != null ? '${log.ssSinr} dB' : 'N/A',
          ),
        );
        techWidgets.add(
          _buildInfoRow(
            'CSI-RSRP / CSI-RSRQ',
            '${log.csiRsrp ?? "N/A"} dBm / ${log.csiRsrq ?? "N/A"} dB',
          ),
        );
        techWidgets.add(
          _buildInfoRow(
            'CSI-SINR',
            log.csiSinr != null ? '${log.csiSinr} dB' : 'N/A',
          ),
        );
        techWidgets.add(
          _buildInfoRow(
            'ASU Level',
            log.asu5g != null ? '${log.asu5g}' : 'N/A',
          ),
        );
        if (log.nrCqi != null) {
          techWidgets.add(
            _buildInfoRow(
              'CQI / Table Index',
              '${log.nrCqi} / ${log.nrCqiTableIndex ?? "N/A"}',
            ),
          );
        }
      } else if (tech == '4G') {
        techWidgets.add(
          _buildInfoRow(
            'CI (LTE Cell ID)',
            log.ci4g != null ? '${log.ci4g}' : 'N/A',
          ),
        );
        techWidgets.add(
          _buildInfoRow(
            'PCI / TAC',
            '${log.pci4g ?? "N/A"} / ${log.tac4g ?? "N/A"}',
          ),
        );
        techWidgets.add(
          _buildInfoRow(
            'EARFCN / Band',
            '${log.earfcn4g ?? "N/A"} / ${log.lteBand ?? "N/A"}',
          ),
        );
        techWidgets.add(
          _buildInfoRow(
            'Bandwidth',
            log.lteBandwidth != null ? '${log.lteBandwidth} MHz' : 'N/A',
          ),
        );
        techWidgets.add(
          _buildInfoRow(
            'RSRP / RSRQ',
            '${log.rsrp4g ?? "N/A"} dBm / ${log.rsrq4g ?? "N/A"} dB',
          ),
        );
        techWidgets.add(
          _buildInfoRow(
            'RSSI / RSSNR',
            '${log.rssi4g ?? "N/A"} dBm / ${log.rssnr4g ?? "N/A"} dB',
          ),
        );
        techWidgets.add(
          _buildInfoRow(
            'CQI / Timing Advance',
            '${log.lteCqi ?? "N/A"} / ${log.timingAdvance ?? "N/A"}',
          ),
        );
        techWidgets.add(
          _buildInfoRow(
            'ASU Level',
            log.asu4g != null ? '${log.asu4g}' : 'N/A',
          ),
        );
        if (log.calculatedDistance != null) {
          techWidgets.add(
            _buildInfoRow(
              'Base Station Distance',
              '${log.calculatedDistance!.toStringAsFixed(1)} m',
            ),
          );
        }
      } else if (tech == '3G') {
        techWidgets.add(
          _buildInfoRow(
            'UCID (Cell ID)',
            log.ucid3g != null ? '${log.ucid3g}' : 'N/A',
          ),
        );
        techWidgets.add(
          _buildInfoRow(
            'PSC / LAC',
            '${log.psc3g ?? "N/A"} / ${log.lac3g ?? "N/A"}',
          ),
        );
        techWidgets.add(
          _buildInfoRow(
            'UARFCN',
            log.uarfcn3g != null ? '${log.uarfcn3g}' : 'N/A',
          ),
        );
        techWidgets.add(
          _buildInfoRow(
            'RSCP / Ec/No',
            '${log.rscp3g ?? "N/A"} dBm / ${log.ecNo3g ?? "N/A"} dB',
          ),
        );
        techWidgets.add(
          _buildInfoRow(
            'ASU Level',
            log.asu3g != null ? '${log.asu3g}' : 'N/A',
          ),
        );
      } else if (tech == '2G') {
        techWidgets.add(
          _buildInfoRow(
            'CID (Cell ID)',
            log.cid2g != null ? '${log.cid2g}' : 'N/A',
          ),
        );
        techWidgets.add(
          _buildInfoRow(
            'BSIC / LAC',
            '${log.bsic2g ?? "N/A"} / ${log.lac2g ?? "N/A"}',
          ),
        );
        techWidgets.add(
          _buildInfoRow(
            'ARFCN',
            log.arfcn2g != null ? '${log.arfcn2g}' : 'N/A',
          ),
        );
        techWidgets.add(
          _buildInfoRow(
            'RSSI / RxQual',
            '${log.rssi2g ?? "N/A"} dBm / ${log.rxQual2g ?? "N/A"}',
          ),
        );
        techWidgets.add(
          _buildInfoRow(
            'ASU Level',
            log.asu2g != null ? '${log.asu2g}' : 'N/A',
          ),
        );
      }
    }

    final List<Widget> derivedWidgets = [];
    if (tech != null &&
        (tech.contains('5G') || tech == '4G' || tech == '3G' || tech == '2G')) {
      derivedWidgets.add(
        _buildInfoRow('Neighbor Cells Detected', '${log.neighborCells.length}'),
      );
      if (log.dominanceMargin != null) {
        derivedWidgets.add(
          _buildInfoRow(
            'Dominance Margin',
            '${log.dominanceMargin!.toStringAsFixed(1)} dB',
          ),
        );
      }
      if (log.ppi != null) {
        derivedWidgets.add(
          _buildInfoRow(
            'Pilot Pollution Index',
            '${log.ppi} (${log.ppiState ?? "Clean"})',
          ),
        );
      }
      if (log.pingPongIndex != null) {
        derivedWidgets.add(
          _buildInfoRow('Handover Ping-Pong Index', '${log.pingPongIndex}'),
        );
      }
      if (log.rfAsymmetryIndex != null) {
        derivedWidgets.add(
          _buildInfoRow(
            'RF Asymmetry (RSRP - RSSI)',
            '${log.rfAsymmetryIndex!.toStringAsFixed(1)} dB',
          ),
        );
      }

      if (log.neighborCells.isNotEmpty) {
        derivedWidgets.add(const SizedBox(height: 8));
        derivedWidgets.add(
          const Text(
            'DETECTED NEIGHBORS',
            style: TextStyle(
              color: Colors.white24,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        );
        derivedWidgets.add(const SizedBox(height: 4));

        final topNeighbors = log.neighborCells.take(3).toList();
        for (int i = 0; i < topNeighbors.length; i++) {
          final n = topNeighbors[i];
          final nTech = n['tech'] ?? 'N/A';
          final nPci = n['pci'] ?? n['psc'] ?? n['bsic'] ?? 'N/A';
          final nSignalKey = nTech == '3G'
              ? 'rscp'
              : (nTech == '2G' ? 'rxLev' : 'rsrp');
          final nSignal = n[nSignalKey] ?? 'N/A';
          final nFreqKey = nTech == '3G'
              ? 'uarfcn'
              : (nTech == '2G' ? 'arfcn' : 'earfcn');
          final nFreq = n[nFreqKey] ?? 'N/A';

          derivedWidgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '  #$i [$nTech] PCI/BSIC: $nPci',
                    style: const TextStyle(color: Colors.white30, fontSize: 11),
                  ),
                  Text(
                    'Signal: $nSignal dBm | Freq: $nFreq',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }

    return Column(
      children: [
        // Rows of vitals
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Connection / Mode',
                value: log.technology ?? 'Unknown',
                unit: '',
                icon: Icons.wifi_tethering_rounded,
                color: const Color(0xFF06B6D4), // Cyan
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Signal Strength',
                value: log.rsrp != null ? '${log.rsrp}' : 'N/A',
                unit: log.rsrp != null ? 'dBm' : '',
                icon: Icons.signal_cellular_alt_rounded,
                color: const Color(0xFFF59E0B), // Amber
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Dominance Margin',
                value: log.dominanceMargin != null
                    ? '${log.dominanceMargin!.toStringAsFixed(1)}'
                    : 'N/A',
                unit: 'dB',
                subtitle: 'PPI: ${log.ppi ?? 1} (${log.ppiState ?? "Clean"})',
                icon: Icons.grid_view_rounded,
                color: const Color(0xFFEC4899), // Magenta
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Accuracy / Speed',
                value: log.accuracy != null
                    ? '${log.accuracy!.toStringAsFixed(1)}'
                    : 'N/A',
                unit: 'm',
                subtitle: 'Speed: ${((log.speed ?? 0.0) * 3.6).toInt()} km/h',
                icon: Icons.location_on_rounded,
                color: const Color(0xFF10B981), // Emerald
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Full cellular and location info card
        _buildGlassCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'NETWORK INFRASTRUCTURE',
                      style: TextStyle(
                        color: Colors.cyanAccent.withOpacity(0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.blueAccent.withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        log.technology ?? 'Unknown',
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white12, height: 20),

                // Telephony variables grid
                ...techWidgets,

                if (derivedWidgets.isNotEmpty) ...[
                  const Divider(color: Colors.white12, height: 20),
                  Text(
                    'DERIVED RF METRICS',
                    style: TextStyle(
                      color: Colors.orangeAccent.withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 20),
                  ...derivedWidgets,
                ],

                const Divider(color: Colors.white12, height: 24),
                Text(
                  'GPS LOCATION & DEVICE',
                  style: TextStyle(
                    color: Colors.purpleAccent.withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const Divider(color: Colors.white12, height: 20),

                _buildInfoRow(
                  'GPS Coordinates',
                  log.latitude != null && log.longitude != null
                      ? '${log.latitude!.toStringAsFixed(6)}, ${log.longitude!.toStringAsFixed(6)}'
                      : 'Acquiring...',
                ),
                _buildInfoRow(
                  'GPS Accuracy / Speed',
                  '${log.accuracy?.toStringAsFixed(1) ?? "0"}m / ${(log.speed ?? 0.0) * 3.6.toInt()} km/h',
                ),
                _buildInfoRow('Device Hardware', log.deviceModel),
                _buildInfoRow('OS Version', log.androidVersion),
                _buildInfoRow('IMEI / Android ID', log.imei ?? 'N/A'),
                _buildInfoRow(
                  'Logged Timestamp',
                  log.timestamp.split('T').join(' ').substring(0, 19),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper row widget
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xE6FFFFFF),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dashboard charts showing live speed trends and RSRP power levels
  Widget _buildChartsSection(SpeedCheckController controller) {
    final logs = controller.historyLogs;
    if (logs.length < 2) {
      return _buildGlassCard(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          alignment: Alignment.center,
          child: const Text(
            'Waiting for more data points to render charts...',
            style: TextStyle(color: Colors.white30, fontSize: 13),
          ),
        ),
      );
    }

    // Prepare chart spots (reverse logs so they show oldest to newest)
    final reversedLogs = logs.reversed.toList();
    final List<FlSpot> downloadSpots = [];
    final List<FlSpot> uploadSpots = [];
    final List<FlSpot> rsrpSpots = [];

    for (int i = 0; i < reversedLogs.length; i++) {
      final log = reversedLogs[i];
      final double idx = i.toDouble();

      downloadSpots.add(FlSpot(idx, log.downloadSpeed ?? 0.0));
      uploadSpots.add(FlSpot(idx, log.uploadSpeed ?? 0.0));

      if (log.rsrp != null) {
        rsrpSpots.add(
          FlSpot(idx, log.rsrp!.toDouble().abs()),
        ); // Map as positive value for display ease
      }
    }

    return Column(
      children: [
        /*
        // Speed profile chart (Download/Upload)
        _buildGlassCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SPEED PROFILE (Mbps)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        _buildLegendIndicator(
                          const Color(0xFF06B6D4),
                          'Download',
                        ),
                        const SizedBox(width: 12),
                        _buildLegendIndicator(
                          const Color(0xFFEC4899),
                          'Upload',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 150,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (val) =>
                            FlLine(color: Colors.white10, strokeWidth: 1),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 38,
                            getTitlesWidget: (val, meta) => SideTitleWidget(
                              meta: meta,
                              space: 6,
                              child: Text(
                                '${val.toInt()}',
                                style: const TextStyle(
                                  color: Colors.white30,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: downloadSpots,
                          isCurved: true,
                          color: const Color(0xFF06B6D4),
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFF06B6D4).withOpacity(0.08),
                          ),
                        ),
                        LineChartBarData(
                          spots: uploadSpots,
                          isCurved: true,
                          color: const Color(0xFFEC4899),
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFFEC4899).withOpacity(0.08),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),
        */

        // Signal RSRP chart
        if (rsrpSpots.isNotEmpty)
          _buildGlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SIGNAL LOSS TREND (RSRP | -dBm)',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 120,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (val) =>
                              FlLine(color: Colors.white10, strokeWidth: 1),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 38,
                              getTitlesWidget: (val, meta) => SideTitleWidget(
                                meta: meta,
                                space: 6,
                                child: Text(
                                  '-${val.toInt()}',
                                  style: const TextStyle(
                                    color: Colors.white30,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: rsrpSpots,
                            isCurved: true,
                            color: const Color(0xFFF59E0B),
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: const Color(0xFFF59E0B).withOpacity(0.08),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /*
  Widget _buildLegendIndicator(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }
  */

  // History logs builder
  Widget _buildLogsHistorySection(SpeedCheckController controller) {
    final logs = controller.historyLogs;
    if (logs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT LOGS (${logs.length})',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Obx(
                () => Text(
                  'Unsynced: ${controller.unsyncedCount.value}',
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: logs.length > 5 ? 5 : logs.length, // Show top 5 logs
          itemBuilder: (context, idx) {
            final log = logs[idx];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildLogItem(log),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLogItem(TelemetryModel log) {
    final isWifi = log.networkType == 'WiFi';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  isWifi ? Icons.wifi : Icons.signal_cellular_alt,
                  color: isWifi ? Colors.blueAccent : Colors.cyanAccent,
                  size: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${log.carrierName ?? "WiFi Network"} (${log.technology ?? "WiFi"})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        log.timestamp.split('T').join(' ').substring(11, 19),
                        style: const TextStyle(
                          color: Colors.white30,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '⬇ ${log.downloadSpeed?.toStringAsFixed(1) ?? "0"} / ⬆ ${log.uploadSpeed?.toStringAsFixed(1) ?? "0"} Mbps',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ping: ${log.ping?.toInt() ?? 0} ms | Loss: ${log.packetLoss?.toInt() ?? 0}%',
                    style: const TextStyle(color: Colors.white30, fontSize: 9),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Icon(
                log.synced ? Icons.cloud_done : Icons.cloud_off,
                color: log.synced ? Colors.green : Colors.white24,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Floating Action Deck at the bottom
  Widget _buildControlDeck(
    BuildContext context,
    SpeedCheckController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Column(
        children: [
          // Local Database Sync Status
          Obx(() {
            final count = controller.unsyncedCount.value;
            final isSyncing = controller.isSyncing.value;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count logs unsynced in Server',
                      style: TextStyle(
                        color: count > 0 ? Colors.cyanAccent : Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: count == 0 || isSyncing
                      ? null
                      : () async {
                          _handleSync(context, controller);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    disabledBackgroundColor: Colors.white10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  icon: isSyncing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.sync, size: 16, color: Colors.white),
                  label: Text(
                    isSyncing ? 'Syncing...' : 'Sync Now',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 16),

          // Central start/stop trigger button
          Obx(() {
            final running = controller.isLoggingRunning.value;

            return GestureDetector(
              onTap: () async {
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: running
                        ? [
                            const Color(0xFFEF4444),
                            const Color(0xFFDC2626),
                          ] // Red stop
                        : [
                            const Color(0xFF06B6D4),
                            const Color(0xFF4F46E5),
                          ], // Cyan-indigo start
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: running
                          ? Colors.red.withOpacity(0.3)
                          : Colors.cyan.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        running
                            ? Icons.stop_circle
                            : Icons.play_circle_filled_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        running
                            ? 'STOP CONTINUOUS TEST'
                            : 'START CONTINUOUS TEST',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Handle manual database synchronization
  void _handleSync(
    BuildContext context,
    SpeedCheckController controller,
  ) async {
    final success = await controller.syncData();
    toastification.show(
      context: context,
      type: success ? ToastificationType.success : ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: Text(success ? 'Sync Successful' : 'Sync Failed'),
      description: Text(
        success
            ? 'Telemetry logs pushed to API successfully.'
            : 'Unable to connect to speedcheck.insagrp.com API.',
      ),
      autoCloseDuration: const Duration(seconds: 4),
    );
  }

  // Glass Container Builder
  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: child,
        ),
      ),
    );
  }

  // Metric card builder
  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    String? subtitle,
    Color? subtitleColor,
    required IconData icon,
    required Color color,
  }) {
    return _buildGlassCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(icon, color: color.withOpacity(0.8), size: 18),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              textBaseline: TextBaseline.alphabetic,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22, // Slightly adjusted size for better fitting
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      unit,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white30,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: subtitleColor ?? Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Confirmation dialog before clearing DB logs
  void _showClearDataDialog(
    BuildContext context,
    SpeedCheckController controller,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Clear All Logs?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will purge all local database telemetry records. Are you sure you want to proceed?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white38),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              await controller.clearAllData();
              Navigator.of(ctx).pop();
              toastification.show(
                context: context,
                type: ToastificationType.success,
                title: const Text('History Purged'),
                description: const Text('Local SQLite telemetry data cleared.'),
                autoCloseDuration: const Duration(seconds: 3),
              );
            },
          ),
        ],
      ),
    );
  }
}
