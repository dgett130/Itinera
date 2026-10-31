import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enum_labels.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
import '../../ui/widgets.dart';
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
    return _PackingBody(tripId: tripId);
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

/// Colore del sole che sale quando la valigia è pronta.
const Color _kReadySun = Color(0xFFFFE27A);

bool _isPacked(PackingItem i) => i.packedCount >= i.quantity;

/// Pronta: c'è almeno un oggetto e sono tutti dentro.
bool _isReady(List<PackingItem> items) =>
    items.isNotEmpty && items.every(_isPacked);

class _PackingBodyState extends ConsumerState<_PackingBody> {
  String _query = '';

  /// Bagagli selezionati come filtro (vuoto = mostra tutti). Può contenere
  /// [_kNoBag] per gli oggetti non assegnati a una borsa.
  final Set<String> _selectedBags = {};

  /// La valigia è appena diventata pronta: testata grande e sole alto. Resta
  /// finché l'utente è qui; aprendo una valigia già pronta non scatta.
  bool _celebrating = false;

  void _toggleBag(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      if (!_selectedBags.remove(key)) _selectedBags.add(key);
    });
  }

  /// Riconosce il passaggio a 100%. Una lista prima vuota non conta: è il
  /// caricamento o l'annullamento dell'unica eliminazione, non un traguardo.
  void _onItemsChanged(List<PackingItem>? before, List<PackingItem>? after) {
    if (before == null || after == null) return;
    final was = _isReady(before);
    final now = _isReady(after);
    if (!was && now && before.isNotEmpty) {
      setState(() => _celebrating = true);
      HapticFeedback.mediumImpact();
      showConfetti(context);
    } else if (!now && _celebrating) {
      setState(() => _celebrating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      packingItemsProvider(widget.tripId),
      (prev, next) => _onItemsChanged(prev?.value, next.value),
    );
    final items = ref.watch(packingItemsProvider(widget.tripId)).value;
    final bags = ref.watch(bagsProvider(widget.tripId)).value;
    final cats = ref.watch(packingCategoriesProvider).value;

    if (items == null || bags == null || cats == null) {
      return const Scaffold(body: _PackingLoading());
    }

    if (items.isEmpty) {
      return Scaffold(
        body: Column(
          children: [
            ModuleHeader(
              style: ModuleStyle.valigia,
              title: 'Valigia',
              actions: [_TemplateMenu(tripId: widget.tripId, canAddBag: true)],
            ),
            Expanded(child: _EmptyPacking(tripId: widget.tripId)),
          ],
        ),
      );
    }

    // Un filtro su un bagaglio che non c'è più nasconderebbe tutto, senza
    // modo di toglierlo.
    final hasUnassigned = items.any((i) => i.bagId == null);
    _selectedBags.removeWhere(
      (k) => k == _kNoBag ? !hasUnassigned : !bags.any((b) => b.id == k),
    );

    return Scaffold(
      floatingActionButton: CartolinaFab(
        label: 'Oggetto',
        onPressed: cats.isEmpty
            ? null
            : () => showPackingItemSheet(
                context,
                tripId: widget.tripId,
                categories: cats,
                bags: bags,
                fromFab: true,
              ),
      ),
      body: Column(
        children: [
          ModuleHeader(
            style: ModuleStyle.valigia,
            title: _isReady(items) ? 'Valigia pronta!' : 'Valigia',
            actions: [_TemplateMenu(tripId: widget.tripId)],
            child: _ProgressHeader(items: items, celebrating: _celebrating),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _EssentialBanner(items: items),
                  _BagFilterRow(
                    tripId: widget.tripId,
                    bags: bags,
                    items: items,
                    selected: _selectedBags,
                    onToggle: _toggleBag,
                  ),
                  const SizedBox(height: 12),
                  _SearchField(
                    onChanged: (v) =>
                        setState(() => _query = v.trim().toLowerCase()),
                  ),
                  _ItemList(
                    tripId: widget.tripId,
                    items: items,
                    bags: bags,
                    categories: cats,
                    query: _query,
                    selectedBags: _selectedBags,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Testata e righe che respirano mentre i dati arrivano.
class _PackingLoading extends StatelessWidget {
  const _PackingLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ModuleHeader(style: ModuleStyle.valigia, title: 'Valigia'),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < 4; i++) ...[
                const Skeleton(height: 48, radius: 16),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Percentuale, conteggio e barra dentro la testata. Quando la valigia diventa
/// pronta si allarga per far spazio al sole che sale.
class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.items, required this.celebrating});
  final List<PackingItem> items;
  final bool celebrating;

  @override
  Widget build(BuildContext context) {
    const ink = Cartolina.inchiostro;
    final texts = context.texts;
    final total = items.length;
    final packed = items.where(_isPacked).length;
    final ratio = total == 0 ? 0.0 : packed / total;
    final ready = _isReady(items);
    final note = texts.bodyMedium?.copyWith(
      color: ink,
      fontWeight: FontWeight.w500,
      height: 1.25,
    );
    final strong = note?.copyWith(fontWeight: FontWeight.w700);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -10,
          right: -8,
          bottom: 0,
          width: _RisingSun.size,
          child: _RisingSun(up: celebrating),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Grow(celebrating ? 76 : 0),
            Row(
              children: [
                CountUpText(
                  value: (ratio * 100).round(),
                  format: (v) => '${v.round()}%',
                  maxLines: 1,
                  style: texts.displaySmall?.copyWith(
                    fontSize: 60,
                    height: 1,
                    color: ink,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: ready
                        ? [
                            Text('$packed di $total', style: strong),
                            if (!celebrating && items.any((i) => i.isEssential))
                              Text('Essenziali tutti dentro', style: note),
                          ]
                        : [
                            Text('Pronti', style: note),
                            Text('$packed di $total', style: note),
                          ],
                  ),
                ),
              ],
            ),
            _Grow(celebrating ? 36 : 14),
            MeterBar(
              value: ratio,
              color: ink,
              track: ink.withValues(alpha: 0.22),
              height: 10,
            ),
            _Grow(celebrating ? 16 : 0),
          ],
        ),
      ],
    );
  }
}

/// Spazio verticale che cresce e cala morbido.
class _Grow extends StatelessWidget {
  const _Grow(this.height);
  final double height;

  @override
  Widget build(BuildContext context) {
    if (Motion.off(context)) return SizedBox(height: height);
    return AnimatedSize(
      duration: Motion.scene,
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: SizedBox(height: height),
    );
  }
}

/// Il sole chiaro della valigia pronta: sale dal fondo della testata e torna
/// giù se la valigia non è più pronta.
class _RisingSun extends StatelessWidget {
  const _RisingSun({required this.up});
  static const double size = 110;
  final bool up;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: up ? 1 : 0),
      duration: Motion.of(context, Motion.scene),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        if (t <= 0) return const SizedBox.shrink();
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.topCenter,
            minHeight: size,
            maxHeight: size,
            child: Transform.translate(
              offset: Offset(0, (1 - t) * 220),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: _kReadySun,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EssentialBanner extends StatelessWidget {
  const _EssentialBanner({required this.items});
  final List<PackingItem> items;

  @override
  Widget build(BuildContext context) {
    final missing = items.where((i) => i.isEssential && !_isPacked(i)).length;
    if (missing == 0) return const SizedBox.shrink();
    final tokens = context.tokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: tokens.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: tokens.warning, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              missing == 1
                  ? 'Manca 1 essenziale da preparare'
                  : 'Mancano $missing essenziali da preparare',
              style: context.texts.bodyMedium?.copyWith(
                color: tokens.warning,
                fontWeight: FontWeight.w500,
              ),
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
    final unassigned = items.where((i) => i.bagId == null).length;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final bag in bags) ...[
            Builder(
              builder: (context) {
                final inBag = items.where((i) => i.bagId == bag.id).toList();
                final w = computeBagWeight(bag, inBag);
                final over =
                    bag.maxWeightGrams != null &&
                    w.complete &&
                    w.grams > bag.maxWeightGrams!;
                final caption =
                    '${Fmt.weightGrams(w.grams)}${w.complete ? '' : '+'}';
                return _BagFilterChip(
                  key: ValueKey(bag.id),
                  icon: bag.type.icon,
                  label: bag.name,
                  caption: caption,
                  selected: selected.contains(bag.id),
                  over: over,
                  onTap: () => onToggle(bag.id),
                  onLongPress: () => showPackingBagSheet(
                    context,
                    tripId: tripId,
                    existing: bag,
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
          ],
          if (unassigned > 0) ...[
            _BagFilterChip(
              count: unassigned,
              label: 'Senza borsa',
              labelLines: 2,
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
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.count,
    this.caption,
    this.over = false,
    this.addStyle = false,
    this.labelLines = 1,
    this.onLongPress,
  });

  /// Nel cerchio: [icon], oppure il numero [count] ("Senza borsa").
  final IconData? icon;
  final int? count;
  final String label;
  final String? caption;
  final bool selected;
  final bool over;
  final bool addStyle;
  final int labelLines;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    final isBag = icon != null && !addStyle;

    // Bagaglio: sole pieno; oltre il limite: cerchio d'avviso. Selezionato: un
    // anello spesso che si legge su qualunque fondo.
    final Color fill = addStyle
        ? Colors.transparent
        : (isBag && !over)
        ? Cartolina.sole
        : scheme.surfaceContainerLow;
    final Color fg = over
        ? tokens.warning
        : (isBag ? Cartolina.inchiostro : scheme.onSurface);
    final Color ring = over
        ? tokens.warning
        : (selected || addStyle)
        ? scheme.onSurface
        : isBag
        ? Colors.transparent
        : tokens.hairline;
    final double ringWidth = selected ? 3 : (over ? 2 : 1.5);

    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 72,
          child: Column(
            children: [
              ShakeOnTrue(
                trigger: over,
                child: AnimatedContainer(
                  duration: Motion.of(context, Motion.fast),
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: fill,
                    shape: BoxShape.circle,
                    border: Border.all(color: ring, width: ringWidth),
                  ),
                  child: count != null
                      ? Text(
                          '$count',
                          maxLines: 1,
                          style: context.texts.titleMedium?.copyWith(color: fg),
                        )
                      : Icon(icon, color: fg, size: 26),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: labelLines,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.texts.bodySmall?.copyWith(
                  height: 1.15,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              if (caption != null)
                Text(
                  caption!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.bodySmall?.copyWith(
                    fontSize: 11,
                    fontWeight: over ? FontWeight.w600 : FontWeight.w400,
                    color: over ? tokens.warning : scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ricerca a pillola sopra la lista.
class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: color, width: width),
    );
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search, color: context.scheme.onSurfaceVariant),
        hintText: 'Cerca oggetto',
        border: border(tokens.hairline, 1),
        enabledBorder: border(tokens.hairline, 1),
        focusedBorder: border(tokens.accent, 2),
      ),
      onChanged: onChanged,
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
      result = result.where(
        (i) =>
            (i.bagId != null && selectedBags.contains(i.bagId)) ||
            (i.bagId == null && selectedBags.contains(_kNoBag)),
      );
    }
    final filtered = result.toList();

    if (filtered.isEmpty) {
      return const EmptyState(
        icon: Icons.filter_alt_off_outlined,
        title: 'Nessun oggetto',
        message: 'Nessun oggetto corrisponde ai filtri attivi.',
        color: Cartolina.sole,
        iconColor: Cartolina.inchiostro,
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

    // Indice della cascata: conta le righe attraverso le categorie.
    final sections = <Widget>[];
    var firstRow = 0;
    for (final catId in orderedCatIds) {
      sections.add(
        _CategorySection(
          key: ValueKey(catId),
          category: catById[catId],
          items: grouped[catId]!,
          firstRow: firstRow,
          bagById: bagById,
          categories: categories,
          bags: bags,
          tripId: tripId,
        ),
      );
      firstRow += grouped[catId]!.length;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: sections,
    );
  }
}

class _CategorySection extends ConsumerWidget {
  const _CategorySection({
    super.key,
    required this.category,
    required this.items,
    required this.firstRow,
    required this.bagById,
    required this.categories,
    required this.bags,
    required this.tripId,
  });

  final PackingCategory? category;
  final List<PackingItem> items;
  final int firstRow;
  final Map<String, Bag> bagById;
  final List<PackingCategory> categories;
  final List<Bag> bags;
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(packingRepositoryProvider);
    final packedInCat = items.where(_isPacked).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          category?.name ?? 'Varie',
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
          trailing: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              '$packedInCat/${items.length}',
              style: context.texts.titleSmall?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        ItineraCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < items.length; i++)
                StaggerIn(
                  key: ValueKey(items[i].id),
                  index: firstRow + i,
                  child: _PackingItemTile(
                    item: items[i],
                    bag: items[i].bagId == null
                        ? null
                        : bagById[items[i].bagId],
                    onToggle: () {
                      HapticFeedback.selectionClick();
                      repo.togglePacked(items[i]);
                    },
                    onEdit: () => showPackingItemSheet(
                      context,
                      tripId: tripId,
                      categories: categories,
                      bags: bags,
                      existing: items[i],
                    ),
                  ),
                ),
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
    final scheme = context.scheme;
    final packed = _isPacked(item);
    final name = item.quantity > 1
        ? '${item.name} ×${item.quantity}'
        : item.name;
    final details = [
      if (item.unitWeightGrams != null)
        Fmt.weightGrams(item.unitWeightGrams! * item.quantity),
      if (bag != null) bag!.name,
    ].join(' · ');
    final base = context.texts.bodyLarge ?? const TextStyle();

    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, right: 14),
        child: Row(
          children: [
            Semantics(
              button: true,
              checked: packed,
              label: name,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onToggle,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(child: CheckDot(checked: packed)),
                ),
              ),
            ),
            const SizedBox(width: 4),
            if (item.isEssential)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.star, size: 18, color: Cartolina.sole),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: AnimatedDefaultTextStyle(
                  duration: Motion.of(context, Motion.fast),
                  style: base.copyWith(
                    color: packed ? scheme.onSurfaceVariant : scheme.onSurface,
                    decoration: packed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: scheme.onSurfaceVariant,
                  ),
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            if (details.isNotEmpty) ...[
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 130),
                child: Text(
                  details,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
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
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: EmptyState(
            icon: Icons.luggage,
            color: Cartolina.sole,
            iconColor: Cartolina.inchiostro,
            title: 'Valigia vuota',
            message: 'Aggiungi il primo oggetto o parti da un modello pronto.',
            action: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: cats.isEmpty
                        ? null
                        : () => showPackingItemSheet(
                            context,
                            tripId: tripId,
                            categories: cats,
                            bags: bags,
                          ),
                    child: const Text('Aggiungi oggetto'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      textStyle: TextStyle(
                        fontFamily: context.tokens.displayFont,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () => _showTemplatePicker(context, ref, tripId),
                    child: const Text('Applica un modello'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Menu della testata: modelli e, a valigia vuota (quando la riga dei bagagli
/// non si vede), l'aggiunta di un bagaglio.
class _TemplateMenu extends ConsumerWidget {
  const _TemplateMenu({required this.tripId, this.canAddBag = false});
  final String tripId;
  final bool canAddBag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      tooltip: 'Altre azioni',
      icon: const Icon(Icons.more_vert),
      iconColor: Cartolina.inchiostro,
      onSelected: (value) async {
        if (value == 'apply') {
          await _showTemplatePicker(context, ref, tripId);
        } else if (value == 'save') {
          await _saveAsTemplate(context, ref, tripId);
        } else if (value == 'bag') {
          await showPackingBagSheet(context, tripId: tripId);
        }
      },
      itemBuilder: (context) => [
        if (canAddBag)
          const PopupMenuItem(
            value: 'bag',
            child: _MenuRow(Icons.add, 'Aggiungi bagaglio'),
          ),
        const PopupMenuItem(
          value: 'apply',
          child: _MenuRow(Icons.download, 'Applica un modello'),
        ),
        const PopupMenuItem(
          value: 'save',
          child: _MenuRow(Icons.upload, 'Salva come modello'),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: context.scheme.onSurface),
        const SizedBox(width: 12),
        Flexible(child: Text(label)),
      ],
    );
  }
}

Future<void> _showTemplatePicker(
  BuildContext context,
  WidgetRef ref,
  String tripId,
) async {
  final templates = await ref
      .read(packingRepositoryProvider)
      .watchTemplates()
      .first;
  if (!context.mounted) return;
  final selected = await showCartolinaSheet<String>(
    context: context,
    builder: (context) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHeader('Scegli un modello'),
            const SizedBox(height: 8),
            Text(
              'Aggiunge gli oggetti del modello alla valigia.',
              style: context.texts.bodyMedium?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: templates.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) => StaggerIn(
                  index: i,
                  child: _TemplateTile(
                    template: templates[i],
                    index: i,
                    onTap: () => Navigator.pop(context, templates[i].id),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  if (selected == null || !context.mounted) return;
  final count = await ref
      .read(packingRepositoryProvider)
      .applyTemplate(tripId, selected);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          count == 1
              ? '1 oggetto aggiunto dal modello'
              : '$count oggetti aggiunti dal modello',
        ),
      ),
    );
  }
}

/// Riga del foglio modelli: i tuoi hanno la stella su cobalto, gli altri
/// alternano i colori di Cartolina.
class _TemplateTile extends StatelessWidget {
  const _TemplateTile({
    required this.template,
    required this.index,
    required this.onTap,
  });

  final PackingTemplate template;
  final int index;
  final VoidCallback onTap;

  static const _colors = [Cartolina.sole, Cartolina.laguna, Cartolina.corallo];

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final mine = !template.isBuiltIn;
    final note = template.description ?? (mine ? 'Salvato da te' : null);
    return ItineraCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          mine
              ? const IconTile(
                  Icons.star,
                  color: Cartolina.cobalto,
                  iconColor: Colors.white,
                  size: 44,
                )
              : IconTile(
                  Icons.luggage,
                  color: _colors[index % _colors.length],
                  size: 44,
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(template.name, style: context.texts.titleMedium),
                if (note != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    note,
                    style: context.texts.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: scheme.onSurface),
        ],
      ),
    );
  }
}

Future<void> _saveAsTemplate(
  BuildContext context,
  WidgetRef ref,
  String tripId,
) async {
  final controller = TextEditingController();
  final name = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Salva come modello'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Potrai riusare questa valigia nei prossimi viaggi.',
            style: context.texts.bodyMedium?.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nome del modello'),
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: context.scheme.onSurface,
          ),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Modello "$name" salvato')));
  }
}
