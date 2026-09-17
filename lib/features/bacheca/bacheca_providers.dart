import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/id.dart';
import '../../core/supabase_config.dart';
import '../../data/database.dart';
import '../../providers.dart';
import 'trip_files_repository.dart';
import 'trip_files_service.dart';

final tripFilesRepositoryProvider = Provider<TripFilesRepository>((ref) {
  return TripFilesRepository(ref.watch(databaseProvider));
});

final tripFilesServiceProvider = Provider<TripFilesService>((ref) {
  return TripFilesService(supabaseReady ? Supabase.instance.client : null);
});

/// File della bacheca del viaggio (metadati locali, sincronizzati).
final tripFilesProvider = StreamProvider.family<List<TripFile>, String>((
  ref,
  tripId,
) {
  return ref.watch(tripFilesRepositoryProvider).watchFiles(tripId);
});

final bachecaControllerProvider = Provider<BachecaController>((ref) {
  return BachecaController(
    repo: ref.watch(tripFilesRepositoryProvider),
    service: ref.watch(tripFilesServiceProvider),
  );
});

/// Esito di un tentativo di caricamento file.
enum UploadOutcome { added, cancelled, noAccount, tooBig }

class UploadResult {
  const UploadResult(this.outcome, {this.fileName});
  final UploadOutcome outcome;
  final String? fileName;
}

/// Orchestra bacheca: scelta file + Storage + metadati.
class BachecaController {
  BachecaController({required this.repo, required this.service});

  final TripFilesRepository repo;
  final TripFilesService service;

  /// Limite prudenziale per singolo file (25 MB): la bacheca serve per
  /// documenti (biglietti, programmi), non per archivi pesanti.
  static const int maxSizeBytes = 25 * 1024 * 1024;

  bool get isReady => service.isReady;

  /// Apre il selettore, carica il file su Storage e registra i metadati.
  Future<UploadResult> pickAndUpload(String tripId) async {
    if (!service.isReady) return const UploadResult(UploadOutcome.noAccount);

    final f = await FilePicker.pickFile();
    if (f == null) return const UploadResult(UploadOutcome.cancelled);
    final bytes = await f.readAsBytes();
    if (bytes.isEmpty) return const UploadResult(UploadOutcome.cancelled);
    if (bytes.length > maxSizeBytes) {
      return UploadResult(UploadOutcome.tooBig, fileName: f.name);
    }

    final id = newId();
    final mime = mimeFromExtension(f.extension);
    final path = await service.upload(
      tripId: tripId,
      fileId: id,
      bytes: bytes,
      contentType: mime,
    );
    await repo.addFile(
      id: id,
      tripId: tripId,
      name: f.name,
      storagePath: path,
      mimeType: mime,
      sizeBytes: bytes.length,
      uploadedBy: service.currentUserId,
    );
    return UploadResult(UploadOutcome.added, fileName: f.name);
  }

  /// URL firmato per aprire il file.
  Future<String> signedUrl(TripFile file) => service.signedUrl(file.storagePath);

  /// Elimina metadato + byte (lo Storage e' best-effort).
  Future<void> delete(TripFile file) async {
    await repo.deleteFile(file.id);
    try {
      if (service.isReady) await service.remove(file.storagePath);
    } catch (e) {
      // Il metadato e' gia' rimosso (soft-delete sincronizzato); un eventuale
      // oggetto orfano su Storage non e' bloccante.
      debugPrint('[bacheca] storage remove fallita: $e');
    }
  }
}
