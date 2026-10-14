import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:itinera/core/enums.dart';
import 'package:itinera/features/explore/explore_providers.dart';
import 'package:itinera/features/explore/place_photo_service.dart';
import 'package:itinera/features/explore/place_sheet.dart';
import 'package:itinera/l10n/app_localizations.dart';

String _claims(String? file) => jsonEncode({
  'claims': {
    if (file != null)
      'P18': [
        {
          'mainsnak': {
            'datavalue': {'value': file},
          },
        },
      ],
  },
});

final _commons = jsonEncode({
  'query': {
    'pages': {
      '-1': {
        'imageinfo': [
          {
            'thumburl': 'https://upload.wikimedia.org/thumb/colosseo.jpg',
            'url': 'https://upload.wikimedia.org/colosseo.jpg',
            'descriptionurl':
                'https://commons.wikimedia.org/wiki/File:Colosseo.jpg',
            'extmetadata': {
              'Artist': {
                'value':
                    '<a href="//commons.wikimedia.org/wiki/User:X">User:Mario '
                    '&amp; Anna</a>',
              },
              'LicenseShortName': {'value': 'CC BY-SA 4.0'},
            },
          },
        ],
      },
    },
  },
});

/// PNG 1×1 trasparente: nei test la rete non c'è.
const _transparentPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

void main() {
  group('PlacePhotoService', () {
    test('Wikidata P18 → miniatura, pagina, autore (senza HTML) e '
        'licenza', () async {
      final calls = <Uri>[];
      final client = MockClient((req) async {
        calls.add(req.url);
        expect(req.headers['User-Agent'], contains('Itinera'));
        return req.url.host == 'www.wikidata.org'
            ? http.Response(_claims('Colosseo.jpg'), 200)
            : http.Response(_commons, 200);
      });
      final photo = await PlacePhotoService(
        client: client,
      ).forWikidata('Q10285');
      expect(photo, isNotNull);
      expect(
        photo!.imageUrl,
        'https://upload.wikimedia.org/thumb/colosseo.jpg',
      );
      expect(photo.pageUrl, contains('File:Colosseo.jpg'));
      expect(photo.author, 'Mario & Anna');
      expect(photo.license, 'CC BY-SA 4.0');
      expect(calls.last.queryParameters['titles'], 'File:Colosseo.jpg');
    });

    test(
      'nessuna foto, errori, rete assente o codice non valido: null',
      () async {
        Future<PlacePhoto?> run(
          Future<http.Response> Function(http.Request) handler, [
          String qid = 'Q1',
        ]) => PlacePhotoService(client: MockClient(handler)).forWikidata(qid);

        expect(
          await run((_) async => http.Response(_claims(null), 200)),
          isNull,
        );
        expect(await run((_) async => http.Response('boom', 500)), isNull);
        expect(await run((_) async => http.Response('<html>', 200)), isNull);
        expect(await run((_) async => throw Exception('offline')), isNull);

        var called = false;
        Future<http.Response> spy(http.Request _) async {
          called = true;
          return http.Response('', 200);
        }

        expect(await run(spy, 'Colosseo'), isNull);
        expect(await run(spy, ''), isNull);
        expect(called, isFalse, reason: 'niente richieste senza un codice Q');
      },
    );
  });

  testWidgets('Scheda del luogo: con la foto mostra autore e licenza; senza '
      'non occupa spazio', (tester) async {
    Future<void> show(PlacePhoto? photo) async {
      // Scope nuovo a ogni giro: la foto resta in memoria per sessione.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            placePhotoProvider.overrideWith((ref, qid) async => photo),
            placePhotoImageProvider.overrideWithValue(
              (_) => MemoryImage(Uint8List.fromList(_transparentPng)),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('it'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: PlaceSheet(
                place: PlaceInfo(
                  name: 'Colosseo',
                  category: PoiCategory.monument,
                  wikidata: 'Q10285',
                ),
              ),
            ),
          ),
        ),
      );
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    await show(
      const PlacePhoto(
        imageUrl: 'https://upload.wikimedia.org/thumb/colosseo.jpg',
        pageUrl: 'https://commons.wikimedia.org/wiki/File:Colosseo.jpg',
        author: 'Mario',
        license: 'CC BY-SA 4.0',
      ),
    );
    expect(
      find.text('Foto: Mario · CC BY-SA 4.0 · Wikimedia Commons'),
      findsOneWidget,
    );

    await show(null);
    expect(find.textContaining('Foto:'), findsNothing);
    expect(find.byType(Image), findsNothing);
  });
}
