import 'package:flutter/material.dart';

import '../../data/reference_data.dart';

/// Campo con autocomplete del paese da lista offline (assets/countries.json).
class CountryAutocompleteField extends StatefulWidget {
  const CountryAutocompleteField({
    super.key,
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

  @override
  State<CountryAutocompleteField> createState() =>
      _CountryAutocompleteFieldState();
}

class _CountryAutocompleteFieldState extends State<CountryAutocompleteField> {
  List<Country> _all = const [];
  List<Country> _suggestions = const [];

  @override
  void initState() {
    super.initState();
    ReferenceData.countries().then((c) {
      if (mounted) setState(() => _all = c);
    });
  }

  void _onChanged(String value) {
    if (value.trim().isEmpty) {
      setState(() => _suggestions = const []);
      return;
    }
    setState(() {
      _suggestions = ReferenceData.filterCountries(_all, value);
    });
  }

  void _select(Country c) {
    widget.controller.text = c.name;
    setState(() => _suggestions = const []);
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
            prefixIcon: const Icon(Icons.public),
          ),
          onChanged: _onChanged,
        ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, i) {
                final c = _suggestions[i];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.flag_outlined, size: 20),
                  title: Text(c.name),
                  onTap: () => _select(c),
                );
              },
            ),
          ),
      ],
    );
  }
}
