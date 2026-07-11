import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../notifiers/repertorio_notifier.dart';
import '../../domain/entities/musica.dart';

class MusicaFormPage extends ConsumerStatefulWidget {
  const MusicaFormPage({super.key, required this.bandaId, this.musica});
  final String bandaId;
  final Musica? musica;

  @override
  ConsumerState<MusicaFormPage> createState() => _MusicaFormPageState();
}

class _MusicaFormPageState extends ConsumerState<MusicaFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titulo;
  late final TextEditingController _artista;
  late final TextEditingController _tonalidade;
  late final TextEditingController _bpm;
  late final TextEditingController _duracao;
  late final TextEditingController _letra;
  late final TextEditingController _cifra;
  late String _status;

  @override
  void initState() {
    super.initState();
    final m = widget.musica;
    _titulo = TextEditingController(text: m?.titulo ?? '');
    _artista = TextEditingController(text: m?.artistaOriginal ?? '');
    _tonalidade = TextEditingController(text: m?.tonalidade ?? '');
    _bpm = TextEditingController(text: m?.bpm?.toString() ?? '');
    _duracao = TextEditingController(text: m?.duracaoSeg?.toString() ?? '');
    _letra = TextEditingController(text: m?.letra ?? '');
    _cifra = TextEditingController(text: m?.cifra ?? '');
    _status = m?.status ?? 'em_aprendizado';
  }

  @override
  void dispose() {
    _titulo.dispose(); _artista.dispose(); _tonalidade.dispose();
    _bpm.dispose(); _duracao.dispose(); _letra.dispose(); _cifra.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(repertorioNotifierProvider.notifier);
    if (widget.musica == null) {
      await notifier.criar(
        bandaId: widget.bandaId,
        titulo: _titulo.text.trim(),
        artistaOriginal: _artista.text.trim().isEmpty ? null : _artista.text.trim(),
        tonalidade: _tonalidade.text.trim().isEmpty ? null : _tonalidade.text.trim(),
        bpm: int.tryParse(_bpm.text),
        duracaoSeg: int.tryParse(_duracao.text),
        letra: _letra.text.trim().isEmpty ? null : _letra.text.trim(),
        cifra: _cifra.text.trim().isEmpty ? null : _cifra.text.trim(),
        status: _status,
      );
    } else {
      final m = widget.musica!;
      await notifier.atualizar(Musica(
        id: m.id,
        bandaId: m.bandaId,
        titulo: _titulo.text.trim(),
        artistaOriginal: _artista.text.trim().isEmpty ? null : _artista.text.trim(),
        tonalidade: _tonalidade.text.trim().isEmpty ? null : _tonalidade.text.trim(),
        bpm: int.tryParse(_bpm.text),
        duracaoSeg: int.tryParse(_duracao.text),
        letra: _letra.text.trim().isEmpty ? null : _letra.text.trim(),
        cifra: _cifra.text.trim().isEmpty ? null : _cifra.text.trim(),
        status: _status,
      ));
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.musica != null;
    return Scaffold(
      backgroundColor: AppColors.stageBlack,
      appBar: AppBar(
        backgroundColor: AppColors.stageBlack2,
        title: Text(isEdit ? 'Editar Música' : 'Nova Música',
            style: const TextStyle(color: AppColors.warmWhite)),
        iconTheme: const IconThemeData(color: AppColors.warmWhite),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titulo,
              style: const TextStyle(color: AppColors.warmWhite),
              decoration: const InputDecoration(labelText: 'Título *', labelStyle: TextStyle(color: AppColors.hintText)),
              validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _artista, style: const TextStyle(color: AppColors.warmWhite),
              decoration: const InputDecoration(labelText: 'Artista original', labelStyle: TextStyle(color: AppColors.hintText))),
            const SizedBox(height: 12),
            TextFormField(controller: _tonalidade, style: const TextStyle(color: AppColors.warmWhite),
              decoration: const InputDecoration(labelText: 'Tonalidade', labelStyle: TextStyle(color: AppColors.hintText))),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextFormField(controller: _bpm,
                style: const TextStyle(color: AppColors.warmWhite),
                decoration: const InputDecoration(labelText: 'BPM', labelStyle: TextStyle(color: AppColors.hintText)),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly])),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(controller: _duracao,
                style: const TextStyle(color: AppColors.warmWhite),
                decoration: const InputDecoration(labelText: 'Duração (seg)', labelStyle: TextStyle(color: AppColors.hintText)),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly])),
            ]),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              dropdownColor: AppColors.stageBlack2,
              style: const TextStyle(color: AppColors.warmWhite),
              decoration: const InputDecoration(labelText: 'Status', labelStyle: TextStyle(color: AppColors.hintText)),
              items: const [
                DropdownMenuItem(value: 'em_aprendizado', child: Text('Em aprendizado')),
                DropdownMenuItem(value: 'pronto_para_show', child: Text('Pronto para show')),
              ],
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _letra,
              style: const TextStyle(color: AppColors.warmWhite),
              decoration: const InputDecoration(labelText: 'Letra', labelStyle: TextStyle(color: AppColors.hintText)),
              maxLines: 6),
            const SizedBox(height: 12),
            TextFormField(controller: _cifra,
              style: const TextStyle(color: AppColors.warmWhite),
              decoration: const InputDecoration(labelText: 'Cifra', labelStyle: TextStyle(color: AppColors.hintText)),
              maxLines: 6),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _salvar, child: Text(isEdit ? 'Salvar' : 'Criar')),
          ],
        ),
      ),
    );
  }
}
