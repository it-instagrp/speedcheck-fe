import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/speedcheck_controller.dart';
import '../telemetry_model.dart';

class ChartsView extends StatelessWidget {
  const ChartsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SpeedCheckController>();

    return Scaffold(
      backgroundColor: const Color(0xFF111318), // Midnight Dark
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            _buildHeader(),

            // Content
            Expanded(
              child: Obx(() {
                final logs = controller.historyLogs;
                final latest = controller.latestTelemetry.value;
                if (logs.length < 2 || latest == null) {
                  return _buildEmptyPlaceholder();
                }

                final tech = latest.technology ?? 'Unknown';

                final List<Widget> children = [
                  const SizedBox(height: 16),
                  _buildTechIndicator(tech),
                  const SizedBox(height: 16),
                ];

                if (tech.contains('5G')) {
                  children.add(_buildChart(logs, 'SS-RSRP', 'dBm', (log) => log.ssRsrp?.toDouble(), const Color(0xFF00F0FF)));
                  children.add(const SizedBox(height: 20));
                  children.add(_buildChart(logs, 'SS-RSRQ', 'dB', (log) => log.ssRsrq?.toDouble(), const Color(0xFFFFBA20)));
                  children.add(const SizedBox(height: 20));
                  children.add(_buildChart(logs, 'SS-SINR', 'dB', (log) => log.ssSinr?.toDouble(), const Color(0xFFFFABF3)));
                  children.add(const SizedBox(height: 20));
                  children.add(_buildChart(logs, 'CSI-RSRP', 'dBm', (log) => log.csiRsrp?.toDouble(), const Color(0xFF00FF66)));
                  children.add(const SizedBox(height: 20));
                  children.add(_buildChart(logs, 'CSI-RSRQ', 'dB', (log) => log.csiRsrq?.toDouble(), const Color(0xFFEFFF20)));
                  children.add(const SizedBox(height: 20));
                  children.add(_buildChart(logs, 'CSI-SINR', 'dB', (log) => log.csiSinr?.toDouble(), const Color(0xFFABFFFA)));
                  children.add(const SizedBox(height: 20));
                }

                if (tech == '4G' || tech.contains('NSA')) {
                  children.add(_buildChart(logs, 'RSRP', 'dBm', (log) => log.rsrp4g?.toDouble(), const Color(0xFF00F0FF)));
                  children.add(const SizedBox(height: 20));
                  children.add(_buildChart(logs, 'RSRQ', 'dB', (log) => log.rsrq4g?.toDouble(), const Color(0xFFFFBA20)));
                  children.add(const SizedBox(height: 20));
                  children.add(_buildChart(logs, 'RSSI', 'dBm', (log) => log.rssi4g?.toDouble(), const Color(0xFFFF9F20)));
                  children.add(const SizedBox(height: 20));
                  children.add(_buildChart(logs, 'RSSNR', 'dB', (log) => log.rssnr4g?.toDouble(), const Color(0xFFFFABF3)));
                  children.add(const SizedBox(height: 20));
                }

                if (tech == '3G') {
                  children.add(_buildChart(logs, 'RSCP', 'dBm', (log) => log.rscp3g?.toDouble(), const Color(0xFF00F0FF)));
                  children.add(const SizedBox(height: 20));
                  children.add(_buildChart(logs, 'Ec/No', 'dB', (log) => log.ecNo3g?.toDouble(), const Color(0xFFFFABF3)));
                  children.add(const SizedBox(height: 20));
                }

                if (tech == '2G') {
                  children.add(_buildChart(logs, 'RSSI', 'dBm', (log) => log.rssi2g?.toDouble(), const Color(0xFF00F0FF)));
                  children.add(const SizedBox(height: 20));
                  children.add(_buildChart(logs, 'RxQual', 'index', (log) => log.rxQual2g?.toDouble(), const Color(0xFFFFABF3)));
                  children.add(const SizedBox(height: 20));
                }

                children.add(const SizedBox(height: 24));

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0C0E12),
        border: Border(bottom: BorderSide(color: Color(0xFF1A1C20), width: 1)),
      ),
      child: Row(
        children: const [
          Icon(Icons.show_chart_rounded, color: Color(0xFF00F0FF), size: 24),
          SizedBox(width: 10),
          Text(
            'Signal Trend Splines',
            style: TextStyle(
              color: Color(0xFF00F0FF),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Hanken Grotesk',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechIndicator(String tech) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF3B494B), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'ACTIVE CHANNEL MODE',
            style: TextStyle(
              color: Color(0xFF849495),
              fontSize: 10,
              fontFamily: 'JetBrains Mono',
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF00F0FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF00F0FF), width: 0.5),
            ),
            child: Text(
              tech,
              style: const TextStyle(
                color: Color(0xFF00F0FF),
                fontSize: 12,
                fontFamily: 'JetBrains Mono',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(
    List<TelemetryModel> logs,
    String metricName,
    String unit,
    double? Function(TelemetryModel) getValue,
    Color lineColor,
  ) {
    final reversedLogs = logs.reversed.toList();
    final List<FlSpot> spots = [];

    for (int i = 0; i < reversedLogs.length; i++) {
      final val = getValue(reversedLogs[i]);
      if (val != null) {
        spots.add(FlSpot(i.toDouble(), val));
      }
    }

    if (spots.isEmpty) {
      return _buildNoDataCard(metricName);
    }

    return _buildSplineChart(
      title: '$metricName Trend',
      subtitle: 'Real-time $metricName spline over time',
      unit: unit,
      spots: spots,
      logs: reversedLogs,
      lineColor: lineColor,
    );
  }

  Widget _buildSplineChart({
    required String title,
    required String subtitle,
    required String unit,
    required List<FlSpot> spots,
    required List<TelemetryModel> logs,
    required Color lineColor,
  }) {
    // Determine min/max values dynamically to ensure correct zoom level
    double minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    // Add small buffer margin to top and bottom
    minY = (minY - 5).roundToDouble();
    maxY = (maxY + 5).roundToDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF3B494B), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF00F0FF),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'JetBrains Mono',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF849495),
              fontSize: 10,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) =>
                      FlLine(color: const Color(0xFF1E2024), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < logs.length) {
                          // Only show titles periodically to prevent overlaps
                          final interval = (logs.length ~/ 3).clamp(
                            1,
                            logs.length,
                          );
                          if (idx % interval == 0 || idx == logs.length - 1) {
                            final time = logs[idx].timestamp;
                            final timeStr = time.length >= 19
                                ? time.substring(11, 16) // e.g. "17:34"
                                : time;
                            return SideTitleWidget(
                              meta: meta,
                              space: 4,
                              child: Text(
                                timeStr,
                                style: const TextStyle(
                                  color: Color(0xFF849495),
                                  fontSize: 8,
                                  fontFamily: 'JetBrains Mono',
                                ),
                              ),
                            );
                          }
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (val, meta) => SideTitleWidget(
                        meta: meta,
                        space: 4,
                        child: Text(
                          '${val.toInt()}',
                          style: const TextStyle(
                            color: Color(0xFF849495),
                            fontSize: 8,
                            fontFamily: 'JetBrains Mono',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: lineColor,
                    barWidth: 2,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 2,
                            color: lineColor,
                            strokeWidth: 1.0,
                            strokeColor: const Color(0xFF1A1C20),
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          lineColor.withOpacity(0.12),
                          lineColor.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'unit: $unit',
              style: const TextStyle(
                color: Color(0xFF849495),
                fontSize: 8,
                fontFamily: 'JetBrains Mono',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataCard(String metricName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF3B494B), width: 1),
      ),
      child: Center(
        child: Text(
          'No metric samples for $metricName available',
          style: const TextStyle(
            color: Color(0xFF849495),
            fontSize: 12,
            fontFamily: 'JetBrains Mono',
          ),
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
            Icon(Icons.query_stats_rounded, color: Color(0xFF00F0FF), size: 48),
            SizedBox(height: 16),
            Text(
              '[ DATA POOL EMPTY ]',
              style: TextStyle(
                color: Color(0xFF00F0FF),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'JetBrains Mono',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Need at least 2 diagnostic log samples to construct spline splines. Trigger START TEST to begin cellular telemetry collection.',
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
}
