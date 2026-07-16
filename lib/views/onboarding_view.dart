import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                
                // Welcome Banner Header
                _buildHeader(),
                
                const SizedBox(height: 32),
                
                // Onboarding Permissions List
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Obx(() => _buildPermissionCard(
                              title: 'GPS Location Access',
                              description: 'Required to collect exact latitude, longitude, movement speed, and accuracy parameters for cell diagnostic mapping.',
                              icon: Icons.location_on_rounded,
                              iconColor: const Color(0xFF38BDF8), // Cyan Blue
                              isGranted: controller.isLocationGranted.value,
                              onGrantTap: controller.requestLocation,
                            )),
                        const SizedBox(height: 16),
                        Obx(() => _buildPermissionCard(
                              title: 'Phone & Cellular Status',
                              description: 'Required to query physical network technology (2G/3G/4G/5G), carrier operator names, Cell ID, PCI, TAC, and signal levels (RSRP/RSRQ/RSSI/RSSNR).',
                              icon: Icons.phone_android_rounded,
                              iconColor: const Color(0xFFF59E0B), // Amber
                              isGranted: controller.isPhoneGranted.value,
                              onGrantTap: controller.requestPhone,
                            )),
                        const SizedBox(height: 16),
                        Obx(() => _buildPermissionCard(
                              title: 'Notification Services',
                              description: 'Required to post a persistent foreground service notification. This guarantees Android keeps logging telemetry continuously in the background.',
                              icon: Icons.notifications_active_rounded,
                              iconColor: const Color(0xFFEC4899), // Pink
                              isGranted: controller.isNotificationGranted.value,
                              onGrantTap: controller.requestNotification,
                            )),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                
                // Action Action Buttons
                Obx(() {
                  final ready = controller.allGranted;
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (ready) {
                            controller.completeOnboarding();
                          } else {
                            controller.requestAllPermissions();
                            toastification.show(
                              context: context,
                              type: ToastificationType.info,
                              style: ToastificationStyle.flatColored,
                              title: const Text('Requesting Permissions'),
                              description: const Text('Please approve the system dialogs to set up telemetry.'),
                              autoCloseDuration: const Duration(seconds: 4),
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: ready
                                  ? [const Color(0xFF10B981), const Color(0xFF059669)] // Green Go
                                  : [const Color(0xFF06B6D4), const Color(0xFF4F46E5)], // Cyan Request
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: ready
                                    ? Colors.green.withOpacity(0.3)
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
                                Icon(ready ? Icons.check_circle_rounded : Icons.security, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  ready ? 'CONTINUE TO DASHBOARD' : 'GRANT ALL PERMISSIONS',
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
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'All permissions are required for accurate network analytics.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white24, fontSize: 11),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF06B6D4).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: const Icon(Icons.speed_rounded, color: Colors.white, size: 48),
        ),
        const SizedBox(height: 20),
        const Text(
          'Telemetry Configuration',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Allow SpeedCheck to collect network vitals on your device',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white38, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildPermissionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required bool isGranted,
    required VoidCallback onGrantTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isGranted
                  ? Colors.green.withOpacity(0.3)
                  : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isGranted ? Icons.check_circle_outline_rounded : Icons.pending_outlined,
                              color: isGranted ? Colors.greenAccent : Colors.orangeAccent,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isGranted ? 'Permission Granted' : 'Pending Authorization',
                              style: TextStyle(
                                color: isGranted ? Colors.greenAccent : Colors.orangeAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (!isGranted)
                          ElevatedButton(
                            onPressed: onGrantTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.08),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Grant', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
