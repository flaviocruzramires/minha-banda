import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.nomeArtistico,
    required this.email,
  });

  final String id;
  final String nomeArtistico;
  final String email;

  @override
  List<Object?> get props => [id, nomeArtistico, email];
}
