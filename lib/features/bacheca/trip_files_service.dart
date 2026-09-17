import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Nome del bucket Storage della bacheca (vedi `docs/supabase/bacheca.sql`).
const String kTripFilesBucket = 'trip-files';

/// Caricamento/scaricamento/eliminazione dei byte dei file su Supabase Storage.
///
/// Convenzione dei percorsi: `<tripId>/<fileId>`. Le RLS di `storage.objects`
/// concedono ai membri del viaggio (prima cartella = tripId) lettura, scrittura
/// ed eliminazione. Online: senza client (modalita' locale) i metodi lanciano.
class TripFilesService {
  TripFilesService(this._client);

  final SupabaseClient? _client;

  bool get isReady => _client != null;

  SupabaseClient get _c {
    final c = _client;
    if (c == null) {
      throw const AuthException('Serve un account per usare la bacheca.');
    }
    return c;
  }

  /// Id dell'utente corrente (per `uploaded_by`), o null in modalita' locale.
  String? get currentUserId => _client?.auth.currentUser?.id;

  String buildPath(String tripId, String fileId) => '$tripId/$fileId';

  /// Carica i byte e ritorna il percorso nel bucket.
  Future<String> upload({
    required String tripId,
    required String fileId,
    required Uint8List bytes,
    String? contentType,
  }) async {
    final path = buildPath(tripId, fileId);
    await _c.storage
        .from(kTripFilesBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: true,
          ),
        );
    return path;
  }

  /// URL firmato temporaneo per aprire/scaricare il file (default 1 ora).
  Future<String> signedUrl(String storagePath, {int expiresIn = 3600}) {
    return _c.storage.from(kTripFilesBucket).createSignedUrl(
      storagePath,
      expiresIn,
    );
  }

  /// Rimuove il file dallo Storage (best-effort: gli errori non bloccano
  /// l'eliminazione del metadato locale).
  Future<void> remove(String storagePath) async {
    await _c.storage.from(kTripFilesBucket).remove([storagePath]);
  }
}

/// Deduce il MIME type dall'estensione del file (per un'apertura corretta).
String? mimeFromExtension(String? ext) {
  if (ext == null || ext.isEmpty) return null;
  switch (ext.toLowerCase()) {
    case 'pdf':
      return 'application/pdf';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'gif':
      return 'image/gif';
    case 'webp':
      return 'image/webp';
    case 'heic':
      return 'image/heic';
    case 'txt':
      return 'text/plain';
    case 'csv':
      return 'text/csv';
    case 'doc':
      return 'application/msword';
    case 'docx':
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    case 'xls':
      return 'application/vnd.ms-excel';
    case 'xlsx':
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    case 'ppt':
      return 'application/vnd.ms-powerpoint';
    case 'pptx':
      return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    case 'zip':
      return 'application/zip';
    default:
      return null;
  }
}
