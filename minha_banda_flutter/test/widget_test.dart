import 'package:flutter_test/flutter_test.dart';
import 'package:minha_banda_flutter/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('app smoke test — abre tela de login sem crash', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MinhaBandaApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Entrar'), findsOneWidget);
  });
}
