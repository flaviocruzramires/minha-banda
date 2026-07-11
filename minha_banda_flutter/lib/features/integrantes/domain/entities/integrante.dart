import 'package:equatable/equatable.dart';

class Integrante extends Equatable {
  const Integrante({
    required this.id,
    required this.userId,
    required this.bandaId,
    required this.papel,
    this.instrumento,
    this.apelido,
    this.email,
    this.nomeArtistico,
  });

  final String id, userId, bandaId, papel;
  final String? instrumento, apelido, email, nomeArtistico;

  factory Integrante.fromJson(Map<String, dynamic> j) => Integrante(
        id: j['id'] as String,
        userId: j['userId'] as String,
        bandaId: j['bandaId'] as String,
        papel: j['papel'] as String,
        instrumento: j['instrumento'] as String?,
        apelido: j['apelido'] as String?,
        email: j['email'] as String?,
        nomeArtistico: j['nomeArtistico'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'bandaId': bandaId,
        'papel': papel,
        'instrumento': instrumento,
        'apelido': apelido,
        'email': email,
        'nomeArtistico': nomeArtistico,
      };

  @override
  List<Object?> get props => [id, userId, bandaId, papel, instrumento, apelido, email, nomeArtistico];
}
