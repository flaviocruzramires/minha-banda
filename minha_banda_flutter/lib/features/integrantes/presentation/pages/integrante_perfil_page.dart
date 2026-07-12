import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../notifiers/integrantes_notifier.dart';
import '../../domain/entities/integrante.dart';

class IntegrantePerfilPage extends ConsumerStatefulWidget {
  const IntegrantePerfilPage({super.key, required this.integrante});
  final Integrante integrante;

  @override
  ConsumerState<IntegrantePerfilPage> createState() => _IntegrantePerfilPageState();
}

class _IntegrantePerfilPageState extends ConsumerState<IntegrantePerfilPage> {
  bool _editMode = false;
  late final TextEditingController _apelido;
  late final TextEditingController _instrumento;
  late final TextEditingController _nomeArtistico;
  late final TextEditingController _email;
  late String _papel;

  @override
  void initState() {
    super.initState();
    final i = widget.integrante;
    _apelido = TextEditingController(text: i.apelido ?? '');
    _instrumento = TextEditingController(text: i.instrumento ?? '');
    _nomeArtistico = TextEditingController(text: i.nomeArtistico ?? '');
    _email = TextEditingController(text: i.email ?? '');
    _papel = i.papel;
  }

  @override
  void dispose() {
    _apelido.dispose(); _instrumento.dispose();
    _nomeArtistico.dispose(); _email.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final updated = Integrante(
      id: widget.integrante.id,
      userId: widget.integrante.userId,
      bandaId: widget.integrante.bandaId,
      papel: _papel,
      instrumento: _instrumento.text.trim().isEmpty ? null : _instrumento.text.trim(),
      apelido: _apelido.text.trim().isEmpty ? null : _apelido.text.trim(),
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      nomeArtistico: _nomeArtistico.text.trim().isEmpty ? null : _nomeArtistico.text.trim(),
    );
    await ref.read(integrantesNotifierProvider.notifier).atualizar(updated);
    if (mounted) setState(() => _editMode = false);
  }

  @override
  Widget build(BuildContext context) {
    final i = widget.integrante;
    final displayName = i.apelido ?? i.nomeArtistico ?? 'U';

    return Scaffold(
      backgroundColor: AppColors.stageBlack,
      appBar: AppBar(
        backgroundColor: AppColors.stageBlack2,
        title: Text(displayName, style: const TextStyle(color: AppColors.warmWhite)),
        iconTheme: const IconThemeData(color: AppColors.warmWhite),
        actions: [
          if (!_editMode)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.spotlight),
              onPressed: () => setState(() => _editMode = true),
            ),
        ],
      ),
      body: _editMode ? _buildEditForm() : _buildView(i),
    );
  }

  Widget _buildView(Integrante i) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.spotlight,
            child: Text(
              (i.apelido ?? i.nomeArtistico ?? 'U')[0].toUpperCase(),
              style: const TextStyle(color: AppColors.stageBlack, fontSize: 32, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (i.apelido != null) _InfoRow('Apelido', i.apelido!),
        if (i.nomeArtistico != null) _InfoRow('Nome artístico', i.nomeArtistico!),
        if (i.email != null) _InfoRow('E-mail', i.email!),
        _InfoRow('Papel', i.papel),
        if (i.instrumento != null) _InfoRow('Instrumento', i.instrumento!),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () async {
            await ref.read(integrantesNotifierProvider.notifier).remover(i);
            if (mounted) context.pop();
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.danger),
            foregroundColor: AppColors.danger,
          ),
          child: const Text('Remover integrante'),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextFormField(controller: _apelido, style: const TextStyle(color: AppColors.warmWhite),
          decoration: const InputDecoration(labelText: 'Apelido', labelStyle: TextStyle(color: AppColors.hintText))),
        const SizedBox(height: 12),
        TextFormField(controller: _nomeArtistico, style: const TextStyle(color: AppColors.warmWhite),
          decoration: const InputDecoration(labelText: 'Nome artístico', labelStyle: TextStyle(color: AppColors.hintText))),
        const SizedBox(height: 12),
        TextFormField(controller: _email, style: const TextStyle(color: AppColors.warmWhite),
          decoration: const InputDecoration(labelText: 'E-mail', labelStyle: TextStyle(color: AppColors.hintText))),
        const SizedBox(height: 12),
        TextFormField(controller: _instrumento, style: const TextStyle(color: AppColors.warmWhite),
          decoration: const InputDecoration(labelText: 'Instrumento', labelStyle: TextStyle(color: AppColors.hintText))),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: _papel,
          style: const TextStyle(color: AppColors.warmWhite),
          decoration: const InputDecoration(labelText: 'Papel', labelStyle: TextStyle(color: AppColors.hintText)),
          onChanged: (v) => _papel = v,
        ),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _editMode = false),
          child: const Text('Cancelar', style: TextStyle(color: AppColors.bodyText)),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.hintText, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: AppColors.warmWhite, fontSize: 16)),
      ]),
    );
  }
}
