import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../../features/contexto/presentation/notifiers/contexto_notifier.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    _Tab(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Início', path: '/'),
    _Tab(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'Agenda', path: '/agenda'),
    _Tab(icon: Icons.event_outlined, activeIcon: Icons.event, label: 'Eventos', path: '/eventos'),
    _Tab(icon: Icons.more_horiz, activeIcon: Icons.more_horiz, label: 'Mais', path: '/mais'),
  ];

  int _selectedIndex(String location) {
    if (location == '/') { return 0; }
    if (location.startsWith('/agenda')) { return 1; }
    if (location.startsWith('/eventos')) { return 2; }
    if (location.startsWith('/mais') ||
        location.startsWith('/repertorio') ||
        location.startsWith('/integrantes') ||
        location.startsWith('/locais')) { return 3; }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _selectedIndex(location);
    final contexto = ref.watch(contextoNotifierProvider);
    final bandaId = contexto.ativo?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.stageBlack,
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.stageBlack2,
        indicatorColor: AppColors.spotlight.withValues(alpha: 0.18),
        selectedIndex: selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (i) => _navigate(context, i, bandaId),
        destinations: _tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.icon, color: AppColors.bodyText),
                  selectedIcon: Icon(t.activeIcon, color: AppColors.spotlight),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }

  void _navigate(BuildContext context, int index, String bandaId) {
    switch (index) {
      case 0:
        context.go('/');
      case 1:
        context.go('/agenda');
      case 2:
        if (bandaId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aguarde o carregamento da banda...')),
          );
          return;
        }
        context.go('/eventos/$bandaId');
      case 3:
        context.go('/mais');
    }
  }
}

class _Tab {
  const _Tab({required this.icon, required this.activeIcon, required this.label, required this.path});
  final IconData icon, activeIcon;
  final String label, path;
}
