import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../notifiers/agenda_notifier.dart';

class NovoBloqueioPage extends ConsumerStatefulWidget {
  const NovoBloqueioPage({super.key});

  @override
  ConsumerState<NovoBloqueioPage> createState() => _NovoBloqueioPageState();
}

class _NovoBloqueioPageState extends ConsumerState<NovoBloqueioPage> {
  final _formKey = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  DateTime _inicio = DateTime.now().add(const Duration(hours: 1));
  DateTime _fim = DateTime.now().add(const Duration(hours: 3));

  @override
  void dispose() {
    _titulo.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool isInicio}) async {
    final initial = isInicio ? _inicio : _fim;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.spotlight)),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.spotlight)),
        child: child!,
      ),
    );
    if (time == null) return;
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isInicio) { _inicio = dt; } else { _fim = dt; }
    });
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(agendaNotifierProvider.notifier).adicionarBloqueio(
      userId: 'me',
      titulo: _titulo.text.trim(),
      dataHoraInicio: _inicio,
      dataHoraFim: _fim,
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.stageBlack,
      appBar: AppBar(
        backgroundColor: AppColors.stageBlack2,
        title: const Text('Novo Bloqueio', style: TextStyle(color: AppColors.warmWhite)),
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
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Início', style: TextStyle(color: AppColors.hintText, fontSize: 12)),
              subtitle: Text(_fmt(_inicio), style: const TextStyle(color: AppColors.warmWhite)),
              trailing: const Icon(Icons.access_time, color: AppColors.spotlight),
              onTap: () => _pickDateTime(isInicio: true),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fim', style: TextStyle(color: AppColors.hintText, fontSize: 12)),
              subtitle: Text(_fmt(_fim), style: const TextStyle(color: AppColors.warmWhite)),
              trailing: const Icon(Icons.access_time, color: AppColors.spotlight),
              onTap: () => _pickDateTime(isInicio: false),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
          ],
        ),
      ),
    );
  }
}
