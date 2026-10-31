import 'dart:async';

import 'package:flutter/material.dart';

import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
import 'geocoding_service.dart';

/// Campo di testo con autocomplete dei luoghi (Photon/OSM).
///
/// Il [controller] contiene sempre l'etichetta testuale (modificabile a mano);
/// [onSelected] viene chiamato quando l'utente sceglie un suggerimento, con
/// coordinate e paese. Offline i suggerimenti non compaiono: resta l'input
/// manuale.
class PlaceAutocompleteField extends StatefulWidget {
  const PlaceAutocompleteField({
    super.key,
    required this.controller,
    required this.label,
    this.icon = Icons.place,
    this.onSelected,
    this.onManualEdit,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final void Function(PlaceResult place)? onSelected;

  /// Chiamato quando l'utente digita a mano (non su selezione di un
  /// suggerimento): utile per invalidare eventuali coordinate salvate.
  final void Function(String text)? onManualEdit;
  final String? Function(String?)? validator;

  @override
  State<PlaceAutocompleteField> createState() => _PlaceAutocompleteFieldState();
}

class _PlaceAutocompleteFieldState extends State<PlaceAutocompleteField> {
  final _geocoding = GeocodingService();
  Timer? _debounce;
  List<PlaceResult> _suggestions = const [];
  bool _loading = false;
  bool _suppress = false; // evita ricerche dopo una selezione

  @override
  void dispose() {
    _debounce?.cancel();
    _geocoding.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    if (_suppress) {
      _suppress = false;
      return;
    }
    widget.onManualEdit?.call(value);
    _debounce?.cancel();
    if (value.trim().length < 3) {
      setState(() => _suggestions = const []);
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      final results = await _geocoding.search(value);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _loading = false;
      });
    });
  }

  void _select(PlaceResult place) {
    _suppress = true;
    widget.controller.text = place.label;
    setState(() => _suggestions = const []);
    widget.onSelected?.call(place);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: widget.label,
            suffixIcon: _loading
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.tokens.accent,
                      ),
                    ),
                  )
                : Icon(widget.icon, color: scheme.onSurfaceVariant),
          ),
          validator: widget.validator,
          onChanged: _onChanged,
        ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 240),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.tokens.hairline),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: _suggestions.length,
                itemBuilder: (context, i) {
                  final p = _suggestions[i];
                  return StaggerIn(
                    key: ValueKey('${p.label}/${p.latitude}/${p.longitude}'),
                    index: i,
                    offset: 12,
                    child: PlaceResultRow(place: p, onTap: () => _select(p)),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

/// Riga di un risultato di ricerca: nome in evidenza, poi il resto
/// dell'indirizzo. Va dentro una card o una [Material].
class PlaceResultRow extends StatelessWidget {
  const PlaceResultRow({super.key, required this.place, required this.onTap});

  final PlaceResult place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final muted = context.scheme.onSurfaceVariant;
    final label = place.label;
    final comma = label.indexOf(',');
    final title = comma > 0 ? label.substring(0, comma) : label;
    final rest = comma > 0 ? label.substring(comma + 1).trim() : place.country;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          children: [
            Icon(Icons.place, size: 20, color: muted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.titleSmall,
                  ),
                  if (rest != null && rest.isNotEmpty)
                    Text(
                      rest,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.bodySmall?.copyWith(color: muted),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
