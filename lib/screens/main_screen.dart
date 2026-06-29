import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'analytics_screen.dart';
import 'plans_screen.dart';
import 'calculator_screen.dart';
import 'settings_screen.dart';
import '../providers/theme_provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Widget> _screens = const [
    AnalyticsScreen(),
    PlansScreen(),
    CalculatorScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _goToPage(int index) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayTrack', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Column(
        children: [
          // Glassy Top Navigation Pill
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? const Color(0xFF2C2C2E)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                children: [
                  _buildTopNavButton(0, Icons.explore_rounded, 'Dashboard'),
                  _buildTopNavButton(1, Icons.folder_copy_rounded, 'My Plans'),
                  _buildTopNavButton(2, Icons.calculate_rounded, 'Calculator'),
                ],
              ),
            ),
          ),
          // Main Swipeable Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIndicator(0),
              const SizedBox(width: 8),
              _buildIndicator(1),
              const SizedBox(width: 8),
              _buildIndicator(2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavButton(int index, IconData icon, String label) {
    final isActive = _currentPage == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final selectedBgColor = isDark ? const Color(0xFF48484A) : Colors.white;
    final unselectedBgColor = Colors.transparent;
    
    final selectedIconColor = isDark ? Colors.white : Colors.black87;
    final unselectedIconColor = isDark ? Colors.white54 : Colors.black54;

    return Expanded(
      child: GestureDetector(
        onTap: () => _goToPage(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            color: isActive ? selectedBgColor : unselectedBgColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isActive && !isDark ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ] : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon, 
                color: isActive ? selectedIconColor : unselectedIconColor, 
                size: 26
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? selectedIconColor : unselectedIconColor,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(int index) {
    final isActive = _currentPage == index;
    return GestureDetector(
      onTap: () => _goToPage(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 8,
        width: isActive ? 24 : 12,
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
