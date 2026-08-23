import 'dart:convert';

import 'package:http/http.dart' as http;

/// Errore parlante del livello di rete/sincronizzazione.
class RemoteException implements Exception {
  RemoteException(this.message, {this.unauthorized = false});
  final String message;
  final bool unauthorized;

  @override
  String toString() => message;
}

/// Client HTTP verso il backend Itinera (versione remota).
///
/// Nessuna logica di dominio: solo login e get/put del documento JSON.
class RemoteApi {
  RemoteApi(String baseUrl) : _base = _normalize(baseUrl);

  final String _base;
  final _client = http.Client();

  static String _normalize(String url) {
    var u = url.trim();
    if (u.endsWith('/')) u = u.substring(0, u.length - 1);
    if (!u.startsWith('http://') && !u.startsWith('https://')) {
      u = 'http://$u';
    }
    return u;
  }

  Uri _uri(String path) => Uri.parse('$_base$path');

  Future<bool> health() async {
    try {
      final res = await _client
          .get(_uri('/api/health'))
          .timeout(const Duration(seconds: 8));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Ritorna il token di sessione.
  Future<String> login(String username, String password) async {
    final http.Response res;
    try {
      res = await _client
          .post(
            _uri('/api/login'),
            headers: {'content-type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 12));
    } catch (e) {
      throw RemoteException('Impossibile raggiungere il server: $e');
    }
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body['token'] as String;
    }
    if (res.statusCode == 401) {
      throw RemoteException('Credenziali non valide', unauthorized: true);
    }
    throw RemoteException('Errore di login (HTTP ${res.statusCode})');
  }

  /// Ritorna il documento JSON, o null se il server non ne ha ancora uno.
  Future<String?> getData(String token) async {
    final http.Response res;
    try {
      res = await _client
          .get(_uri('/api/data'), headers: {'authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 20));
    } catch (e) {
      throw RemoteException('Errore di rete: $e');
    }
    if (res.statusCode == 204) return null;
    if (res.statusCode == 200) return res.body;
    if (res.statusCode == 401) {
      throw RemoteException('Sessione scaduta', unauthorized: true);
    }
    throw RemoteException('Errore nel download (HTTP ${res.statusCode})');
  }

  Future<void> putData(String token, String documentJson) async {
    final http.Response res;
    try {
      res = await _client
          .put(
            _uri('/api/data'),
            headers: {
              'authorization': 'Bearer $token',
              'content-type': 'application/json',
            },
            body: documentJson,
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw RemoteException('Errore di rete: $e');
    }
    if (res.statusCode == 200) return;
    if (res.statusCode == 401) {
      throw RemoteException('Sessione scaduta', unauthorized: true);
    }
    throw RemoteException('Errore nel caricamento (HTTP ${res.statusCode})');
  }

  void dispose() => _client.close();
}
