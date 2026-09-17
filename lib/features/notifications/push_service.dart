import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../router.dart';

/// Handler dei messaggi FCM ricevuti con app in background/terminata.
///
/// Deve essere una funzione top-level annotata: gira in un isolate separato.
/// Con payload `notification` il sistema mostra gia' l'avviso nella barra e la
/// riga in inbox e' gia' creata dal trigger su Supabase: qui non serve altro.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

/// Collega FCM alle notifiche locali di sistema (visualizzazione in foreground,
/// canale Android, tap -> navigazione) e gestisce permesso e token.
class PushService {
  PushService._();
  static final PushService instance = PushService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  bool _inited = false;
  bool _tzReady = false;

  /// Canale Android di default (deve combaciare con il meta-data nel manifest).
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'itinera_default',
    'Notifiche Itinera',
    description: 'Avvisi su amici, viaggi e documenti condivisi',
    importance: Importance.high,
  );

  /// Inizializza il canale locale e i listener FCM. Idempotente.
  Future<void> init() async {
    if (_inited) return;
    _inited = true;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _local.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
      onDidReceiveNotificationResponse: (resp) {
        final payload = resp.payload;
        if (payload != null && payload.isNotEmpty) _openRoute(payload);
      },
    );
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // Foreground: FCM non mostra nulla da solo -> mostro una notifica locale.
    FirebaseMessaging.onMessage.listen(_showForeground);
    // Tap sulla notifica con app in background -> naviga alla rotta indicata.
    FirebaseMessaging.onMessageOpenedApp.listen((m) {
      final route = m.data['route'] as String?;
      if (route != null && route.isNotEmpty) _openRoute(route);
    });
    // App aperta da terminata tramite una notifica.
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    final route = initial?.data['route'] as String?;
    if (route != null && route.isNotEmpty) _openRoute(route);
  }

  /// Chiede il permesso di notifica (Android 13+ / iOS). True se concesso.
  Future<bool> requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission();
    final s = settings.authorizationStatus;
    return s == AuthorizationStatus.authorized ||
        s == AuthorizationStatus.provisional;
  }

  Future<String?> token() => FirebaseMessaging.instance.getToken();

  Stream<String> get tokenRefresh => FirebaseMessaging.instance.onTokenRefresh;

  // --- Notifiche locali programmate (scadenze) ------------------------------

  /// Inizializza il database dei fusi orari e imposta quello locale. Idempotente.
  Future<void> _ensureTimezone() async {
    if (_tzReady) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Fallback: UTC (le scadenze restano funzionanti, con offset generico).
    }
    _tzReady = true;
  }

  NotificationDetails get _details => NotificationDetails(
    android: AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    ),
    iOS: const DarwinNotificationDetails(),
  );

  /// Programma una notifica locale a [when] (ignora se e' nel passato).
  Future<void> schedule({
    required int id,
    required DateTime when,
    required String title,
    String? body,
    String? route,
  }) async {
    await init();
    await _ensureTimezone();
    if (!when.isAfter(DateTime.now())) return;
    await _local.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: route,
    );
  }

  Future<void> cancel(int id) => _local.cancel(id: id);
  Future<void> cancelAll() => _local.cancelAll();

  /// Base degli ID riservati alle notifiche di scadenza (per non collidere con
  /// gli ID delle notifiche push mostrate in foreground).
  static const int reminderBase = 900000;
  static const int reminderSpan = 500;

  /// Cancella solo le notifiche di scadenza gia' programmate (range riservato),
  /// lasciando intatte le altre.
  Future<void> cancelReminders() async {
    final pending = await _local.pendingNotificationRequests();
    for (final p in pending) {
      if (p.id >= reminderBase && p.id < reminderBase + reminderSpan) {
        await _local.cancel(id: p.id);
      }
    }
  }

  Future<void> _showForeground(RemoteMessage m) async {
    final n = m.notification;
    final title = n?.title ?? m.data['title'] as String?;
    final body = n?.body ?? m.data['body'] as String?;
    if (title == null && body == null) return;
    await _local.show(
      id: m.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: m.data['route'] as String?,
    );
  }

  void _openRoute(String route) {
    try {
      appRouter.push(route);
    } catch (_) {
      // Rotta non valida: ignora (la notifica resta comunque in inbox).
    }
  }
}
