import 'package:equatable/equatable.dart';

class Local extends Equatable {
  const Local({
    required this.id,
    required this.nome,
    required this.cidade,
    required this.tipo,
    this.capacidade,
    this.contato,
    this.temSom = false,
    this.temCamarim = false,
    this.notas,
  });

  final String id, nome, cidade, tipo;
  final int? capacidade;
  final String? contato, notas;
  final bool temSom, temCamarim;

  factory Local.fromJson(Map<String, dynamic> j) => Local(
        id: j['id'] as String,
        nome: j['nome'] as String,
        cidade: j['cidade'] as String,
        tipo: j['tipo'] as String,
        capacidade: j['capacidade'] as int?,
        contato: j['contato'] as String?,
        temSom: (j['temSom'] as bool?) ?? false,
        temCamarim: (j['temCamarim'] as bool?) ?? false,
        notas: j['notas'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'cidade': cidade,
        'tipo': tipo,
        'capacidade': capacidade,
        'contato': contato,
        'temSom': temSom,
        'temCamarim': temCamarim,
        'notas': notas,
      };

  @override
  List<Object?> get props => [id, nome, cidade, tipo, capacidade, contato, temSom, temCamarim, notas];
}
