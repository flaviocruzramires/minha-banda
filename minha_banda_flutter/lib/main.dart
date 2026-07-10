import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/cadastro_dados_pessoais_page.dart';

void main() {
  runApp(const ProviderScope(child: MinhaBandaApp()));
}

class MinhaBandaApp extends StatelessWidget {
  const MinhaBandaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minha Banda',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const CadastroDadosPessoaisPage(),
    );
  }
}
