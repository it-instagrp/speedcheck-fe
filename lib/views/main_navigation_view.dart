import 'package:flutter/material.dart';
import 'home_view.dart';
import 'neighbors_view.dart';
import 'charts_view.dart';
import 'license_view.dart';
import 'settings_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({Key? key}) : super(key: key);

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeView(),
    NeighborsView(),
    ChartsView(),
    LicenseView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111318), // Midnight Dark
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        height: 72,
        decoration: const BoxDecoration(
          color: Color(0xFF0C0E12), // lowest surface container
          border: Border(
            top: BorderSide(color: Color(0xFF1A1C20), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.bar_chart_rounded, 'Home'),
            _buildNavItem(1, Icons.cell_tower_rounded, 'Neighbors'),
            _buildNavItem(2, Icons.show_chart_rounded, 'Trends'),
            _buildNavItem(3, Icons.badge_outlined, 'License'),
            _buildNavItem(4, Icons.settings_outlined, 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final activeColor = const Color(0xFF00F0FF); // Electric Cyan
    final inactiveColor = const Color(0xFF849495); // Muted Outline

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top indicator line
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: isSelected ? 40 : 0,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(1),
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withOpacity(0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontFamily: 'Inter',
                letterSpacing: 0.2,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
