import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Banda extends Equatable {
  const Banda({
    required this.id,
    required this.nome,
    required this.generoMusical,
    required this.cidade,
    required this.cor,
  });

  final String id;
  final String nome;
  final String generoMusical;
  final String cidade;
  final Color cor;

  @override
  List<Object?> get props => [id, nome, generoMusical, cidade, cor];
}
