import 'package:drift/drift.dart';

import '../../data/database.dart';

/// Accesso ai METADATI dei file della bacheca (tabella `trip_files`, sincronizzata).
///
/// I byte veri stanno su Supabase Storage: qui vivono solo nome, percorso nel
/// bucket, tipo e dimensione. Cosi' l'elenco resta consultabile offline anche
/// se il download del file richiede la rete.
class TripFilesRepository {
  TripFilesRepository(this._db);

  final AppDatabase _db;

  /// File del viaggio, dal piu' recente al piu' vecchio.
  Stream<List<TripFile>> watchFiles(String tripId) =>
      (_db.select(_db.tripFiles)
            ..where((f) => f.tripId.equals(tripId))
            ..orderBy([
              (f) => OrderingTerm(
                expression: f.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch();

  Future<TripFile?> getFile(String id) => (_db.select(
    _db.tripFiles,
  )..where((f) => f.id.equals(id))).getSingleOrNull();

  /// Registra i metadati di un file gia' caricato su Storage.
  Future<void> addFile({
    required String id,
    required String tripId,
    required String name,
    required String storagePath,
    String? mimeType,
    int? sizeBytes,
    String? uploadedBy,
  }) async {
    await _db
        .into(_db.tripFiles)
        .insert(
          TripFilesCompanion.insert(
            id: id,
            tripId: tripId,
            name: name,
            storagePath: storagePath,
            mimeType: Value(mimeType),
            sizeBytes: Value(sizeBytes),
            uploadedBy: Value(uploadedBy),
          ),
        );
  }

  Future<void> deleteFile(String id) async {
    await (_db.delete(_db.tripFiles)..where((f) => f.id.equals(id))).go();
  }
}
