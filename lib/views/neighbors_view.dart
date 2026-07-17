import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/speedcheck_controller.dart';
import '../telemetry_model.dart';

class NeighborsView extends StatelessWidget {
  const NeighborsView({Key? key}) : super(key: key);

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

            // Content Area
            Expanded(
              child: Obx(() {
                final log = controller.latestTelemetry.value;
                if (log == null) {
                  return _buildEmptyPlaceholder();
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Derived RF Metrics Section Header
                      _buildSectionHeader(
                        Icons.insert_chart_outlined_rounded,
                        'DERIVED RF METRICS',
                      ),
                      const SizedBox(height: 8),
                      _buildDerivedMetricsCard(log),
                      const SizedBox(height: 20),

                      // Neighbor Cells Table Section Header
                      _buildSectionHeader(
                        Icons.cell_tower_rounded,
                        'DETECTED NEIGHBOR CELLS',
                      ),
                      const SizedBox(height: 8),
                      _buildNeighborsTable(log),
                      const SizedBox(height: 24),
                    ],
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
          Icon(
            Icons.cell_tower_rounded,
            color: Color(0xFF00F0FF),
            size: 24,
          ),
          SizedBox(width: 10),
          Text(
            'Neighbor Diagnostic Deck',
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

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
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
    );
  }

  Widget _buildDerivedMetricsCard(TelemetryModel log) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF3B494B), width: 1),
      ),
      child: Column(
        children: [
          _buildRowDetail('Neighbor Cells Detected', '${log.neighborCells.length}'),
          const SizedBox(height: 8),
          _buildRowDetail('Pilot Pollution Index (PPI)', log.ppi != null ? '${log.ppi}' : 'N/A'),
          const SizedBox(height: 8),
          _buildRowDetail('Pilot Pollution State', log.ppiState ?? 'N/A'),
          const SizedBox(height: 8),
          _buildRowDetail(
            'Serving Cell Dominance Margin',
            log.dominanceMargin != null ? '${log.dominanceMargin!.toStringAsFixed(1)} dB' : 'N/A',
          ),
          const SizedBox(height: 8),
          _buildRowDetail('Handover Ping-Pong Index', log.pingPongIndex != null ? '${log.pingPongIndex}' : 'N/A'),
          const SizedBox(height: 8),
          _buildRowDetail(
            'RF Asymmetry Index',
            log.rfAsymmetryIndex != null ? '${log.rfAsymmetryIndex!.toStringAsFixed(1)} dB' : 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildNeighborsTable(TelemetryModel log) {
    if (log.neighborCells.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1C20),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF3B494B), width: 1),
        ),
        child: const Center(
          child: Text(
            'No neighboring cells detected',
            style: TextStyle(
              color: Color(0xFF849495),
              fontSize: 12,
              fontFamily: 'JetBrains Mono',
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF3B494B), width: 1),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFF0C0E12)),
          dataRowMinHeight: 48,
          dataRowMaxHeight: 48,
          horizontalMargin: 12,
          columnSpacing: 16,
          columns: const [
            DataColumn(label: Text('CELL', style: _headerStyle)),
            DataColumn(label: Text('TECH', style: _headerStyle)),
            DataColumn(label: Text('PCI/PSC/BSIC', style: _headerStyle)),
            DataColumn(label: Text('SIGNAL', style: _headerStyle)),
            DataColumn(label: Text('RSRQ', style: _headerStyle)),
            DataColumn(label: Text('FREQUENCY', style: _headerStyle)),
          ],
          rows: List.generate(log.neighborCells.length, (index) {
            final n = log.neighborCells[index];
            final nTech = n['tech'] ?? 'N/A';

            String pciStr = 'N/A';
            String signalStr = 'N/A';
            String rsrqStr = 'N/A';
            String freqStr = 'N/A';

            if (nTech == '4G' || nTech == '5G') {
              pciStr = 'PCI: ${n['pci'] ?? "N/A"}';
              signalStr = n['rsrp'] != null ? '${n['rsrp']} dBm' : 'N/A';
              rsrqStr = n['rsrq'] != null ? '${n['rsrq']} dB' : 'N/A';
              freqStr = '${n['earfcn'] ?? "N/A"}';
            } else if (nTech == '3G') {
              pciStr = 'PSC: ${n['psc'] ?? "N/A"}';
              signalStr = n['rscp'] != null ? '${n['rscp']} dBm' : 'N/A';
              freqStr = '${n['uarfcn'] ?? "N/A"}';
            } else if (nTech == '2G') {
              pciStr = 'BSIC: ${n['bsic'] ?? "N/A"}';
              signalStr = n['rxLev'] != null ? '${n['rxLev']} dBm' : 'N/A';
              freqStr = '${n['arfcn'] ?? "N/A"}'; // BCCH Frequency
            }

            return DataRow(
              cells: [
                DataCell(Text('#${index + 1}', style: _cellCyanStyle)),
                DataCell(Text(nTech, style: _cellStyle)),
                DataCell(Text(pciStr, style: _cellStyle)),
                DataCell(Text(signalStr, style: _cellStyle)),
                DataCell(Text(rsrqStr, style: _cellStyle)),
                DataCell(Text(freqStr, style: _cellStyle)),
              ],
            );
          }),
        ),
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

  static const TextStyle _headerStyle = TextStyle(
    color: Color(0xFF849495),
    fontSize: 10,
    fontWeight: FontWeight.bold,
    fontFamily: 'JetBrains Mono',
  );

  static const TextStyle _cellStyle = TextStyle(
    color: Color(0xFFE2E2E8),
    fontSize: 12,
    fontFamily: 'JetBrains Mono',
  );

  static const TextStyle _cellCyanStyle = TextStyle(
    color: Color(0xFF00F0FF),
    fontSize: 12,
    fontFamily: 'JetBrains Mono',
    fontWeight: FontWeight.bold,
  );
}
