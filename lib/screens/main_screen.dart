import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'analytics_screen.dart';
import 'plans_screen.dart';
import 'calculator_screen.dart';
import 'settings_screen.dart';
import '../providers/theme_provider.dart';

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
          // Top Navigation Icons
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTopNavButton(0, Icons.bar_chart, 'Analytics'),
                _buildTopNavButton(1, Icons.credit_card, 'My Plans'),
                _buildTopNavButton(2, Icons.calculate, 'Calculator'),
              ],
            ),
          ),
          const Divider(height: 1),
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
    final color = isActive ? Theme.of(context).colorScheme.primary : Colors.grey.shade500;
    
    return InkWell(
      onTap: () => _goToPage(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
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
