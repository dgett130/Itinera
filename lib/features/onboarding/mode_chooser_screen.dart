import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums.dart';
import '../../providers.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/signatures.dart';

/// Prima apertura: scelta tra uso locale (senza login) e remoto (con server).
class ModeChooserScreen extends ConsumerWidget {
  const ModeChooserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(settingsRepositoryProvider);
    final tokens = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _BrandPanel(),
            const SizedBox(height: 28),
            Text('Come vuoi iniziare?', style: context.texts.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Potrai cambiare quando vuoi dalle Impostazioni.',
              style: context.texts.bodyMedium
                  ?.copyWith(color: context.scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            _ModeCard(
              icon: Icons.phone_iphone,
              title: 'Solo su questo dispositivo',
              subtitle:
                  'I dati restano nel telefono. Nessun account, nessun login.',
              onTap: () => repo.chooseMode(AppMode.local),
            ),
            const SizedBox(height: 12),
            _ModeCard(
              icon: Icons.cloud_sync,
              title: 'Con il mio server',
              subtitle: 'Accedi e sincronizza i viaggi tra i tuoi dispositivi.',
              accent: tokens.accent,
              onTap: () => repo.chooseMode(AppMode.remote),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 200,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(gradient: tokens.heroLinearGradient),
            ),
            Positioned.fill(
              child: CustomPaint(painter: ContourPainter(tokens.heroForeground)),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'ITINERA',
                    style: TextStyle(
                      fontFamily: tokens.monoFont,
                      color: tokens.heroForegroundMuted,
                      fontSize: 12,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ogni viaggio,\ndalla valigia alla strada.',
                    style: TextStyle(
                      fontFamily: tokens.displayFont,
                      color: tokens.heroForeground,
                      fontSize: 26,
                      height: 1.1,
                      fontWeight: FontWeight.w600,
                    ),
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

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    final c = accent ?? scheme.onSurface;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: tokens.hairline),
          ),
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: (accent ?? tokens.accent).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: accent ?? tokens.accent, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.texts.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: context.texts.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward, color: c.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}
