import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../notifiers/locais_notifier.dart';

class LocalFormPage extends ConsumerStatefulWidget {
  const LocalFormPage({super.key});

  @override
  ConsumerState<LocalFormPage> createState() => _LocalFormPageState();
}

class _LocalFormPageState extends ConsumerState<LocalFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _cidade = TextEditingController();
  final _capacidade = TextEditingController();
  final _contato = TextEditingController();
  final _notas = TextEditingController();
  String _tipo = 'bar';
  bool _temSom = false;
  bool _temCamarim = false;

  @override
  void dispose() {
    _nome.dispose(); _cidade.dispose(); _capacidade.dispose();
    _contato.dispose(); _notas.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(locaisNotifierProvider.notifier).criar(
      nome: _nome.text.trim(),
      cidade: _cidade.text.trim(),
      tipo: _tipo,
      capacidade: int.tryParse(_capacidade.text),
      contato: _contato.text.trim().isEmpty ? null : _contato.text.trim(),
      temSom: _temSom,
      temCamarim: _temCamarim,
      notas: _notas.text.trim().isEmpty ? null : _notas.text.trim(),
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.stageBlack,
      appBar: AppBar(
        backgroundColor: AppColors.stageBlack2,
        title: const Text('Novo Local', style: TextStyle(color: AppColors.warmWhite)),
        iconTheme: const IconThemeData(color: AppColors.warmWhite),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _nome, style: const TextStyle(color: AppColors.warmWhite),
              decoration: const InputDecoration(labelText: 'Nome *', labelStyle: TextStyle(color: AppColors.hintText)),
              validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _cidade, style: const TextStyle(color: AppColors.warmWhite),
              decoration: const InputDecoration(labelText: 'Cidade *', labelStyle: TextStyle(color: AppColors.hintText)),
              validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _tipo,
              dropdownColor: AppColors.stageBlack2,
              style: const TextStyle(color: AppColors.warmWhite),
              decoration: const InputDecoration(labelText: 'Tipo', labelStyle: TextStyle(color: AppColors.hintText)),
              items: const [
                DropdownMenuItem(value: 'bar', child: Text('Bar')),
                DropdownMenuItem(value: 'teatro', child: Text('Teatro')),
                DropdownMenuItem(value: 'arena', child: Text('Arena')),
                DropdownMenuItem(value: 'outro', child: Text('Outro')),
              ],
              onChanged: (v) => setState(() => _tipo = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _capacidade, style: const TextStyle(color: AppColors.warmWhite),
              decoration: const InputDecoration(labelText: 'Capacidade', labelStyle: TextStyle(color: AppColors.hintText)),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
            const SizedBox(height: 12),
            TextFormField(controller: _contato, style: const TextStyle(color: AppColors.warmWhite),
              decoration: const InputDecoration(labelText: 'Contato', labelStyle: TextStyle(color: AppColors.hintText))),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _temSom, onChanged: (v) => setState(() => _temSom = v!),
              title: const Text('Tem som', style: TextStyle(color: AppColors.warmWhite)),
              activeColor: AppColors.spotlight, checkColor: AppColors.stageBlack,
            ),
            CheckboxListTile(
              value: _temCamarim, onChanged: (v) => setState(() => _temCamarim = v!),
              title: const Text('Tem camarim', style: TextStyle(color: AppColors.warmWhite)),
              activeColor: AppColors.spotlight, checkColor: AppColors.stageBlack,
            ),
            const SizedBox(height: 8),
            TextFormField(controller: _notas, style: const TextStyle(color: AppColors.warmWhite),
              decoration: const InputDecoration(labelText: 'Notas', labelStyle: TextStyle(color: AppColors.hintText)),
              maxLines: 3),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _salvar, child: const Text('Criar')),
          ],
        ),
      ),
    );
  }
}
