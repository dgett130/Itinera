import 'package:supabase_flutter/supabase_flutter.dart';

/// Riferimento a un utente nel contesto amici: un amico accettato, una
/// richiesta ricevuta, o un risultato di ricerca.
class UserRef {
  const UserRef({
    required this.userId,
    this.friendshipId,
    this.name,
    this.email,
    this.relation,
  });

  final String userId;

  /// Id della riga `friendships` (per amici e richieste), se disponibile.
  final String? friendshipId;
  final String? name;
  final String? email;

  /// 'friend' | 'pending_out' | 'pending_in' | 'none' (dai risultati ricerca).
  final String? relation;

  String get display =>
      (name != null && name!.isNotEmpty) ? name! : (email ?? 'Utente');
  String get initial =>
      display.isEmpty ? '?' : display.substring(0, 1).toUpperCase();

  factory UserRef.friend(Map<String, dynamic> m) => UserRef(
        userId: m['user_id'] as String,
        friendshipId: m['friendship_id'] as String?,
        name: m['display_name'] as String?,
        email: m['email'] as String?,
        relation: 'friend',
      );

  factory UserRef.request(Map<String, dynamic> m) => UserRef(
        userId: m['user_id'] as String,
        friendshipId: m['friendship_id'] as String?,
        name: m['display_name'] as String?,
        email: m['email'] as String?,
        relation: 'pending_in',
      );

  factory UserRef.search(Map<String, dynamic> m) => UserRef(
        userId: m['id'] as String,
        name: m['display_name'] as String?,
        email: m['email'] as String?,
        relation: m['relation'] as String?,
      );
}

/// Amici come relazioni fra utenti reali (tabella `friendships` + RPC). Online.
class FriendsService {
  FriendsService(this._client);

  final SupabaseClient? _client;

  bool get isReady => _client != null;

  SupabaseClient get _c {
    final c = _client;
    if (c == null) throw const AuthException('Account non disponibile.');
    return c;
  }

  Future<List<UserRef>> list() async {
    final data = await _c.rpc('list_friends');
    return (data as List)
        .map((m) => UserRef.friend(Map<String, dynamic>.from(m as Map)))
        .toList();
  }

  Future<List<UserRef>> requests() async {
    final data = await _c.rpc('list_friend_requests');
    return (data as List)
        .map((m) => UserRef.request(Map<String, dynamic>.from(m as Map)))
        .toList();
  }

  /// Cerca utenti per email esatta o nome (min 3 caratteri lato DB).
  Future<List<UserRef>> search(String q) async {
    final data = await _c.rpc('search_users', params: {'q': q});
    return (data as List)
        .map((m) => UserRef.search(Map<String, dynamic>.from(m as Map)))
        .toList();
  }

  Future<void> sendRequest(String userId) =>
      _c.rpc('send_friend_request', params: {'target': userId});

  Future<void> respond(String friendshipId, {required bool accept}) =>
      _c.rpc('respond_friend_request',
          params: {'req': friendshipId, 'accept': accept});

  Future<void> remove(String friendshipId) =>
      _c.rpc('remove_friend', params: {'fid': friendshipId});
}
