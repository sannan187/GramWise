import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/calculator/presentation/calculator_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/price_book/presentation/price_book_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// Navigation shell wrapping the Material 3 NavigationBar and preserving tab state via IndexedStack.
class NavigationShell extends ConsumerWidget {
  const NavigationShell({super.key});

  final List<Widget> _destinations = const [
    CalculatorScreen(),
    HistoryScreen(),
    PriceBookScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _destinations,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          ref.read(navigationIndexProvider.notifier).state = index;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Price Book',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
