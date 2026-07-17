import 'package:flutter/material.dart';

class LicenseView extends StatelessWidget {
  const LicenseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111318), // Midnight Dark
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSectionHeader(Icons.verified_user_rounded, 'LICENSE INFORMATION'),
                    const SizedBox(height: 8),

                    // Primary License Info Card
                    _buildMainLicenseCard(),
                    const SizedBox(height: 16),

                    // Node Diagnostics Card
                    _buildSectionHeader(Icons.terminal_rounded, 'NODE AUDIT LOGS'),
                    const SizedBox(height: 8),
                    _buildNodeAuditCard(),
                    const SizedBox(height: 32),

                    // System validation line
                    const Center(
                      child: Text(
                        'DIAGNOSTIC CORE // LICENSE_VERIFIED: OK',
                        style: TextStyle(
                          color: Color(0xFF849495),
                          fontSize: 9,
                          fontFamily: 'JetBrains Mono',
                          letterSpacing: 0.08,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
            children: const [
              Icon(Icons.workspace_premium_rounded, color: Color(0xFF00F0FF), size: 22),
              SizedBox(width: 8),
              Text(
                'License',
                style: TextStyle(
                  color: Color(0xFF00F0FF),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Hanken Grotesk',
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF00FF41).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.3), width: 1),
            ),
            child: const Text(
              'ACTIVE',
              style: TextStyle(
                color: Color(0xFF00FF41),
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

  Widget _buildMainLicenseCard() {
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
          const Text(
            'Enterprise Network License',
            style: TextStyle(
              color: Color(0xFFE2E2E8),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Hanken Grotesk',
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Insta ICT Solutions Pvt Ltd',
            style: TextStyle(
              color: Color(0xFF00F0FF),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
          const Divider(color: Color(0xFF3B494B), height: 24, thickness: 0.5),
          _buildInfoRow('License Key', 'SC-9482-1049-XT82-5920'),
          _buildInfoRow('Assigned Node ID', 'NCI-38274910-CORE'),
          _buildInfoRow('Valid Until', 'December 31, 2026'),
          _buildInfoRow('Usage Limit', 'Unlimited Diagnostics'),
          _buildInfoRow('API Access Status', 'SYNCHRONIZATION GRANTED'),
        ],
      ),
    );
  }

  Widget _buildNodeAuditCard() {
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
          const Text(
            'NODE INTEGRITY STATUS',
            style: TextStyle(
              color: Color(0xFFE2E2E8),
              fontSize: 11,
              fontFamily: 'JetBrains Mono',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildAuditRow('2026-07-16 11:42:00', 'LICENSE_KEY_VALIDATION', 'SUCCESS'),
          _buildAuditRow('2026-07-16 11:42:02', 'API_HANDSHAKE_PULL', 'OK'),
          _buildAuditRow('2026-07-16 11:42:05', 'DIAGNOSTIC_CORE_INIT', 'SECURE_LINK'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
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
              fontSize: 12,
              fontFamily: 'JetBrains Mono',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditRow(String timestamp, String event, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timestamp,
                style: const TextStyle(color: Color(0xFF849495), fontSize: 10, fontFamily: 'JetBrains Mono'),
              ),
              Text(
                status,
                style: const TextStyle(color: Color(0xFF00FF41), fontSize: 10, fontFamily: 'JetBrains Mono', fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '> $event',
            style: const TextStyle(color: Color(0xFFE2E2E8), fontSize: 11, fontFamily: 'JetBrains Mono'),
          ),
          const Divider(color: Color(0xFF3B494B), height: 12, thickness: 0.5),
        ],
      ),
    );
  }
}
