import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../core/enums.dart';
import '../../core/format.dart';
import '../../core/icon_keys.dart';
import '../../data/database.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/widgets.dart';
import '../trip/trip_providers.dart';
import 'packing_bag_sheet.dart';
import 'packing_item_sheet.dart';
import 'packing_providers.dart';
import 'packing_repository.dart';

/// Modulo Valigia: oggetti per categoria, spunta, bagagli con peso, template.
class PackingScreen extends ConsumerWidget {
  const PackingScreen({super.key, required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripProvider(tripId)).value;
    final style = trip == null
        ? TripStyle.atlante
        : ItineraTheme.effectiveStyle(trip);
    return TripThemeScope(style: style, child: _PackingBody(tripId: tripId));
  }
}

class _PackingBody extends ConsumerStatefulWidget {
  const _PackingBody({required this.tripId});
  final String tripId;

  @override
  ConsumerState<_PackingBody> createState() => _PackingBodyState();
}

class _PackingBodyState extends ConsumerState<_PackingBody> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(packingItemsProvider(widget.tripId)).value;
    final bags = ref.watch(bagsProvider(widget.tripId)).value;
    final cats = ref.watch(packingCategoriesProvider).value;

    if (items == null || bags == null || cats == null) {
      return const Scaffold(body: LoadingView());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Valigia'),
        actions: [
          IconButton(
            tooltip: 'Aggiungi bagaglio',
            icon: const Icon(Icons.add_shopping_cart_outlined),
            onPressed: () => showPackingBagSheet(context, tripId: widget.tripId),
          ),
          _TemplateMenu(tripId: widget.tripId),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showPackingItemSheet(
          context,
          tripId: widget.tripId,
          categories: cats,
          bags: bags,
        ),
        icon: const Icon(Icons.add),
        label: const Text('Oggetto'),
      ),
      body: items.isEmpty
          ? _EmptyPacking(tripId: widget.tripId)
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: _ProgressHeader(items: items),
                ),
                _EssentialBanner(items: items),
                if (bags.isNotEmpty)
                  _BagsRow(tripId: widget.tripId, bags: bags, items: items),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Cerca oggetto',
                    ),
                    onChanged: (v) =>
                        setState(() => _query = v.trim().toLowerCase()),
                  ),
                ),
                Expanded(
                  child: _ItemList(
                    tripId: widget.tripId,
                    items: items,
                    bags: bags,
                    categories: cats,
                    query: _query,
                  ),
                ),
              ],
            ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.items});
  final List<PackingItem> items;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final total = items.length;
    final packed = items.where((i) => i.packedCount >= i.quantity).length;
    final ratio = total == 0 ? 0.0 : packed / total;
    return ItineraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(ratio * 100).round()}',
                style: TextStyle(
                  fontFamily: tokens.displayFont,
                  fontSize: 40,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  color: tokens.positive,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 2),
                child: Text('%',
                    style: context.texts.titleMedium
                        ?.copyWith(color: tokens.positive)),
              ),
              const Spacer(),
              Text(
                'Pronti $packed di $total',
                style: context.texts.bodyMedium
                    ?.copyWith(color: context.scheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MeterBar(value: ratio, color: tokens.positive, height: 10),
        ],
      ),
    );
  }
}

class _EssentialBanner extends StatelessWidget {
  const _EssentialBanner({required this.items});
  final List<PackingItem> items;

  @override
  Widget build(BuildContext context) {
    final missing =
        items.where((i) => i.isEssential && i.packedCount < i.quantity).length;
    if (missing == 0) return const SizedBox.shrink();
    final tokens = context.tokens;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tokens.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.priority_high, color: tokens.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              missing == 1
                  ? 'Manca 1 essenziale da preparare'
                  : 'Mancano $missing essenziali da preparare',
              style: TextStyle(
                  color: tokens.warning, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _BagsRow extends StatelessWidget {
  const _BagsRow(
      {required this.tripId, required this.bags, required this.items});
  final String tripId;
  final List<Bag> bags;
  final List<PackingItem> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        children: [
          for (final bag in bags) ...[
            _BagChip(tripId: tripId, bag: bag, items: items),
            const SizedBox(width: 10),
          ],
          _AddBagChip(tripId: tripId),
        ],
      ),
    );
  }
}

class _BagChip extends StatelessWidget {
  const _BagChip(
      {required this.tripId, required this.bag, required this.items});
  final String tripId;
  final Bag bag;
  final List<PackingItem> items;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    final inBag = items.where((i) => i.bagId == bag.id).toList();
    final weight = computeBagWeight(bag, inBag);
    final over = bag.maxWeightGrams != null &&
        weight.complete &&
        weight.grams > bag.maxWeightGrams!;
    final label = bag.maxWeightGrams != null
        ? '${Fmt.weightGrams(weight.grams)}${weight.complete ? '' : '+'} / ${Fmt.weightGrams(bag.maxWeightGrams!)}'
        : '${Fmt.weightGrams(weight.grams)}${weight.complete ? '' : '+'}';
    return InkWell(
      onTap: () => showPackingBagSheet(context, tripId: tripId, existing: bag),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: over ? tokens.warning.withValues(alpha: 0.12)
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: over ? tokens.warning.withValues(alpha: 0.5)
                  : tokens.hairline),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(bag.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.titleSmall),
                ),
                if (over)
                  Icon(Icons.warning_amber, size: 16, color: tokens.warning),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: tokens.monoFont,
                fontSize: 12,
                color: over ? tokens.warning : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddBagChip extends StatelessWidget {
  const _AddBagChip({required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return InkWell(
      onTap: () => showPackingBagSheet(context, tripId: tripId),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: tokens.hairline,
            style: BorderStyle.solid,
          ),
        ),
        child: Icon(Icons.add, color: tokens.accent),
      ),
    );
  }
}

class _ItemList extends ConsumerWidget {
  const _ItemList({
    required this.tripId,
    required this.items,
    required this.bags,
    required this.categories,
    required this.query,
  });

  final String tripId;
  final List<PackingItem> items;
  final List<Bag> bags;
  final List<PackingCategory> categories;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = query.isEmpty
        ? items
        : items.where((i) => i.name.toLowerCase().contains(query)).toList();

    if (filtered.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'Nessun risultato',
        message: 'Nessun oggetto corrisponde alla ricerca.',
      );
    }

    final catById = {for (final c in categories) c.id: c};
    final bagById = {for (final b in bags) b.id: b};

    final grouped = <String, List<PackingItem>>{};
    for (final it in filtered) {
      grouped.putIfAbsent(it.categoryId, () => []).add(it);
    }
    final orderedCatIds = [
      ...categories.map((c) => c.id).where(grouped.containsKey),
      ...grouped.keys.where((id) => !catById.containsKey(id)),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      children: [
        for (final catId in orderedCatIds)
          _CategorySection(
            category: catById[catId],
            items: grouped[catId]!,
            bagById: bagById,
            categories: categories,
            bags: bags,
            tripId: tripId,
          ),
      ],
    );
  }
}

class _CategorySection extends ConsumerWidget {
  const _CategorySection({
    required this.category,
    required this.items,
    required this.bagById,
    required this.categories,
    required this.bags,
    required this.tripId,
  });

  final PackingCategory? category;
  final List<PackingItem> items;
  final Map<String, Bag> bagById;
  final List<PackingCategory> categories;
  final List<Bag> bags;
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(packingRepositoryProvider);
    final tokens = context.tokens;
    final scheme = context.scheme;
    Color? color;
    if (category?.colorHex != null) {
      color =
          Color(int.parse('FF${category!.colorHex!.substring(1)}', radix: 16));
    }
    final packedInCat =
        items.where((i) => i.packedCount >= i.quantity).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
          child: Row(
            children: [
              Icon(iconForKey(category?.iconKey ?? 'category'),
                  size: 18, color: color ?? tokens.accent),
              const SizedBox(width: 8),
              Text(
                (category?.name ?? 'Varie').toUpperCase(),
                style: TextStyle(
                  fontFamily: tokens.monoFont,
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: color ?? scheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text('$packedInCat/${items.length}',
                  style: TextStyle(
                    fontFamily: tokens.monoFont,
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  )),
            ],
          ),
        ),
        ItineraCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i != 0) Divider(height: 1, color: tokens.hairline),
                _PackingItemTile(
                  item: items[i],
                  bag: items[i].bagId == null ? null : bagById[items[i].bagId],
                  onToggle: () => repo.togglePacked(items[i]),
                  onEdit: () => showPackingItemSheet(
                    context,
                    tripId: tripId,
                    categories: categories,
                    bags: bags,
                    existing: items[i],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PackingItemTile extends StatelessWidget {
  const _PackingItemTile({
    required this.item,
    required this.bag,
    required this.onToggle,
    required this.onEdit,
  });

  final PackingItem item;
  final Bag? bag;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    final packed = item.packedCount >= item.quantity;

    final tags = <Widget>[];
    if (item.quantity > 1) tags.add(MonoTag('×${item.quantity}'));
    if (item.unitWeightGrams != null) {
      tags.add(MonoTag(Fmt.weightGrams(item.unitWeightGrams! * item.quantity)));
    }
    if (bag != null) tags.add(MonoTag(bag!.name, icon: Icons.work_outline));

    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _CheckDot(checked: packed, onTap: onToggle),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (item.isEssential)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child:
                              Icon(Icons.star, size: 15, color: tokens.accent),
                        ),
                      Expanded(
                        child: Text(
                          item.name,
                          style: context.texts.bodyLarge?.copyWith(
                            decoration:
                                packed ? TextDecoration.lineThrough : null,
                            color: packed ? scheme.onSurfaceVariant : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(spacing: 6, runSpacing: 6, children: tags),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: tokens.hairline),
          ],
        ),
      ),
    );
  }
}

/// Cerchietto di spunta animato.
class _CheckDot extends StatelessWidget {
  const _CheckDot({required this.checked, required this.onTap});
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: checked ? tokens.positive : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: checked ? tokens.positive : tokens.hairline,
            width: 2,
          ),
        ),
        child: checked
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}

class _EmptyPacking extends ConsumerWidget {
  const _EmptyPacking({required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = ref.watch(packingCategoriesProvider).value ?? const [];
    final bags = ref.watch(bagsProvider(tripId)).value ?? const [];
    return EmptyState(
      icon: Icons.checklist_rtl,
      title: 'Valigia vuota',
      message: 'Aggiungi il primo oggetto o parti da un modello pronto.',
      action: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton.icon(
            onPressed: cats.isEmpty
                ? null
                : () => showPackingItemSheet(
                      context,
                      tripId: tripId,
                      categories: cats,
                      bags: bags,
                    ),
            icon: const Icon(Icons.add),
            label: const Text('Aggiungi oggetto'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _showTemplatePicker(context, ref, tripId),
            icon: const Icon(Icons.playlist_add),
            label: const Text('Applica un modello'),
          ),
        ],
      ),
    );
  }
}

class _TemplateMenu extends ConsumerWidget {
  const _TemplateMenu({required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.playlist_add_check),
      onSelected: (value) async {
        if (value == 'apply') {
          await _showTemplatePicker(context, ref, tripId);
        } else if (value == 'save') {
          await _saveAsTemplate(context, ref, tripId);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'apply', child: Text('Applica un modello')),
        PopupMenuItem(value: 'save', child: Text('Salva come modello')),
      ],
    );
  }
}

Future<void> _showTemplatePicker(
    BuildContext context, WidgetRef ref, String tripId) async {
  final templates =
      await ref.read(packingRepositoryProvider).watchTemplates().first;
  if (!context.mounted) return;
  final selected = await showModalBottomSheet<String>(
    context: context,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHeader('Scegli un modello'),
            const SizedBox(height: 8),
            for (final t in templates)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.luggage_outlined,
                    color: context.tokens.accent),
                title: Text(t.name),
                subtitle: t.description != null ? Text(t.description!) : null,
                onTap: () => Navigator.pop(context, t.id),
              ),
          ],
        ),
      ),
    ),
  );
  if (selected == null || !context.mounted) return;
  final count =
      await ref.read(packingRepositoryProvider).applyTemplate(tripId, selected);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$count oggetti aggiunti dal modello')),
    );
  }
}

Future<void> _saveAsTemplate(
    BuildContext context, WidgetRef ref, String tripId) async {
  final controller = TextEditingController();
  final name = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Salva come modello'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Nome del modello'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text('Salva'),
        ),
      ],
    ),
  );
  if (name == null || name.isEmpty || !context.mounted) return;
  await ref.read(packingRepositoryProvider).saveAsTemplate(tripId, name);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Modello "$name" salvato')),
    );
  }
}
