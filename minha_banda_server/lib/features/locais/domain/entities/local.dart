class Local {
  const Local({
    required this.id,
    required this.nome,
    this.endereco,
    required this.cidade,
    required this.tipo,
    this.capacidade,
    this.contato,
    required this.temSom,
    required this.temCamarim,
    this.notas,
    required this.criadoPor,
    required this.criadoEm,
  });

  final String id;
  final String nome;
  final String? endereco;
  final String cidade;
  final String tipo;
  final int? capacidade;
  final String? contato;
  final bool temSom;
  final bool temCamarim;
  final String? notas;
  final String criadoPor;
  final DateTime criadoEm;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'endereco': endereco,
        'cidade': cidade,
        'tipo': tipo,
        'capacidade': capacidade,
        'contato': contato,
        'temSom': temSom,
        'temCamarim': temCamarim,
        'notas': notas,
        'criadoPor': criadoPor,
        'criadoEm': criadoEm.toIso8601String(),
      };
}
