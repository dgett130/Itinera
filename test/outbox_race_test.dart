import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itinera/data/database.dart';
import 'package:itinera/data/sync/sync_engine.dart';

/// Una scrittura arrivata mentre la precedente era in volo non va persa.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    await db.customSelect('SELECT 1').get();
    await db.customStatement('DELETE FROM _outbox');
  });

  tearDown(() => db.close());

  Future<List<String>> ops() async {
    final rows = await db
        .customSelect("SELECT op FROM _outbox WHERE row_id = 'r1'")
        .get();
    return [for (final r in rows) r.read<String>('op')];
  }

  Future<void> enqueue(String op, int at) => db.customStatement(
    "INSERT INTO _outbox(tbl,row_id,op,at) VALUES('trips','r1',?,?) "
    'ON CONFLICT(tbl,row_id) DO UPDATE SET op=excluded.op, at=excluded.at',
    [op, at],
  );

  test('la voce spinta e invariata esce dalla coda', () async {
    await enqueue('delete', 100);
    await dropPushedOutboxEntry(db, 'trips', 'r1', 'delete', 100);
    expect(await ops(), isEmpty);
  });

  test('Annulla durante il push della delete resta in coda', () async {
    await enqueue('delete', 100);
    await enqueue('upsert', 100);
    await dropPushedOutboxEntry(db, 'trips', 'r1', 'delete', 100);
    expect(await ops(), ['upsert']);
  });

  test('una modifica successiva durante il push resta in coda', () async {
    await enqueue('upsert', 100);
    await enqueue('upsert', 101);
    await dropPushedOutboxEntry(db, 'trips', 'r1', 'upsert', 100);
    expect(await ops(), ['upsert']);
  });
}
