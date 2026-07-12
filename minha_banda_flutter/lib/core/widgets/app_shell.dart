import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_token_provider.dart';
import '../theme/app_theme.dart';
import '../../features/contexto/presentation/notifiers/contexto_notifier.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    _Tab(icon: Icons.calendar_month, label: 'Agenda', path: '/'),
    _Tab(icon: Icons.event, label: 'Eventos', path: '/eventos'),
    _Tab(icon: Icons.library_music, label: 'Repertório', path: '/repertorio'),
    _Tab(icon: Icons.group, label: 'Integrantes', path: '/integrantes'),
    _Tab(icon: Icons.place, label: 'Locais', path: '/locais'),
  ];

  int _selectedIndex(String location) {
    if (location.startsWith('/eventos')) return 1;
    if (location.startsWith('/repertorio')) return 2;
    if (location.startsWith('/integrantes')) return 3;
    if (location.startsWith('/locais')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _selectedIndex(location);
    final contexto = ref.watch(contextoNotifierProvider);
    final bandaId = contexto.ativo?.id ?? '';
    final bandaNome = contexto.ativo?.nome ?? 'Minha Banda';

    return Scaffold(
      backgroundColor: AppColors.stageBlack,
      appBar: AppBar(
        backgroundColor: AppColors.stageBlack2,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _tabs[selectedIndex].label,
              style: const TextStyle(color: AppColors.warmWhite, fontSize: 17, fontWeight: FontWeight.w700),
            ),
            Text(
              bandaNome,
              style: const TextStyle(color: AppColors.spotlight, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<_MenuAction>(
            icon: const Icon(Icons.more_vert, color: AppColors.warmWhite),
            color: AppColors.stageBlack2,
            onSelected: (action) async {
              switch (action) {
                case _MenuAction.trocarBanda:
                  ref.read(contextoNotifierProvider.notifier).limpar();
                  await ref.read(contextoNotifierProvider.notifier).carregar();
                  if (context.mounted) context.go('/seletor-contexto');
                case _MenuAction.sair:
                  await ref.read(authTokenProvider.notifier).clearToken();
                  ref.read(contextoNotifierProvider.notifier).limpar();
              }
            },
            itemBuilder: (_) => [
              if ((contexto.vinculos.length) > 1)
                const PopupMenuItem(
                  value: _MenuAction.trocarBanda,
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz, color: AppColors.spotlight, size: 20),
                      SizedBox(width: 10),
                      Text('Trocar banda', style: TextStyle(color: AppColors.warmWhite)),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: _MenuAction.sair,
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.danger, size: 20),
                    SizedBox(width: 10),
                    Text('Sair', style: TextStyle(color: AppColors.danger)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.stageBlack2,
        indicatorColor: AppColors.spotlight.withOpacity(0.2),
        selectedIndex: selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (i) => _navigate(context, i, bandaId),
        destinations: _tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.icon, color: AppColors.bodyText),
                  selectedIcon: Icon(t.icon, color: AppColors.spotlight),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }

  void _navigate(BuildContext context, int index, String bandaId) {
    if (index != 0 && index != 4 && bandaId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aguarde o carregamento da banda...')),
      );
      return;
    }
    switch (index) {
      case 0:
        context.go('/');
      case 1:
        context.go('/eventos/$bandaId');
      case 2:
        context.go('/repertorio/$bandaId');
      case 3:
        context.go('/integrantes/$bandaId');
      case 4:
        context.go('/locais');
    }
  }
}

enum _MenuAction { trocarBanda, sair }

class _Tab {
  const _Tab({required this.icon, required this.label, required this.path});
  final IconData icon;
  final String label;
  final String path;
}
