import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../notifiers/cadastro_notifier.dart';
import '../widgets/campo_palco.dart';
import '../widgets/erro_inline.dart';
import '../widgets/indicador_passos.dart';
import 'cadastro_convites_page.dart';

const _coresBanda = [
  Color(0xFF7A1F3D),
  Color(0xFF1F4D7A),
  Color(0xFF2B7A1F),
  Color(0xFF7A5C1F),
  Color(0xFF4C1F7A),
];

class CadastroCriarBandaPage extends ConsumerStatefulWidget {
  const CadastroCriarBandaPage({super.key});

  static const routeName = '/cadastro/banda';

  @override
  ConsumerState<CadastroCriarBandaPage> createState() =>
      _CadastroCriarBandaPageState();
}

class _CadastroCriarBandaPageState
    extends ConsumerState<CadastroCriarBandaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _generoCtrl = TextEditingController();
  final _cidadeCtrl = TextEditingController();
  Color _corSelecionada = _coresBanda.first;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _generoCtrl.dispose();
    _cidadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _criarBanda() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(cadastroNotifierProvider.notifier).criarBanda(
          nome: _nomeCtrl.text.trim(),
          generoMusical: _generoCtrl.text.trim(),
          cidade: _cidadeCtrl.text.trim(),
          cor: _corSelecionada,
        );
    if (ok && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CadastroConvitesPage()),
      );
    }
  }

  void _pular() {
    ref.read(cadastroNotifierProvider.notifier).pularCriacaoBanda();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CadastroConvitesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cadastroNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.stageBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const IndicadorPassos(total: 3, atual: 2),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Row(
                    children: [
                      Icon(Icons.arrow_back,
                          size: 18, color: AppColors.hintText),
                      SizedBox(width: 4),
                      Text('Voltar',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.hintText)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                Text('PASSO 2 DE 3',
                    style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 4),
                Text('Crie sua banda',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text(
                  'Ou entre numa banda por convite depois.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),

                if (state.hasError && state.erro != null) ...[
                  ErroInline(mensagem: state.erro!),
                  const SizedBox(height: 12),
                ],

                CampoPalco(
                  label: 'Nome da banda',
                  hint: 'Ex.: Os Veteranos',
                  prefixIcon: Icons.music_note_outlined,
                  controller: _nomeCtrl,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Informe o nome da banda'
                      : null,
                ),
                const SizedBox(height: 12),

                CampoPalco(
                  label: 'Gênero musical',
                  hint: 'Ex.: Rock / Blues',
                  prefixIcon: Icons.label_outline,
                  controller: _generoCtrl,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Informe o gênero musical'
                      : null,
                ),
                const SizedBox(height: 12),

                CampoPalco(
                  label: 'Cidade / Estado',
                  hint: 'Ex.: São Paulo, SP',
                  prefixIcon: Icons.location_on_outlined,
                  controller: _cidadeCtrl,
                  textInputAction: TextInputAction.done,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Informe a cidade'
                      : null,
                ),
                const SizedBox(height: 16),

                Text(
                  'COR DA BANDA',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.hintText,
                    letterSpacing: 0.06,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Usada na agenda de todos os integrantes.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: _coresBanda.map((cor) {
                    final selecionada = _corSelecionada == cor;
                    return GestureDetector(
                      key: Key('cor_${cor.toARGB32()}'),
                      onTap: () => setState(() => _corSelecionada = cor),
                      child: Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: cor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selecionada
                                ? AppColors.spotlight
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  key: const Key('btn_criar_banda'),
                  onPressed: state.isLoading ? null : _criarBanda,
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.stageBlack,
                          ),
                        )
                      : const Text('Criar banda'),
                ),
                const SizedBox(height: 12),

                Center(
                  child: GestureDetector(
                    key: const Key('btn_pular_banda'),
                    onTap: _pular,
                    child: const Text(
                      'Pular — vou entrar por convite',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.hintText,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.hintText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
