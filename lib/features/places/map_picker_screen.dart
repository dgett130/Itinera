import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';

/// Schermata di selezione di un punto sulla mappa (OpenStreetMap).
///
/// Ritorna il [LatLng] scelto via Navigator.pop, oppure null se annullato.
/// I tile richiedono rete; offline la mappa resta grigia ma il resto dell'app
/// funziona (il luogo si può inserire a mano).
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
    final scheme = context.scheme;
    final selected = _selected;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scegli sulla mappa'),
        actions: [
          if (selected != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: () => Navigator.pop(context, selected),
                child: const Text(
                  'Conferma',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
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
                tileBuilder: Theme.of(context).brightness == Brightness.dark
                    ? darkModeTileBuilder
                    : null,
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'org.itinera.app',
              ),
              if (selected != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selected,
                      width: 44,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: _DroppingPin(key: ValueKey(selected)),
                    ),
                  ],
                ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    'OpenStreetMap contributors',
                    style: context.texts.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (selected == null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 44,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.onSurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Tocca la mappa per scegliere un punto',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: scheme.surface),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Lo spillo cade dall'alto a ogni punto scelto.
class _DroppingPin extends StatelessWidget {
  const _DroppingPin({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Motion.of(context, Motion.standard),
      curve: Motion.pop,
      builder: (context, v, child) =>
          Transform.translate(offset: Offset(0, -44 * (1 - v)), child: child),
      child: const Icon(Icons.location_pin, size: 44, color: Cartolina.corallo),
    );
  }
}
