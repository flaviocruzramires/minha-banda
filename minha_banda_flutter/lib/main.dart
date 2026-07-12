import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/providers/auth_token_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storedToken = prefs.getString('jwt_token');

  runApp(
    ProviderScope(
      overrides: [
        authTokenProvider.overrideWith(
          (ref) => AuthTokenNotifier(prefs, storedToken),
        ),
      ],
      child: const MinhaBandaApp(),
    ),
  );
}

class MinhaBandaApp extends ConsumerWidget {
  const MinhaBandaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Minha Banda',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
