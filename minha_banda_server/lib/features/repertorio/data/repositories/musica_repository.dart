import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/musica.dart';
import '../../domain/entities/setlist_item.dart';

abstract interface class MusicaRepository {
  Future<List<Musica>> listByBanda(String bandaId);
  Future<Musica?> findById(String id);
  Future<Musica> create({
    required String bandaId,
    required String titulo,
    required String criadoPor,
    String? artistaOriginal,
    String? tonalidade,
    int? bpm,
    int? duracaoSeg,
    List<String> tags,
    String? letra,
    String? cifra,
    String? linkReferencia,
    String? notasArranjo,
    String status,
  });
  Future<Musica> update({
    required String id,
    String? titulo,
    String? artistaOriginal,
    String? tonalidade,
    int? bpm,
    int? duracaoSeg,
    List<String>? tags,
    String? letra,
    String? cifra,
    String? linkReferencia,
    String? notasArranjo,
    String? status,
  });
  Future<void> delete(String id);
  Future<List<SetlistItem>> getSetlist(String eventoId);
  Future<void> setSetlist({
    required String eventoId,
    required List<String> musicaIds,
  });
}

class PostgresMusicaRepository implements MusicaRepository {
  const PostgresMusicaRepository(this._conn);
  final Connection _conn;

  @override
  Future<List<Musica>> listByBanda(String bandaId) async {
    final rows = await _conn.execute(
      Sql.named(
        'SELECT id, banda_id, titulo, artista_original, tonalidade, bpm, '
        'duracao_seg, tags, letra, cifra, link_referencia, notas_arranjo, '
        'status, criado_por, criado_em, atualizado_em '
        'FROM musicas WHERE banda_id = @bandaId ORDER BY titulo',
      ),
      parameters: {'bandaId': bandaId},
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<Musica?> findById(String id) async {
    final rows = await _conn.execute(
      Sql.named(
        'SELECT id, banda_id, titulo, artista_original, tonalidade, bpm, '
        'duracao_seg, tags, letra, cifra, link_referencia, notas_arranjo, '
        'status, criado_por, criado_em, atualizado_em '
        'FROM musicas WHERE id = @id LIMIT 1',
      ),
      parameters: {'id': id},
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<Musica> create({
    required String bandaId,
    required String titulo,
    required String criadoPor,
    String? artistaOriginal,
    String? tonalidade,
    int? bpm,
    int? duracaoSeg,
    List<String> tags = const [],
    String? letra,
    String? cifra,
    String? linkReferencia,
    String? notasArranjo,
    String status = 'em_aprendizado',
  }) async {
    final id = const Uuid().v4();
    final rows = await _conn.execute(
      Sql.named(
        'INSERT INTO musicas (id, banda_id, titulo, artista_original, tonalidade, '
        'bpm, duracao_seg, tags, letra, cifra, link_referencia, notas_arranjo, '
        'status, criado_por) '
        'VALUES (@id, @bandaId, @titulo, @artistaOriginal, @tonalidade, '
        '@bpm, @duracaoSeg, @tags, @letra, @cifra, @linkReferencia, @notasArranjo, '
        '@status, @criadoPor) '
        'RETURNING id, banda_id, titulo, artista_original, tonalidade, bpm, '
        'duracao_seg, tags, letra, cifra, link_referencia, notas_arranjo, '
        'status, criado_por, criado_em, atualizado_em',
      ),
      parameters: {
        'id': id,
        'bandaId': bandaId,
        'titulo': titulo.trim(),
        'artistaOriginal': artistaOriginal,
        'tonalidade': tonalidade,
        'bpm': bpm,
        'duracaoSeg': duracaoSeg,
        'tags': TypedValue(Type.textArray, tags),
        'letra': letra,
        'cifra': cifra,
        'linkReferencia': linkReferencia,
        'notasArranjo': notasArranjo,
        'status': status,
        'criadoPor': criadoPor,
      },
    );
    return _fromRow(rows.first);
  }

  @override
  Future<Musica> update({
    required String id,
    String? titulo,
    String? artistaOriginal,
    String? tonalidade,
    int? bpm,
    int? duracaoSeg,
    List<String>? tags,
    String? letra,
    String? cifra,
    String? linkReferencia,
    String? notasArranjo,
    String? status,
  }) async {
    final setParts = <String>['atualizado_em = now()'];
    final params = <String, dynamic>{'id': id};

    if (titulo != null) {
      setParts.add('titulo = @titulo');
      params['titulo'] = titulo.trim();
    }
    if (artistaOriginal != null) {
      setParts.add('artista_original = @artistaOriginal');
      params['artistaOriginal'] = artistaOriginal;
    }
    if (tonalidade != null) {
      setParts.add('tonalidade = @tonalidade');
      params['tonalidade'] = tonalidade;
    }
    if (bpm != null) {
      setParts.add('bpm = @bpm');
      params['bpm'] = bpm;
    }
    if (duracaoSeg != null) {
      setParts.add('duracao_seg = @duracaoSeg');
      params['duracaoSeg'] = duracaoSeg;
    }
    if (tags != null) {
      setParts.add('tags = @tags');
      params['tags'] = TypedValue(Type.textArray, tags);
    }
    if (letra != null) {
      setParts.add('letra = @letra');
      params['letra'] = letra;
    }
    if (cifra != null) {
      setParts.add('cifra = @cifra');
      params['cifra'] = cifra;
    }
    if (linkReferencia != null) {
      setParts.add('link_referencia = @linkReferencia');
      params['linkReferencia'] = linkReferencia;
    }
    if (notasArranjo != null) {
      setParts.add('notas_arranjo = @notasArranjo');
      params['notasArranjo'] = notasArranjo;
    }
    if (status != null) {
      setParts.add('status = @status');
      params['status'] = status;
    }

    final rows = await _conn.execute(
      Sql.named(
        'UPDATE musicas SET ${setParts.join(', ')} WHERE id = @id '
        'RETURNING id, banda_id, titulo, artista_original, tonalidade, bpm, '
        'duracao_seg, tags, letra, cifra, link_referencia, notas_arranjo, '
        'status, criado_por, criado_em, atualizado_em',
      ),
      parameters: params,
    );
    return _fromRow(rows.first);
  }

  @override
  Future<void> delete(String id) async {
    await _conn.execute(
      Sql.named('DELETE FROM musicas WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  @override
  Future<List<SetlistItem>> getSetlist(String eventoId) async {
    final rows = await _conn.execute(
      Sql.named(
        'SELECT id, evento_id, musica_id, posicao '
        'FROM setlist_itens WHERE evento_id = @eventoId ORDER BY posicao',
      ),
      parameters: {'eventoId': eventoId},
    );
    return rows.map(_itemFromRow).toList();
  }

  @override
  Future<void> setSetlist({
    required String eventoId,
    required List<String> musicaIds,
  }) async {
    await _conn.execute(
      Sql.named('DELETE FROM setlist_itens WHERE evento_id = @eventoId'),
      parameters: {'eventoId': eventoId},
    );
    for (var i = 0; i < musicaIds.length; i++) {
      await _conn.execute(
        Sql.named(
          'INSERT INTO setlist_itens (id, evento_id, musica_id, posicao) '
          'VALUES (@id, @eventoId, @musicaId, @posicao)',
        ),
        parameters: {
          'id': const Uuid().v4(),
          'eventoId': eventoId,
          'musicaId': musicaIds[i],
          'posicao': i,
        },
      );
    }
  }

  Musica _fromRow(ResultRow row) {
    final c = row.toColumnMap();
    return Musica(
      id: c['id'] as String,
      bandaId: c['banda_id'] as String,
      titulo: c['titulo'] as String,
      artistaOriginal: c['artista_original'] as String?,
      tonalidade: c['tonalidade'] as String?,
      bpm: c['bpm'] as int?,
      duracaoSeg: c['duracao_seg'] as int?,
      tags: (c['tags'] as List).cast<String>(),
      letra: c['letra'] as String?,
      cifra: c['cifra'] as String?,
      linkReferencia: c['link_referencia'] as String?,
      notasArranjo: c['notas_arranjo'] as String?,
      status: c['status'] as String,
      criadoPor: c['criado_por'] as String,
      criadoEm: c['criado_em'] as DateTime,
      atualizadoEm: c['atualizado_em'] as DateTime,
    );
  }

  SetlistItem _itemFromRow(ResultRow row) {
    final c = row.toColumnMap();
    return SetlistItem(
      id: c['id'] as String,
      eventoId: c['evento_id'] as String,
      musicaId: c['musica_id'] as String,
      posicao: c['posicao'] as int,
    );
  }
}
