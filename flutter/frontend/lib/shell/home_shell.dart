import 'package:flutter/material.dart';
import '../main.dart';
import '../screens/chat_screen.dart';
import '../screens/lens_screen.dart';

/// Root shell — hosts the two main features (Chat planner, Lens identifier)
/// behind a persistent bottom NavigationBar. Each screen keeps its own
/// Scaffold so its AppBar / drawer behaviour is preserved.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Let each child scaffold paint its own background gradient.
      backgroundColor: SeoulPalette.cream,
      body: IndexedStack(
        index: _index,
        children: const [
          ChatScreen(),
          LensScreen(),
        ],
      ),
      bottomNavigationBar: _SeoulNavBar(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _SeoulNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _SeoulNavBar({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: SeoulPalette.persimmon.withValues(alpha: 0.10),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: SeoulPalette.hanNavy.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.transparent,
            indicatorColor: SeoulPalette.persimmon.withValues(alpha: 0.12),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: selected
                    ? SeoulPalette.persimmon
                    : SeoulPalette.hanNavy.withValues(alpha: 0.6),
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return IconThemeData(
                color: selected
                    ? SeoulPalette.persimmon
                    : SeoulPalette.hanNavy.withValues(alpha: 0.55),
              );
            }),
          ),
          child: NavigationBar(
            height: 64,
            elevation: 0,
            selectedIndex: index,
            onDestinationSelected: onChanged,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: 'Plan',
              ),
              NavigationDestination(
                icon: Icon(Icons.camera_alt_outlined),
                selectedIcon: Icon(Icons.camera_alt),
                label: 'Lens',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
