import 'dart:convert';

import 'package:http/http.dart' as http;

/// Foto di un luogo da Wikimedia Commons, con quanto serve per citarla.
class PlacePhoto {
  const PlacePhoto({
    required this.imageUrl,
    required this.pageUrl,
    this.author,
    this.license,
  });

  /// Miniatura già ridimensionata da Commons (larghezza ~800 px).
  final String imageUrl;

  /// Pagina del file su Commons (autore, licenza completa).
  final String pageUrl;
  final String? author;
  final String? license;
}

/// Recupera la foto principale di un luogo: dal codice Wikidata (tag OSM
/// `wikidata`) la proprietà P18 "immagine", poi da Commons miniatura, autore
/// e licenza. Solo online: senza rete, senza P18 o con errori ritorna null
/// (la scheda semplicemente non mostra la foto).
class PlacePhotoService {
  PlacePhotoService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Wikimedia chiede un User-Agent che identifichi l'app.
  static const headers = {
    'User-Agent': 'Itinera/1.4 (org.itinera.itinera; app di viaggio)',
  };
  static final _qid = RegExp(r'^Q\d+$');

  Future<PlacePhoto?> forWikidata(String? wikidata) async {
    final qid = wikidata?.trim() ?? '';
    if (!_qid.hasMatch(qid)) return null;
    try {
      final file = await _imageFile(qid);
      if (file == null) return null;
      return await _commonsInfo(file);
    } catch (_) {
      return null;
    }
  }

  /// Nome del file della proprietà P18 (es. "Colosseo 2020.jpg").
  Future<String?> _imageFile(String qid) async {
    final uri = Uri.https('www.wikidata.org', '/w/api.php', {
      'action': 'wbgetclaims',
      'entity': qid,
      'property': 'P18',
      'format': 'json',
    });
    final res = await _client
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return null;
    final json = jsonDecode(res.body);
    final claims = (json is Map ? json['claims'] : null);
    final p18 = claims is Map ? claims['P18'] : null;
    if (p18 is! List || p18.isEmpty) return null;
    final value = p18.first['mainsnak']?['datavalue']?['value'];
    return value is String && value.isNotEmpty ? value : null;
  }

  Future<PlacePhoto?> _commonsInfo(String file) async {
    final uri = Uri.https('commons.wikimedia.org', '/w/api.php', {
      'action': 'query',
      'titles': 'File:$file',
      'prop': 'imageinfo',
      'iiprop': 'url|extmetadata',
      'iiurlwidth': '800',
      'format': 'json',
    });
    final res = await _client
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return null;
    final json = jsonDecode(res.body);
    final pages = json is Map ? (json['query']?['pages']) : null;
    if (pages is! Map || pages.isEmpty) return null;
    final info = (pages.values.first as Map?)?['imageinfo'];
    if (info is! List || info.isEmpty) return null;
    final first = info.first as Map;
    final image = (first['thumburl'] ?? first['url']) as String?;
    final page = first['descriptionurl'] as String?;
    if (image == null || page == null) return null;
    final meta = first['extmetadata'];
    String? field(String k) {
      final v = meta is Map ? (meta[k]?['value']) : null;
      if (v is! String) return null;
      final text = _plainText(v);
      return text.isEmpty ? null : text;
    }

    return PlacePhoto(
      imageUrl: image,
      pageUrl: page,
      author: field(
        'Artist',
      )?.replaceFirst(RegExp(r'^(User|Utente):', caseSensitive: false), ''),
      license: field('LicenseShortName'),
    );
  }

  /// I metadati di Commons sono spesso HTML (link all'autore): solo testo.
  static String _plainText(String html) => html
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
