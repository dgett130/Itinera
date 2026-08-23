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
  });

  final String id;
  final String tripId;
  final String role; // 'owner' | 'editor'
  final String status; // 'active' | 'pending'
  final String? userId;
  final String? email;

  bool get isOwner => role == 'owner';
  bool get isPending => status == 'pending';

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
    return (data as List)
        .map((m) => TripMember.fromMap(Map<String, dynamic>.from(m as Map)))
        .toList();
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
