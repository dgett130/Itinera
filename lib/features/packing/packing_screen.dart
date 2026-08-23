import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../core/enum_labels.dart';
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

/// Chiave sentinella per il filtro "oggetti senza borsa".
const String _kNoBag = '__none__';

class _PackingBodyState extends ConsumerState<_PackingBody> {
  String _query = '';

  /// Bagagli selezionati come filtro (vuoto = mostra tutti). Puo' contenere
  /// [_kNoBag] per gli oggetti non assegnati a una borsa.
  final Set<String> _selectedBags = {};

  void _toggleBag(String key) {
    setState(() {
      if (!_selectedBags.remove(key)) _selectedBags.add(key);
    });
  }

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
                _BagFilterRow(
                  tripId: widget.tripId,
                  bags: bags,
                  items: items,
                  selected: _selectedBags,
                  onToggle: _toggleBag,
                ),
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
                    selectedBags: _selectedBags,
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

/// Riga di cerchietti-filtro dei bagagli: tocca per mostrare solo gli oggetti
/// di quelle borse; nessuna selezione = mostra tutto. Pressione prolungata su
/// una borsa per modificarla.
class _BagFilterRow extends StatelessWidget {
  const _BagFilterRow({
    required this.tripId,
    required this.bags,
    required this.items,
    required this.selected,
    required this.onToggle,
  });

  final String tripId;
  final List<Bag> bags;
  final List<PackingItem> items;
  final Set<String> selected;
  final void Function(String key) onToggle;

  @override
  Widget build(BuildContext context) {
    final hasUnassigned = items.any((i) => i.bagId == null);
    return SizedBox(
      height: 104,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        children: [
          for (final bag in bags) ...[
            Builder(builder: (context) {
              final inBag = items.where((i) => i.bagId == bag.id).toList();
              final w = computeBagWeight(bag, inBag);
              final over = bag.maxWeightGrams != null &&
                  w.complete &&
                  w.grams > bag.maxWeightGrams!;
              final caption =
                  '${Fmt.weightGrams(w.grams)}${w.complete ? '' : '+'}';
              return _BagFilterChip(
                icon: bag.type.icon,
                label: bag.name,
                caption: caption,
                selected: selected.contains(bag.id),
                over: over,
                onTap: () => onToggle(bag.id),
                onLongPress: () => showPackingBagSheet(context,
                    tripId: tripId, existing: bag),
              );
            }),
            const SizedBox(width: 12),
          ],
          if (hasUnassigned) ...[
            _BagFilterChip(
              icon: Icons.label_off_outlined,
              label: 'Senza borsa',
              selected: selected.contains(_kNoBag),
              onTap: () => onToggle(_kNoBag),
            ),
            const SizedBox(width: 12),
          ],
          _BagFilterChip(
            icon: Icons.add,
            label: 'Bagaglio',
            addStyle: true,
            selected: false,
            onTap: () => showPackingBagSheet(context, tripId: tripId),
          ),
        ],
      ),
    );
  }
}

class _BagFilterChip extends StatelessWidget {
  const _BagFilterChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.caption,
    this.over = false,
    this.addStyle = false,
    this.onLongPress,
  });

  final IconData icon;
  final String label;
  final String? caption;
  final bool selected;
  final bool over;
  final bool addStyle;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    final Color ring = over
        ? tokens.warning
        : selected
            ? tokens.accent
            : tokens.hairline;
    final Color fill = selected ? tokens.accent : scheme.surfaceContainerHigh;
    final Color fg = selected ? tokens.onAccent : tokens.accent;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 66,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: addStyle ? Colors.transparent : fill,
                shape: BoxShape.circle,
                border: Border.all(
                  color: ring,
                  width: selected ? 2.5 : 1.5,
                ),
              ),
              child: Icon(icon, color: addStyle ? tokens.accent : fg, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? tokens.accent : scheme.onSurface,
              ),
            ),
            if (caption != null)
              Text(
                caption!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: tokens.monoFont,
                  fontSize: 9.5,
                  color: over ? tokens.warning : scheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
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
    required this.selectedBags,
  });

  final String tripId;
  final List<PackingItem> items;
  final List<Bag> bags;
  final List<PackingCategory> categories;
  final String query;
  final Set<String> selectedBags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Iterable<PackingItem> result = items;
    if (query.isNotEmpty) {
      result = result.where((i) => i.name.toLowerCase().contains(query));
    }
    if (selectedBags.isNotEmpty) {
      result = result.where((i) =>
          (i.bagId != null && selectedBags.contains(i.bagId)) ||
          (i.bagId == null && selectedBags.contains(_kNoBag)));
    }
    final filtered = result.toList();

    if (filtered.isEmpty) {
      return const EmptyState(
        icon: Icons.filter_alt_off_outlined,
        title: 'Nessun oggetto',
        message: 'Nessun oggetto corrisponde ai filtri attivi.',
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
