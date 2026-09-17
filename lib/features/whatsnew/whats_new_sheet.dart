import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import 'stickman_hiker.dart';
import 'whats_new_data.dart';

/// Pannello "Novità" mostrato una volta dopo ogni aggiornamento: stickman con
/// zaino animato + elenco delle novità della versione.
class WhatsNewSheet extends StatelessWidget {
  const WhatsNewSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final scheme = context.scheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: tokens.hairline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              width: double.infinity,
              height: 228,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFBFE6F5), Color(0xFFEAF6FB)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const StickmanHiker(fit: BoxFit.contain),
            ),
            const SizedBox(height: 16),
            Text(l10n.whatsNewTitle, style: context.texts.titleLarge),
            const SizedBox(height: 2),
            Text(
              'v$kWhatsNewVersion',
              style: TextStyle(
                fontFamily: tokens.monoFont,
                fontSize: 12,
                letterSpacing: 1,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: kWhatsNewItems.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, i) => _ItemRow(item: kWhatsNewItems[i]),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.whatsNewGotIt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});
  final WhatsNewItem item;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: tokens.accentSoft,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(item.icon, size: 21, color: tokens.accent),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: context.texts.titleSmall),
              const SizedBox(height: 2),
              Text(
                item.body,
                style: context.texts.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
