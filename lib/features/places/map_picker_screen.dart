import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Schermata di selezione di un punto sulla mappa (OpenStreetMap).
///
/// Ritorna il [LatLng] scelto via Navigator.pop, oppure null se annullato.
/// I tile richiedono rete; offline la mappa resta grigia ma il resto dell'app
/// funziona (il luogo si puo' inserire a mano).
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key, this.initial});

  final LatLng? initial;

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng? _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scegli sulla mappa'),
        actions: [
          if (_selected != null)
            TextButton(
              onPressed: () => Navigator.pop(context, _selected),
              child: const Text('Conferma'),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: widget.initial ?? const LatLng(41.9028, 12.4964),
              initialZoom: widget.initial != null ? 13 : 5,
              onTap: (_, point) => setState(() => _selected = point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'org.itinera.app',
              ),
              if (_selected != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selected!,
                      width: 44,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: Icon(Icons.location_pin,
                          size: 44, color: scheme.error),
                    ),
                  ],
                ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          if (_selected == null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: scheme.inverseSurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Tocca la mappa per scegliere un punto',
                    style: TextStyle(color: scheme.onInverseSurface),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
