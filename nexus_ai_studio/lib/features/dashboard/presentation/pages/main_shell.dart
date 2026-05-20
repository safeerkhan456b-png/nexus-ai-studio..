import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../autopilot/bloc/autopilot_bloc.dart';
import 'home_page.dart';
import '../../../trends/presentation/pages/trends_page.dart';
import '../../../studio/presentation/pages/studio_page.dart';
import '../../../queue/presentation/pages/queue_page.dart';
import '../../../analytics/presentation/pages/analytics_page.dart';
import '../../../autopilot/presentation/pages/autopilot_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final _pageCtrl = PageController();

  static const _pages = [
    HomePage(), TrendsPage(), StudioPage(),
    QueuePage(), AnalyticsPage(), AutopilotPage(),
  ];

  static const _navItems = [
    _NavItem(Icons.dashboard_rounded, 'Home'),
    _NavItem(Icons.trending_up_rounded, 'Trends'),
    _NavItem(Icons.auto_awesome_rounded, 'Studio'),
    _NavItem(Icons.upload_rounded, 'Queue'),
    _NavItem(Icons.bar_chart_rounded, 'Stats'),
    _NavItem(Icons.bolt_rounded, 'Pilot'),
  ];

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  void _onTab(int i) {
    if (i == _currentIndex) return;
    setState(() => _currentIndex = i);
    _pageCtrl.jumpToPage(i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusColors.background,
      body: Column(children: [
        SizedBox(height: MediaQuery.of(context).padding.top),
        _AutopilotBanner(),
        Expanded(child: PageView(
          controller: _pageCtrl,
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
        )),
      ]),
      floatingActionButton: _currentIndex != 2
          ? FloatingActionButton.extended(
              onPressed: () => _onTab(2),
              backgroundColor: NexusColors.primary,
              elevation: 8,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('New Video', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: NexusColors.surface, border: Border(top: BorderSide(color: NexusColors.border))),
        child: SafeArea(child: SizedBox(
          height: 62,
          child: Row(children: List.generate(_navItems.length, (i) {
            final active = i == _currentIndex;
            final item = _navItems[i];
            return Expanded(
              child: GestureDetector(
                onTap: () => _onTab(i),
                behavior: HitTestBehavior.opaque,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: active ? 22 : 0, height: 3,
                    margin: const EdgeInsets.only(bottom: 3),
                    decoration: BoxDecoration(color: NexusColors.primary, borderRadius: BorderRadius.circular(2)),
                  ),
                  Icon(item.icon, size: 21, color: active ? NexusColors.primary : NexusColors.textMuted),
                  const SizedBox(height: 2),
                  Text(item.label, style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w400, color: active ? NexusColors.primary : NexusColors.textMuted)),
                ]),
              ),
            );
          })),
        )),
      ),
    );
  }
}

class _AutopilotBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AutopilotBloc, AutopilotState>(
      builder: (context, state) {
        if (state is! AutopilotActiveState) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [NexusColors.accent.withOpacity(0.12), NexusColors.primary.withOpacity(0.08)]),
            border: const Border(bottom: BorderSide(color: NexusColors.accent, width: 0.5)),
          ),
          child: Row(children: [
            Container(width: 6, height: 6, decoration: const BoxDecoration(color: NexusColors.accent, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text('🤖 AUTOPILOT ACTIVE — ${state.videosToday} videos today',
              style: const TextStyle(fontSize: 11, color: NexusColors.accent, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
          ]),
        );
      },
    );
  }
}

class _NavItem { final IconData icon; final String label; const _NavItem(this.icon, this.label); }
