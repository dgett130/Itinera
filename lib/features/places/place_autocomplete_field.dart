import 'dart:async';

import 'package:flutter/material.dart';

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
    this.icon = Icons.place_outlined,
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
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: widget.label,
            prefixIcon: Icon(widget.icon),
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          validator: widget.validator,
          onChanged: _onChanged,
        ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, i) {
                final p = _suggestions[i];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.place, size: 20),
                  title: Text(p.label, maxLines: 2),
                  onTap: () => _select(p),
                );
              },
            ),
          ),
      ],
    );
  }
}
