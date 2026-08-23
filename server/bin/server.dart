import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

/// Backend di sincronizzazione di Itinera.
///
/// Semplice e single-tenant per uso homelab: login username/password ->
/// token HMAC, e un "document store" che conserva l'intero dataset dell'app
/// come JSON (lo stesso formato del backup locale). L'app resta local-first:
/// il server e' solo il punto di sincronizzazione tra dispositivi.
///
/// Sicurezza: pensato per girare DENTRO la rete Tailscale (traffico gia'
/// cifrato WireGuard), quindi HTTP semplice e' accettabile. Cambiare le
/// credenziali e il secret via variabili d'ambiente in produzione.

final _config = _Config.fromEnv();

void main(List<String> args) async {
  final dataDir = Directory(_config.dataDir);
  if (!dataDir.existsSync()) {
    dataDir.createSync(recursive: true);
  }

  final router = Router()
    ..get('/api/health', _health)
    ..post('/api/login', _login)
    ..get('/api/data', _requireAuth(_getData))
    ..put('/api/data', _requireAuth(_putData));

  final handler = const Pipeline()
      .addMiddleware(_corsMiddleware())
      .addMiddleware(logRequests())
      .addHandler(router.call);

  final server = await io.serve(handler, InternetAddress.anyIPv4, _config.port);
  stdout.writeln(
    'Itinera server in ascolto su http://${server.address.host}:${server.port} '
    '(utente: ${_config.username}, dati: ${_config.dataDir})',
  );
}

Response _health(Request request) {
  return _json({'status': 'ok', 'app': 'itinera-server'});
}

Future<Response> _login(Request request) async {
  Map<String, dynamic> body;
  try {
    body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
  } catch (_) {
    return _json({'error': 'body non valido'}, status: 400);
  }
  final username = (body['username'] as String?)?.trim() ?? '';
  final password = (body['password'] as String?) ?? '';

  if (username != _config.username || password != _config.password) {
    return _json({'error': 'credenziali non valide'}, status: 401);
  }
  final expiry = DateTime.now()
      .add(Duration(days: _config.tokenTtlDays))
      .millisecondsSinceEpoch;
  final token = _makeToken(username, expiry);
  return _json({'token': token, 'expiresAt': expiry, 'username': username});
}

Future<Response> _getData(Request request, String username) async {
  final file = _dataFile(username);
  if (file == null || !file.existsSync()) {
    return Response(204); // nessun documento ancora
  }
  return Response.ok(
    await file.readAsString(),
    headers: {'content-type': 'application/json'},
  );
}

Future<Response> _putData(Request request, String username) async {
  final raw = await request.readAsString();
  try {
    jsonDecode(raw); // valida che sia JSON
  } catch (_) {
    return _json({'error': 'il corpo deve essere JSON valido'}, status: 400);
  }
  final file = _dataFile(username);
  if (file == null) {
    return _json({'error': 'utente non valido'}, status: 400);
  }
  await file.writeAsString(raw, flush: true);
  return _json({'status': 'ok', 'bytes': raw.length});
}

// --- Auth ------------------------------------------------------------------

/// Avvolge un handler richiedendo un Bearer token valido; passa lo username.
Handler _requireAuth(
  Future<Response> Function(Request, String username) handler,
) {
  return (Request request) async {
    final auth = request.headers['authorization'] ?? '';
    if (!auth.startsWith('Bearer ')) {
      return _json({'error': 'token mancante'}, status: 401);
    }
    final username = _verifyToken(auth.substring(7));
    if (username == null) {
      return _json({'error': 'token non valido o scaduto'}, status: 401);
    }
    return handler(request, username);
  };
}

String _makeToken(String username, int expiryMs) {
  final payload = '$username.$expiryMs';
  final sig = Hmac(sha256, utf8.encode(_config.secret))
      .convert(utf8.encode(payload))
      .toString();
  return base64Url.encode(utf8.encode('$payload.$sig'));
}

/// Ritorna lo username se il token e' valido e non scaduto, altrimenti null.
String? _verifyToken(String token) {
  String decoded;
  try {
    decoded = utf8.decode(base64Url.decode(token));
  } catch (_) {
    return null;
  }
  final parts = decoded.split('.');
  if (parts.length != 3) return null;
  final username = parts[0];
  final expiryMs = int.tryParse(parts[1]);
  final sig = parts[2];
  if (expiryMs == null) return null;

  final expected = Hmac(sha256, utf8.encode(_config.secret))
      .convert(utf8.encode('$username.$expiryMs'))
      .toString();
  if (!_constantTimeEquals(sig, expected)) return null;
  if (DateTime.now().millisecondsSinceEpoch > expiryMs) return null;
  return username;
}

bool _constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var result = 0;
  for (var i = 0; i < a.length; i++) {
    result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return result == 0;
}

// --- Storage ---------------------------------------------------------------

File? _dataFile(String username) {
  if (!RegExp(r'^[A-Za-z0-9_-]{1,64}$').hasMatch(username)) return null;
  return File('${_config.dataDir}/$username.json');
}

// --- Helpers ---------------------------------------------------------------

Response _json(Object data, {int status = 200}) {
  return Response(
    status,
    body: jsonEncode(data),
    headers: {'content-type': 'application/json'},
  );
}

Middleware _corsMiddleware() {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
  };
  return (Handler inner) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: headers);
      }
      final response = await inner(request);
      return response.change(headers: headers);
    };
  };
}

class _Config {
  _Config({
    required this.port,
    required this.username,
    required this.password,
    required this.secret,
    required this.dataDir,
    required this.tokenTtlDays,
  });

  final int port;
  final String username;
  final String password;
  final String secret;
  final String dataDir;
  final int tokenTtlDays;

  factory _Config.fromEnv() {
    final env = Platform.environment;
    return _Config(
      port: int.tryParse(env['PORT'] ?? '') ?? 8080,
      username: env['ITINERA_USERNAME'] ?? 'dgett130',
      password: env['ITINERA_PASSWORD'] ?? 'password',
      secret: env['ITINERA_SECRET'] ?? 'itinera-dev-secret-change-me',
      dataDir: env['ITINERA_DATA_DIR'] ?? '/data',
      tokenTtlDays: int.tryParse(env['ITINERA_TOKEN_TTL_DAYS'] ?? '') ?? 7,
    );
  }
}
