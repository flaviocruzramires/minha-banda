class ResponsavelLocal {
  const ResponsavelLocal({
    required this.id,
    required this.localId,
    required this.userId,
    required this.papel,
  });

  final String id;
  final String localId;
  final String userId;
  final String papel;

  Map<String, dynamic> toJson() => {
        'id': id,
        'localId': localId,
        'userId': userId,
        'papel': papel,
      };
}
