import 'package:supabase_flutter/supabase_flutter.dart';

/// Un membro (o invito in sospeso) di un viaggio.
class TripMember {
  const TripMember({
    required this.id,
    required this.tripId,
    required this.role,
    required this.status,
    this.userId,
    this.email,
    this.name,
  });

  final String id;
  final String tripId;
  final String role; // 'owner' | 'editor'
  final String status; // 'active' | 'pending'
  final String? userId;
  final String? email;

  /// Nome visualizzato risolto dal profilo (per i membri con user_id).
  final String? name;

  bool get isOwner => role == 'owner';
  bool get isPending => status == 'pending';

  /// Etichetta migliore disponibile: nome profilo, poi email invito, poi generico.
  String get label => (name != null && name!.isNotEmpty)
      ? name!
      : (email ?? 'Utente');

  TripMember withName(String? n) => TripMember(
        id: id,
        tripId: tripId,
        role: role,
        status: status,
        userId: userId,
        email: email,
        name: n,
      );

  factory TripMember.fromMap(Map<String, dynamic> m) => TripMember(
        id: m['id'] as String,
        tripId: m['trip_id'] as String,
        role: (m['role'] as String?) ?? 'editor',
        status: (m['status'] as String?) ?? 'pending',
        userId: m['user_id'] as String?,
        email: m['invited_email'] as String?,
      );
}

/// Gestione dei membri di un viaggio (tabella `trip_members`, RLS: solo l'owner
/// aggiunge/rimuove). Online.
class MembersService {
  MembersService(this._client);

  final SupabaseClient? _client;

  bool get isReady => _client != null;

  SupabaseClient get _c {
    final c = _client;
    if (c == null) throw const AuthException('Account non disponibile.');
    return c;
  }

  Future<List<TripMember>> listForTrip(String tripId) async {
    final data = await _c
        .from('trip_members')
        .select()
        .eq('trip_id', tripId)
        .order('role', ascending: true);
    final members = (data as List)
        .map((m) => TripMember.fromMap(Map<String, dynamic>.from(m as Map)))
        .toList();
    // Risolvo i nomi dai profili (RLS: i co-membri possono leggerseli).
    final ids = [
      for (final m in members)
        if (m.userId != null) m.userId!
    ];
    if (ids.isNotEmpty) {
      try {
        final profs = await _c
            .from('profiles')
            .select('id, display_name')
            .inFilter('id', ids);
        final byId = {
          for (final p in (profs as List))
            (p as Map)['id'] as String: p['display_name'] as String?
        };
        for (var i = 0; i < members.length; i++) {
          final n = byId[members[i].userId];
          if (n != null) members[i] = members[i].withName(n);
        }
      } catch (_) {
        // profilo non leggibile/offline: resta l'etichetta di fallback.
      }
    }
    return members;
  }

  /// Aggiunge un utente REALE (gia' registrato) al viaggio come editor attivo:
  /// lo vedra' subito alla prossima sincronizzazione. Idempotente.
  Future<void> addUser(String tripId, String userId) async {
    await _c.from('trip_members').upsert(
      {
        'trip_id': tripId,
        'user_id': userId,
        'role': 'editor',
        'status': 'active',
      },
      onConflict: 'trip_id,user_id',
      ignoreDuplicates: true,
    );
  }

  /// Invito legacy per email (utente non ancora registrato): reclamato al login
  /// tramite claim_invites. Mantenuto per compatibilita'.
  Future<void> invite(String tripId, String email) async {
    await _c.from('trip_members').insert({
      'trip_id': tripId,
      'invited_email': email.trim().toLowerCase(),
      'role': 'editor',
      'status': 'pending',
    });
  }

  Future<void> remove(String memberId) =>
      _c.from('trip_members').delete().eq('id', memberId);
}
