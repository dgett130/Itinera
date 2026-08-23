import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itinera/data/backup_service.dart';
import 'package:itinera/data/database.dart';
import 'package:itinera/data/sample_data.dart';
import 'package:itinera/data/seed.dart';

void main() {
  test('export e reimport ricreano gli stessi dati (round-trip)', () async {
    final source = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(source);
    await SampleData.createIfEmpty(source);

    final trips1 = (await source.select(source.trips).get()).length;
    final items1 = (await source.select(source.packingItems).get()).length;
    final acts1 = (await source.select(source.activities).get()).length;
    final segs1 = (await source.select(source.transportSegments).get()).length;
    expect(trips1, 1);
    expect(items1, greaterThan(0));
    expect(acts1, greaterThan(0));

    final json = await BackupService(source).exportJson();
    await source.close();

    // Nuovo DB vuoto: l'import deve ricostruire tutto.
    final target = AppDatabase.forExecutor(NativeDatabase.memory());
    await BackupService(target).importJson(json);

    expect((await target.select(target.trips).get()).length, trips1);
    expect((await target.select(target.packingItems).get()).length, items1);
    expect((await target.select(target.activities).get()).length, acts1);
    expect((await target.select(target.transportSegments).get()).length, segs1);
    expect((await target.select(target.packingCategories).get()).length, 8);

    // Un secondo import non deve duplicare (sostituzione completa).
    await BackupService(target).importJson(json);
    expect((await target.select(target.trips).get()).length, trips1);

    await target.close();
  });

  test('un JSON non Itinera viene rifiutato', () async {
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(db);
    await expectLater(
      BackupService(db).importJson('{"app":"altro"}'),
      throwsA(isA<FormatException>()),
    );
    await db.close();
  });
}
