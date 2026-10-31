import 'package:flutter/material.dart';

import '../../core/enum_labels.dart';
import '../../data/reference_data.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
import '../../ui/widgets.dart';

/// Selettore auto dal catalogo offline: cerca marca/modello e ritorna la
/// [CarSpec] scelta (con consumo e tipo carburante).
Future<CarSpec?> showCarPicker(BuildContext context) {
  return showCartolinaSheet<CarSpec>(
    context: context,
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
    final scheme = context.scheme;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 10,
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
              hintText: 'Es. Golf, Panda, 500…',
            ),
            onChanged: (v) =>
                setState(() => _results = ReferenceData.filterCars(_all, v)),
          ),
          const SizedBox(height: 10),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _results.length,
                separatorBuilder: (context, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final c = _results[i];
                  return ItineraCard(
                    padding: const EdgeInsets.all(12),
                    onTap: () => Navigator.pop(context, c),
                    child: Row(
                      children: [
                        const IconTile(
                          Icons.directions_car,
                          color: Cartolina.laguna,
                          size: 40,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: context.texts.titleSmall?.copyWith(
                                  fontSize: 15.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${c.fuel.label} · ${c.consumption.toString().replaceAll('.', ',')} ${c.unit.label}',
                                style: context.texts.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Consumi indicativi (WLTP), modificabili dopo la selezione.',
            style: context.texts.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
