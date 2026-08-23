import 'package:flutter/material.dart';

import '../../core/enum_labels.dart';
import '../../data/reference_data.dart';
import '../../ui/widgets.dart';

/// Selettore auto dal catalogo offline: cerca marca/modello e ritorna la
/// [CarSpec] scelta (con consumo e tipo carburante).
Future<CarSpec?> showCarPicker(BuildContext context) {
  return showModalBottomSheet<CarSpec>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _CarPicker(),
  );
}

class _CarPicker extends StatefulWidget {
  const _CarPicker();

  @override
  State<_CarPicker> createState() => _CarPickerState();
}

class _CarPickerState extends State<_CarPicker> {
  List<CarSpec> _all = const [];
  List<CarSpec> _results = const [];

  @override
  void initState() {
    super.initState();
    ReferenceData.cars().then((c) {
      if (mounted) setState(() => _all = c);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHeader('Cerca la tua auto'),
          const SizedBox(height: 12),
          TextField(
            autofocus: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Es. Golf, Panda, 500...',
            ),
            onChanged: (v) =>
                setState(() => _results = ReferenceData.filterCars(_all, v)),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _results.length,
              itemBuilder: (context, i) {
                final c = _results[i];
                return ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: Text(c.label),
                  subtitle: Text(
                    '${c.fuel.label} · ${c.consumption.toString().replaceAll('.', ',')} ${c.unit.label}',
                  ),
                  onTap: () => Navigator.pop(context, c),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Consumi indicativi (WLTP), modificabili dopo la selezione.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
