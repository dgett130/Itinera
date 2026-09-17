import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../auth/auth_service.dart';

/// Cartella Drive creata dall'app.
class DriveFolder {
  const DriveFolder({required this.id, required this.webViewLink});
  final String id;
  final String webViewLink;
}

/// Errore leggibile durante l'uso di Drive (mostrato all'utente).
class DriveException implements Exception {
  const DriveException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Crea una cartella su Google Drive dall'app e la rende condivisibile via link.
///
/// Usa lo scope `drive.file` (accesso ai soli file creati dall'app), ottenuto
/// tramite `google_sign_in` v7 (`authorizeScopes`). Richiede su Google Cloud:
/// API Drive abilitata e lo scope `drive.file` aggiunto alla schermata di
/// consenso OAuth (vedi `docs/google-drive-setup.md`).
class GoogleDriveService {
  static const String driveFileScope =
      'https://www.googleapis.com/auth/drive.file';

  static const String _filesEndpoint =
      'https://www.googleapis.com/drive/v3/files';

  /// Crea una cartella [name] e la imposta come "chiunque abbia il link puo'
  /// visualizzare". Ritorna id + link condivisibile.
  Future<DriveFolder> createSharedFolder(String name) async {
    final token = await _accessToken();

    final createRes = await http.post(
      Uri.parse('$_filesEndpoint?fields=id,webViewLink'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'name': name,
        'mimeType': 'application/vnd.google-apps.folder',
      }),
    );
    if (createRes.statusCode < 200 || createRes.statusCode >= 300) {
      throw DriveException(
        'Creazione della cartella non riuscita (${createRes.statusCode}).',
      );
    }
    final body = jsonDecode(createRes.body) as Map<String, dynamic>;
    final id = body['id'] as String;
    final link = (body['webViewLink'] as String?) ??
        'https://drive.google.com/drive/folders/$id';

    // Chiunque abbia il link puo' vedere le foto (condivisione col gruppo).
    // Non bloccante: se fallisce, la cartella resta comunque creata.
    try {
      await http.post(
        Uri.parse('$_filesEndpoint/$id/permissions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'role': 'reader', 'type': 'anyone'}),
      );
    } catch (_) {}

    return DriveFolder(id: id, webViewLink: link);
  }

  /// Ottiene un access token con lo scope Drive, chiedendo il consenso se serve.
  Future<String> _accessToken() async {
    await AuthService.ensureGoogleInitialized();
    final gsi = GoogleSignIn.instance;

    // Prova a riusare la sessione Google esistente; altrimenti chiede l'accesso.
    final attempt = gsi.attemptLightweightAuthentication();
    var account = attempt == null ? null : await attempt;
    account ??= await gsi.authenticate(scopeHint: const [driveFileScope]);

    final authz = await account.authorizationClient.authorizeScopes(
      const [driveFileScope],
    );
    return authz.accessToken;
  }
}
