import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../notifiers/teleprompter_notifier.dart';

class TeleprompterPage extends ConsumerStatefulWidget {
  const TeleprompterPage({super.key, required this.eventoId});
  final String eventoId;

  @override
  ConsumerState<TeleprompterPage> createState() => _TeleprompterPageState();
}

class _TeleprompterPageState extends ConsumerState<TeleprompterPage> {
  final _scrollController = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    Future.microtask(
      () => ref.read(teleprompterNotifierProvider.notifier).carregar(widget.eventoId),
    );
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startScroll(double velocidade) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!_scrollController.hasClients) return;
      final current = _scrollController.offset;
      final max = _scrollController.position.maxScrollExtent;
      if (current >= max) {
        _timer?.cancel();
        ref.read(teleprompterNotifierProvider.notifier).toggleRolar();
        return;
      }
      _scrollController.jumpTo((current + velocidade * 2).clamp(0.0, max));
    });
  }

  void _stopScroll() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teleprompterNotifierProvider);

    // React to rolando changes
    ref.listen<TeleprompterState>(teleprompterNotifierProvider, (prev, next) {
      if (next.rolando && !(prev?.rolando ?? false)) {
        _startScroll(next.velocidade);
      } else if (!next.rolando && (prev?.rolando ?? false)) {
        _stopScroll();
      } else if (next.rolando && next.velocidade != prev?.velocidade) {
        _startScroll(next.velocidade);
      }
    });

    final musica = state.musicas.isNotEmpty ? state.musicas[state.indiceSelecionado] : null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(musica?.titulo ?? 'Teleprompter', style: const TextStyle(color: Colors.white)),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : state.hasError
              ? Center(child: Text(state.erro ?? '', style: const TextStyle(color: Colors.red)))
              : state.musicas.isEmpty
                  ? const Center(child: Text('Nenhuma música.', style: TextStyle(color: Colors.white)))
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  musica?.titulo ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (musica?.artistaOriginal != null)
                                  Text(
                                    musica!.artistaOriginal!,
                                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                                  ),
                                const SizedBox(height: 24),
                                Text(
                                  musica?.letra ?? '(sem letra)',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    height: 1.8,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
                        _BottomControls(
                          musicas: state.musicas.map((m) => m.titulo).toList(),
                          indice: state.indiceSelecionado,
                          rolando: state.rolando,
                          velocidade: state.velocidade,
                          onPrev: () {
                            ref.read(teleprompterNotifierProvider.notifier).selecionarMusica(state.indiceSelecionado - 1);
                            _scrollController.jumpTo(0);
                          },
                          onPlay: () => ref.read(teleprompterNotifierProvider.notifier).toggleRolar(),
                          onNext: () {
                            ref.read(teleprompterNotifierProvider.notifier).selecionarMusica(state.indiceSelecionado + 1);
                            _scrollController.jumpTo(0);
                          },
                          onVelocidade: (v) => ref.read(teleprompterNotifierProvider.notifier).setVelocidade(v),
                        ),
                      ],
                    ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.musicas,
    required this.indice,
    required this.rolando,
    required this.velocidade,
    required this.onPrev,
    required this.onPlay,
    required this.onNext,
    required this.onVelocidade,
  });

  final List<String> musicas;
  final int indice;
  final bool rolando;
  final double velocidade;
  final VoidCallback onPrev, onPlay, onNext;
  final void Function(double) onVelocidade;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                onPressed: indice > 0 ? onPrev : null,
              ),
              IconButton(
                icon: Icon(rolando ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 36),
                onPressed: onPlay,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                onPressed: indice < musicas.length - 1 ? onNext : null,
              ),
            ],
          ),
          Row(
            children: [
              const Text('0.5x', style: TextStyle(color: Colors.grey, fontSize: 11)),
              Expanded(
                child: Slider(
                  value: velocidade,
                  min: 0.5,
                  max: 3.0,
                  divisions: 25,
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey,
                  onChanged: onVelocidade,
                ),
              ),
              const Text('3x', style: TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
