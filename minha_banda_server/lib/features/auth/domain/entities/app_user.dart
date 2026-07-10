class AppUser {
  const AppUser({
    required this.id,
    required this.nomeArtistico,
    required this.email,
    required this.senhaHash,
    required this.criadoEm,
  });

  final String id;
  final String nomeArtistico;
  final String email;
  final String senhaHash;
  final DateTime criadoEm;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nomeArtistico': nomeArtistico,
        'email': email,
      };
}
