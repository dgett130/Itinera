import 'package:supabase_flutter/supabase_flutter.dart';

/// Una notifica dell'inbox (tabella Supabase `notifications`).
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    this.data = const {},
    this.readAt,
    required this.createdAt,
  });

  final String id;
  final String type; // friend_request|friend_accepted|shared_trip|new_document|system
  final String title;
  final String? body;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isRead => readAt != null;
  String? get route => data['route'] as String?;

  factory AppNotification.fromMap(Map<String, dynamic> m) => AppNotification(
    id: m['id'] as String,
    type: m['type'] as String? ?? 'system',
    title: m['title'] as String? ?? '',
    body: m['body'] as String?,
    data: (m['data'] as Map?)?.cast<String, dynamic>() ?? const {},
    readAt: m['read_at'] != null
        ? DateTime.parse(m['read_at'] as String).toLocal()
        : null,
    createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
  );
}

/// Preferenze di notifica per categoria (tabella `notification_prefs`).
class NotificationPrefs {
  const NotificationPrefs({
    this.pushEnabled = true,
    this.friendRequests = true,
    this.sharedTrips = true,
    this.newDocuments = true,
    this.systemMessages = true,
  });

  final bool pushEnabled; // master
  final bool friendRequests;
  final bool sharedTrips;
  final bool newDocuments;
  final bool systemMessages;

  factory NotificationPrefs.fromMap(Map<String, dynamic> m) => NotificationPrefs(
    pushEnabled: m['push_enabled'] as bool? ?? true,
    friendRequests: m['friend_requests'] as bool? ?? true,
    sharedTrips: m['shared_trips'] as bool? ?? true,
    newDocuments: m['new_documents'] as bool? ?? true,
    systemMessages: m['system_messages'] as bool? ?? true,
  );

  NotificationPrefs copyWith({
    bool? pushEnabled,
    bool? friendRequests,
    bool? sharedTrips,
    bool? newDocuments,
    bool? systemMessages,
  }) => NotificationPrefs(
    pushEnabled: pushEnabled ?? this.pushEnabled,
    friendRequests: friendRequests ?? this.friendRequests,
    sharedTrips: sharedTrips ?? this.sharedTrips,
    newDocuments: newDocuments ?? this.newDocuments,
    systemMessages: systemMessages ?? this.systemMessages,
  );

  Map<String, dynamic> toMap() => {
    'push_enabled': pushEnabled,
    'friend_requests': friendRequests,
    'shared_trips': sharedTrips,
    'new_documents': newDocuments,
    'system_messages': systemMessages,
  };
}

/// Accesso Supabase all'inbox notifiche, alle preferenze e ai token FCM.
class NotificationsRepository {
  NotificationsRepository(this._client);

  final SupabaseClient? _client;

  bool get isReady => _client != null;

  SupabaseClient get _c {
    final c = _client;
    if (c == null) throw const AuthException('Account non disponibile.');
    return c;
  }

  String? get _uid => _client?.auth.currentUser?.id;

  static String _nowIso() => DateTime.now().toUtc().toIso8601String();

  /// Stream realtime delle notifiche dell'utente (piu' recenti in cima).
  Stream<List<AppNotification>> watch() {
    final uid = _uid;
    if (_client == null || uid == null) {
      return const Stream<List<AppNotification>>.empty();
    }
    return _c
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('created_at')
        .map(
          (rows) => rows
              .map((r) => AppNotification.fromMap(r))
              .toList()
              .reversed
              .toList(),
        );
  }

  Future<void> markRead(String id) async {
    await _c
        .from('notifications')
        .update({'read_at': _nowIso()})
        .eq('id', id);
  }

  Future<void> markAllRead() async {
    final uid = _uid;
    if (uid == null) return;
    await _c
        .from('notifications')
        .update({'read_at': _nowIso()})
        .eq('user_id', uid)
        .isFilter('read_at', null);
  }

  Future<void> delete(String id) async {
    await _c.from('notifications').delete().eq('id', id);
  }

  // --- Token FCM -----------------------------------------------------------

  Future<void> upsertToken(String token, String platform) async {
    final uid = _uid;
    if (uid == null) return;
    await _c.from('device_tokens').upsert({
      'token': token,
      'user_id': uid,
      'platform': platform,
      'updated_at': _nowIso(),
    }, onConflict: 'token');
  }

  Future<void> removeToken(String token) async {
    if (_client == null) return;
    await _c.from('device_tokens').delete().eq('token', token);
  }

  // --- Preferenze ----------------------------------------------------------

  Future<NotificationPrefs> prefs() async {
    final uid = _uid;
    if (_client == null || uid == null) return const NotificationPrefs();
    final row = await _c
        .from('notification_prefs')
        .select()
        .eq('user_id', uid)
        .maybeSingle();
    return row == null
        ? const NotificationPrefs()
        : NotificationPrefs.fromMap(row);
  }

  Future<void> savePrefs(NotificationPrefs p) async {
    final uid = _uid;
    if (uid == null) return;
    await _c.from('notification_prefs').upsert({
      'user_id': uid,
      ...p.toMap(),
      'updated_at': _nowIso(),
    }, onConflict: 'user_id');
  }

  // --- Admin ---------------------------------------------------------------

  /// True se l'utente corrente ha il flag `is_admin` sul profilo.
  Future<bool> isAdmin() async {
    final uid = _uid;
    if (_client == null || uid == null) return false;
    try {
      final row = await _c
          .from('profiles')
          .select('is_admin')
          .eq('id', uid)
          .maybeSingle();
      return (row?['is_admin'] as bool?) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Invia un messaggio di sistema (admin) a un utente o a tutti (target null).
  /// Ritorna il numero di destinatari. Il push parte via webhook.
  Future<int> sendSystemMessage(
    String title,
    String body, {
    String? targetUserId,
  }) async {
    final res = await _c.rpc(
      'send_system_message',
      params: {'p_title': title, 'p_body': body, 'p_target': targetUserId},
    );
    return (res as int?) ?? 0;
  }
}
