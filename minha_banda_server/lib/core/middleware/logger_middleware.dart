import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';

final _log = Logger('HTTP');

Middleware loggerMiddleware() {
  return (Handler inner) {
    return (Request request) async {
      final sw = Stopwatch()..start();
      final response = await inner(request);
      sw.stop();
      _log.info(
        '${request.method} ${request.requestedUri.path} '
        '→ ${response.statusCode} (${sw.elapsedMilliseconds}ms)',
      );
      return response;
    };
  };
}
