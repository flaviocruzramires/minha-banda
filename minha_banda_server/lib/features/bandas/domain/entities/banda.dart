class Banda {
  const Banda({
    required this.id,
    required this.nome,
    required this.generoMusical,
    required this.cidade,
    required this.corHex,
    required this.criadoPor,
    required this.criadoEm,
  });

  final String id;
  final String nome;
  final String generoMusical;
  final String cidade;
  final int corHex;
  final String criadoPor;
  final DateTime criadoEm;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'generoMusical': generoMusical,
        'cidade': cidade,
        'corHex': corHex,
        'criadoPor': criadoPor,
      };
}
