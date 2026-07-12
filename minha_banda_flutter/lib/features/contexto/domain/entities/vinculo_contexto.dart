import 'package:equatable/equatable.dart';

class VinculoContexto extends Equatable {
  const VinculoContexto({
    required this.id,
    required this.nome,
    required this.papel,
    required this.tipo,
  });

  final String id, nome, papel;
  final String tipo; // 'banda' | 'local'

  bool get isBanda => tipo == 'banda';

  factory VinculoContexto.fromJson(Map<String, dynamic> j, String tipo) =>
      VinculoContexto(
        id: j['id'] as String,
        nome: j['nome'] as String,
        papel: j['papel'] as String,
        tipo: tipo,
      );

  @override
  List<Object?> get props => [id, nome, papel, tipo];
}
