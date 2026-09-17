import '../../data/database.dart';
import 'push_service.dart';

/// Programma notifiche locali per le scadenze dei viaggi: promemoria valigia
/// (3 giorni prima) e partenza imminente (il giorno prima). Sono locali, quindi
/// funzionano anche offline e non passano dal server FCM.
class DeadlineReminders {
  DeadlineReminders(this._db);

  final AppDatabase _db;

  /// Preferenza locale (non sincronizzata): scadenze attive per default.
  static const String _prefKey = 'deadline_reminders_enabled';

  Future<bool> isEnabled() async => (await _db.getPref(_prefKey)) != '0';

  Future<void> setEnabled(bool value, List<Trip> trips) async {
    await _db.setPref(_prefKey, value ? '1' : '0');
    await sync(trips);
  }

  /// Ricalcola tutte le notifiche di scadenza in base ai viaggi correnti.
  /// Da richiamare quando cambiano i viaggi o la preferenza.
  Future<void> sync(List<Trip> trips) async {
    await PushService.instance.cancelReminders();
    if (!await isEnabled()) return;

    final now = DateTime.now();
    var id = PushService.reminderBase;
    final maxId = PushService.reminderBase + PushService.reminderSpan;

    for (final t in trips) {
      final start = t.startDate;
      if (start == null) continue;

      // 3 giorni prima, alle 18:00 -> promemoria valigia/backup.
      final threeDays = DateTime(start.year, start.month, start.day - 3, 18);
      if (threeDays.isAfter(now) && id < maxId) {
        await PushService.instance.schedule(
          id: id++,
          when: threeDays,
          title: 'Tra 3 giorni si parte',
          body: '${t.name}: controlla la valigia e fai un backup',
          route: '/trip/${t.id}/packing',
        );
      }

      // Il giorno prima, alle 9:00 -> partenza imminente.
      final dayBefore = DateTime(start.year, start.month, start.day - 1, 9);
      if (dayBefore.isAfter(now) && id < maxId) {
        await PushService.instance.schedule(
          id: id++,
          when: dayBefore,
          title: 'Domani si parte ✈️',
          body: '${t.name}: ultimi preparativi prima della partenza',
          route: '/trip/${t.id}',
        );
      }
    }
  }
}
