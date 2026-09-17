import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_config.dart';
import '../../providers.dart';
import '../auth/auth_providers.dart';
import '../trip/trip_providers.dart';
import 'deadline_reminders.dart';
import 'notifications_repository.dart';
import 'push_service.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  ref.watch(currentUserProvider); // si ricostruisce al cambio utente
  return NotificationsRepository(
    supabaseReady ? Supabase.instance.client : null,
  );
});

/// Inbox notifiche in tempo reale.
final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  return ref.watch(notificationsRepositoryProvider).watch();
});

/// Numero di notifiche non lette (per il badge sul campanellino).
final unreadCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationsProvider).value ?? const [];
  return list.where((n) => !n.isRead).length;
});

/// Preferenze di notifica dell'utente.
final notificationPrefsProvider = FutureProvider<NotificationPrefs>((ref) {
  ref.watch(currentUserProvider);
  return ref.watch(notificationsRepositoryProvider).prefs();
});

/// True se l'utente corrente e' admin (puo' inviare messaggi di sistema).
final isAdminProvider = FutureProvider<bool>((ref) {
  ref.watch(currentUserProvider);
  return ref.watch(notificationsRepositoryProvider).isAdmin();
});

/// Avvia il push quando c'e' un utente loggato e Firebase e' pronto:
/// init FCM + permesso + registrazione del token su Supabase. Da "osservare"
/// in alto nell'albero (RootGate), come il motore di sync.
final pushControllerProvider = Provider<void>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null || !supabaseReady || !firebaseReady) return;
  final repo = ref.watch(notificationsRepositoryProvider);
  final platform = defaultTargetPlatform.name;

  Future.microtask(() async {
    try {
      await PushService.instance.init();
      final granted = await PushService.instance.requestPermission();
      if (!granted) return;
      final token = await PushService.instance.token();
      if (token != null) await repo.upsertToken(token, platform);
    } catch (e) {
      debugPrint('[push] init fallita: $e');
    }
  });

  // Aggiorna il token quando Firebase lo rinnova.
  final sub = PushService.instance.tokenRefresh.listen(
    (t) => repo.upsertToken(t, platform),
  );
  ref.onDispose(sub.cancel);
});

final deadlineRemindersProvider = Provider<DeadlineReminders>((ref) {
  return DeadlineReminders(ref.watch(databaseProvider));
});

/// Riprogramma le notifiche di scadenza quando cambiano i viaggi. Da osservare
/// in alto nell'albero (RootGate).
final deadlineSyncProvider = Provider<void>((ref) {
  final trips = ref.watch(tripsProvider).value;
  if (trips == null) return;
  final reminders = ref.watch(deadlineRemindersProvider);
  Future.microtask(() => reminders.sync(trips));
});
