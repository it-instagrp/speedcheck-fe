import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

    return Scaffold(
      backgroundColor: const Color(0xFF111318), // Midnight Dark
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header
            _buildHeader(),

            // 2. Settings Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // LOG STORAGE CONFIGURATION
                    _buildSectionHeader(Icons.storage_rounded, 'LOG STORAGE CONFIGURATION'),
                    const SizedBox(height: 8),

                    // Storage Location Card
                    _buildStorageLocationCard(context, controller),
                    const SizedBox(height: 12),

                    // Format and Naming Convention Card
                    _buildFormatAndNamingCard(context, controller),
                    const SizedBox(height: 12),

                    // Auto-Purge Logs Card with Dynamic Glow
                    Obx(() => _buildAutoPurgeCard(controller)),
                    const SizedBox(height: 24),

                    // DATA & SYNC
                    _buildSectionHeader(Icons.sync_rounded, 'DATA & SYNC'),
                    const SizedBox(height: 8),

                    // Sync & Frequency Card
                    _buildDataAndSyncCard(context, controller),
                    const SizedBox(height: 24),

                    // ABOUT
                    _buildSectionHeader(Icons.info_outline_rounded, 'ABOUT'),
                    const SizedBox(height: 8),

                    // About Card
                    _buildAboutCard(context),
                    const SizedBox(height: 32),

                    // Diagnostic Footer
                    _buildDiagnosticFooter(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
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
        border: Border(
          bottom: BorderSide(color: Color(0xFF1A1C20), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: Color(0xFF00F0FF), size: 22),
              const SizedBox(width: 8),
              const Text(
                'Settings',
                style: TextStyle(
                  color: Color(0xFF00F0FF),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Hanken Grotesk',
                ),
              ),
            ],
          ),
          const Icon(Icons.sensors_rounded, color: Color(0xFF849495), size: 20),
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
          title.toUpperCase(),
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

  Widget _buildStorageLocationCard(BuildContext context, SettingsController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20), // surface-container-low
        borderRadius: BorderRadius.circular(4), // rounded-sm
        border: Border.all(color: const Color(0xFF3B494B), width: 1), // outline-variant
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Storage Location',
            style: TextStyle(
              color: Color(0xFFE2E2E8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Obx(() => Text(
                '/Internal Storage/${controller.logStorageLocation.value}',
                style: const TextStyle(
                  color: Color(0xFF849495),
                  fontSize: 12,
                  fontFamily: 'JetBrains Mono',
                ),
              )),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _showLocationEditDialog(context, controller),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF00F0FF), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            icon: const Icon(Icons.folder_open_rounded, color: Color(0xFF00F0FF), size: 16),
            label: const Text(
              'BROWSE',
              style: TextStyle(
                color: Color(0xFF00F0FF),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily: 'JetBrains Mono',
                letterSpacing: 0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatAndNamingCard(BuildContext context, SettingsController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF3B494B), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Log Format',
                style: TextStyle(
                  color: Color(0xFFE2E2E8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              Obx(() => DropdownButton<String>(
                    value: controller.logStorageFormat.value,
                    dropdownColor: const Color(0xFF1E2024),
                    underline: const SizedBox.shrink(),
                    style: const TextStyle(
                      color: Color(0xFF00F0FF),
                      fontSize: 13,
                      fontFamily: 'JetBrains Mono',
                      fontWeight: FontWeight.bold,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'SQLite', child: Text('SQLite (DB)')),
                      DropdownMenuItem(value: 'JSON', child: Text('JSON File')),
                      DropdownMenuItem(value: 'CSV', child: Text('CSV File')),
                    ],
                    onChanged: (val) {
                      if (val != null) controller.setLogStorageFormat(val);
                    },
                  )),
            ],
          ),
          const Divider(color: Color(0xFF3B494B), height: 20, thickness: 0.5),
          const SizedBox(height: 4),
          const Text(
            'File Naming Convention',
            style: TextStyle(
              color: Color(0xFFE2E2E8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Obx(() => Text(
                controller.logNamingConvention.value,
                style: const TextStyle(
                  color: Color(0xFF849495),
                  fontSize: 12,
                  fontFamily: 'JetBrains Mono',
                ),
              )),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _showNamingConventionDialog(context, controller),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF3B494B), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text(
              'EDIT PATTERN',
              style: TextStyle(
                color: Color(0xFFE2E2E8),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                fontFamily: 'JetBrains Mono',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoPurgeCard(SettingsController controller) {
    final active = controller.autoPurgeLogs.value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: active ? const Color(0xFF00F0FF) : const Color(0xFF3B494B),
          width: active ? 1.5 : 1,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: const Color(0xFF00F0FF).withOpacity(0.08),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Auto-Purge Logs',
                  style: TextStyle(
                    color: Color(0xFFE2E2E8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Purge logs older than 30 days',
                  style: TextStyle(
                    color: Color(0xFF849495),
                    fontSize: 11,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: active,
            onChanged: controller.setAutoPurgeLogs,
            activeColor: const Color(0xFF00F0FF),
            activeTrackColor: const Color(0xFF006970).withOpacity(0.3),
            inactiveThumbColor: const Color(0xFF849495),
            inactiveTrackColor: const Color(0xFF1E2024),
          ),
        ],
      ),
    );
  }

  Widget _buildDataAndSyncCard(BuildContext context, SettingsController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF3B494B), width: 1),
      ),
      child: Column(
        children: [
          // Wifi Sync Row
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.wifi_rounded, color: Color(0xFF849495), size: 18),
                      SizedBox(width: 10),
                      Text(
                        'Sync only on Wi-Fi',
                        style: TextStyle(
                          color: Color(0xFFE2E2E8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: controller.syncOnlyWifi.value,
                    onChanged: controller.setSyncOnlyWifi,
                    activeColor: const Color(0xFF00F0FF),
                    activeTrackColor: const Color(0xFF006970).withOpacity(0.3),
                    inactiveThumbColor: const Color(0xFF849495),
                    inactiveTrackColor: const Color(0xFF1E2024),
                  ),
                ],
              )),

          const Divider(color: Color(0xFF3B494B), height: 24, thickness: 0.5),

          // Frequency Dropdown Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.timer_outlined, color: Color(0xFF849495), size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Logging Frequency',
                    style: TextStyle(
                      color: Color(0xFFE2E2E8),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              Obx(() => DropdownButton<String>(
                    value: controller.recordFrequency.value,
                    dropdownColor: const Color(0xFF1E2024),
                    underline: const SizedBox.shrink(),
                    style: const TextStyle(
                      color: Color(0xFF00F0FF),
                      fontSize: 13,
                      fontFamily: 'JetBrains Mono',
                      fontWeight: FontWeight.bold,
                    ),
                    items: const [
                      DropdownMenuItem(value: '10', child: Text('10s')),
                      DropdownMenuItem(value: '30', child: Text('30s')),
                      DropdownMenuItem(value: '60', child: Text('1m')),
                      DropdownMenuItem(value: '300', child: Text('5m')),
                    ],
                    onChanged: (val) {
                      if (val != null) controller.setRecordFrequency(val);
                    },
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF3B494B), width: 1),
      ),
      child: Column(
        children: [
          _buildAboutRow(
            label: 'App Version',
            valueWidget: const Text(
              'v2.4.1-stable',
              style: TextStyle(
                color: Color(0xFF00F0FF),
                fontSize: 12,
                fontFamily: 'JetBrains Mono',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Divider(color: Color(0xFF3B494B), height: 16, thickness: 0.5),
          _buildAboutRow(
            label: 'Technical Support',
            valueWidget: const Icon(Icons.open_in_new_rounded, color: Color(0xFF849495), size: 16),
            onTap: () => _showTextDialog(context, 'Technical Support', 'Technical Support can be reached at engineering@speedcheck.insagrp.com.'),
          ),
          const Divider(color: Color(0xFF3B494B), height: 16, thickness: 0.5),
          _buildAboutRow(
            label: 'Privacy Policy',
            valueWidget: const Icon(Icons.chevron_right_rounded, color: Color(0xFF849495), size: 18),
            onTap: () => _showTextDialog(context, 'Privacy Policy', 'SpeedCheck values your privacy. All telemetry metrics collected are stored locally and only synced to the server upon user request or automatic synchronization setup.'),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutRow({
    required String label,
    required Widget valueWidget,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFE2E2E8),
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
            valueWidget,
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticFooter() {
    return const Center(
      child: Text(
        'DIAGNOSTIC CORE // SYSTEM_STATUS: OK',
        style: TextStyle(
          color: Color(0xFF849495),
          fontSize: 9,
          fontFamily: 'JetBrains Mono',
          letterSpacing: 0.08,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showLocationEditDialog(BuildContext context, SettingsController controller) {
    final textController = TextEditingController(text: controller.logStorageLocation.value);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2024),
        title: const Text(
          'Log Storage Subpath',
          style: TextStyle(color: Color(0xFFE2E2E8), fontFamily: 'Hanken Grotesk', fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set folder name relative to Documents directory:',
              style: TextStyle(color: Color(0xFF849495), fontSize: 12, fontFamily: 'Inter'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: textController,
              style: const TextStyle(color: Color(0xFFE2E2E8), fontFamily: 'JetBrains Mono', fontSize: 13),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF3B494B))),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00F0FF))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL', style: TextStyle(color: Color(0xFF849495), fontFamily: 'JetBrains Mono')),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text('SAVE', style: TextStyle(color: Color(0xFF00F0FF), fontFamily: 'JetBrains Mono')),
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                controller.setLogStorageLocation(textController.text.trim());
              }
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showNamingConventionDialog(BuildContext context, SettingsController controller) {
    final textController = TextEditingController(text: controller.logNamingConvention.value);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2024),
        title: const Text(
          'Naming Pattern',
          style: TextStyle(color: Color(0xFFE2E2E8), fontFamily: 'Hanken Grotesk', fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Use TIMESTAMP placeholder for date prefix:',
              style: TextStyle(color: Color(0xFF849495), fontSize: 12, fontFamily: 'Inter'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: textController,
              style: const TextStyle(color: Color(0xFFE2E2E8), fontFamily: 'JetBrains Mono', fontSize: 13),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF3B494B))),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00F0FF))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL', style: TextStyle(color: Color(0xFF849495), fontFamily: 'JetBrains Mono')),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text('SAVE', style: TextStyle(color: Color(0xFF00F0FF), fontFamily: 'JetBrains Mono')),
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                controller.setLogNamingConvention(textController.text.trim());
              }
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showTextDialog(BuildContext context, String title, String text) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2024),
        title: Text(
          title,
          style: const TextStyle(color: Color(0xFFE2E2E8), fontFamily: 'Hanken Grotesk', fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Text(
          text,
          style: const TextStyle(color: Color(0xFF849495), fontSize: 13, fontFamily: 'Inter', height: 1.4),
        ),
        actions: [
          TextButton(
            child: const Text('OK', style: TextStyle(color: Color(0xFF00F0FF), fontFamily: 'JetBrains Mono')),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }
}
