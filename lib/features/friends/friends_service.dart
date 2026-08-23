import 'package:supabase_flutter/supabase_flutter.dart';

/// Un amico salvato nella rubrica dei compagni di viaggio.
class Friend {
  const Friend({required this.id, required this.email, this.name});

  final String id;
  final String email;
  final String? name;

  String get display => (name != null && name!.isNotEmpty) ? name! : email;

  factory Friend.fromMap(Map<String, dynamic> m) => Friend(
        id: m['id'] as String,
        email: m['friend_email'] as String,
        name: m['friend_name'] as String?,
      );
}

/// Rubrica amici (tabella `friends` su Supabase, per-utente). Online: quando si
/// e' offline l'elenco non e' disponibile (e' una comodita', non dati critici).
class FriendsService {
  FriendsService(this._client);

  final SupabaseClient? _client;

  bool get isReady => _client != null;

  SupabaseClient get _c {
    final c = _client;
    if (c == null) {
      throw const AuthException('Account non disponibile.');
    }
    return c;
  }

  Future<List<Friend>> list() async {
    final data = await _c
        .from('friends')
        .select()
        .order('friend_name', ascending: true);
    return (data as List)
        .map((m) => Friend.fromMap(Map<String, dynamic>.from(m as Map)))
        .toList();
  }

  Future<void> add({required String email, String? name}) async {
    // owner_id lo imposta il default auth.uid() lato DB.
    await _c.from('friends').insert({
      'friend_email': email.trim().toLowerCase(),
      'friend_name': (name != null && name.trim().isNotEmpty) ? name.trim() : null,
    });
  }

  Future<void> remove(String id) => _c.from('friends').delete().eq('id', id);
}
