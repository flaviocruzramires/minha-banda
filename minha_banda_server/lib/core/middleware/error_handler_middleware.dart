import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import '../exceptions/app_exception.dart';
import '../helpers/response_helper.dart';

final _log = Logger('ErrorHandler');

Middleware errorHandlerMiddleware() {
  return (Handler inner) {
    return (Request request) async {
      try {
        return await inner(request);
      } on AppException catch (e) {
        return ResponseHelper.error(e.statusCode, e.message);
      } catch (e, st) {
        _log.severe('Unhandled error', e, st);
        return ResponseHelper.error(500, 'Erro interno do servidor.');
      }
    };
  };
}
