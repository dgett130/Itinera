import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/amount_entry.dart';
import '../../core/enum_labels.dart';
import '../../core/enums.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
import '../../ui/widgets.dart';
import '../homewidget/widget_snapshot.dart';
import '../trip/trip_providers.dart';
import 'share_weights_editor.dart';
import 'transport_providers.dart';

/// Le categorie nell'ordine della spesa rapida: prima le quattro del widget.
const quickExpenseCategories = [
  CostCategory.food,
  CostCategory.activity,
  CostCategory.taxi,
  CostCategory.ticket,
  CostCategory.fuel,
  CostCategory.accommodation,
  CostCategory.parking,
  CostCategory.toll,
  CostCategory.rental,
  CostCategory.baggage,
  CostCategory.insurance,
  CostCategory.other,
];

const _widgetChannel = MethodChannel('itinera/widget');

/// Spesa rapida: categoria, importo dal tastierino e salva. Si apre dal widget
/// "Spesa rapida" della Home con la categoria gia' scelta (vedi FigCraft,
/// pagina N). Pagante, divisione e data partono da quelli predefiniti.
class QuickExpenseScreen extends ConsumerStatefulWidget {
  const QuickExpenseScreen({
    super.key,
    required this.tripId,
    this.category,
    this.pickCategory = false,
    this.fromWidget = false,
  });

  final String tripId;
  final CostCategory? category;

  /// Apre subito l'elenco di tutte le categorie ("Altro" sul widget).
  final bool pickCategory;

  /// Aperta dal widget: chiudendo si torna alla Home del telefono.
  final bool fromWidget;

  @override
  ConsumerState<QuickExpenseScreen> createState() => _QuickExpenseScreenState();
}

/// La spesa appena salvata, per la conferma e per annullarla.
typedef _Saved = ({String id, int cents, CostCategory category, String trip});

class _QuickExpenseScreenState extends ConsumerState<QuickExpenseScreen> {
  late String _tripId = widget.tripId;
  late CostCategory _category = widget.category ?? CostCategory.food;
  AmountEntry _amount = const AmountEntry();
  final _descCtrl = TextEditingController();
  final _chipKeys = {for (final c in quickExpenseCategories) c: GlobalKey()};

  // Scelte fatte a mano; null = quella predefinita.
  bool _payerSet = false;
  String? _payer;
  SplitMethod? _split;
  Map<String, double>? _weights;

  bool _rejected = false;
  bool _saving = false;
  _Saved? _saved;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _revealChip(animate: false);
      if (widget.pickCategory) _pickCategory();
    });
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  void _revealChip({bool animate = true}) {
    final ctx = _chipKeys[_category]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: animate ? Motion.of(context, Motion.standard) : Duration.zero,
      curve: Curves.easeOutCubic,
    );
  }

  void _setCategory(CostCategory c) {
    HapticFeedback.selectionClick();
    setState(() => _category = c);
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealChip());
  }

  void _press(String key) {
    final next = key == '⌫' ? _amount.backspace() : _amount.press(key);
    if (next == null) {
      HapticFeedback.heavyImpact();
      // L'oscillazione parte al passaggio da falso a vero: si riarma.
      setState(() => _rejected = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _rejected = true);
      });
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _amount = next;
      _rejected = false;
    });
  }

  String? _payerFor(List<Traveler> travelers) => _payerSet
      ? _payer
      : travelers.where((t) => t.isSelfUser).map((t) => t.id).firstOrNull;

  SplitMethod _splitFor(List<Traveler> travelers) =>
      _split ?? (travelers.length < 2 ? SplitMethod.none : SplitMethod.equal);

  Future<void> _save(Trip trip, List<Traveler> travelers) async {
    final cents = _amount.cents;
    if (cents <= 0 || _saving) return;
    setState(() => _saving = true);
    final desc = _descCtrl.text.trim();
    try {
      final id = await ref
          .read(transportRepositoryProvider)
          .addExpense(
            tripId: trip.id,
            category: _category,
            description: desc.isEmpty ? null : desc,
            amountCents: cents,
            payerId: _payerFor(travelers),
            splitMethod: _splitFor(travelers),
            weights: _splitFor(travelers) == SplitMethod.weighted
                ? ShareWeightsEditor.resolve(travelers, _weights)
                : null,
          );
      if (!mounted) return;
      unawaited(HapticFeedback.mediumImpact());
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() {
        _saved = (id: id, cents: cents, category: _category, trip: trip.name);
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Annulla la spesa appena salvata e torna al tastierino con gli stessi dati.
  Future<void> _undo() async {
    final saved = _saved;
    if (saved == null) return;
    await ref.read(transportRepositoryProvider).deleteExpense(saved.id);
    if (mounted) setState(() => _saved = null);
  }

  void _another() {
    setState(() {
      _saved = null;
      _amount = const AmountEntry();
      _descCtrl.clear();
    });
  }

  Future<void> _leave() async {
    if (widget.fromWidget) {
      // Si torna da dove si era partiti: la Home del telefono.
      try {
        await _widgetChannel.invokeMethod<void>('moveToBack');
      } on MissingPluginException {
        // Fuori da Android: si resta nell'app.
      }
      if (mounted) context.go('/');
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/trip/$_tripId/transport');
    }
  }

  void _switchTrip(String id) {
    if (id == _tripId) return;
    setState(() {
      _tripId = id;
      _payerSet = false;
      _payer = null;
      _split = null;
      _weights = null;
    });
  }

  Future<void> _pickTrip(List<Trip> trips) async {
    final id = await showCartolinaSheet<String>(
      context: context,
      builder: (context) => _TripPicker(trips: trips, selected: _tripId),
    );
    if (id != null) _switchTrip(id);
  }

  Future<void> _pickCategory() async {
    final c = await showCartolinaSheet<CostCategory>(
      context: context,
      builder: (context) => _CategoryPicker(selected: _category),
    );
    if (c != null) _setCategory(c);
  }

  @override
  Widget build(BuildContext context) {
    final trips = ref.watch(tripsProvider).value;
    if (trips == null) return const Scaffold(body: LoadingView());
    // Il viaggio del widget potrebbe non esserci piu': si ripiega sul
    // viaggio in corso o sul prossimo.
    final trip =
        trips.where((t) => t.id == _tripId).firstOrNull ??
        pickWidgetTrip(trips, DateTime.now());
    if (trip == null) {
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(trip: null, onClose: _leave, onPickTrip: null),
            const Expanded(
              child: EmptyState(
                icon: Icons.luggage,
                title: 'Nessun viaggio',
                message:
                    'Le spese si fissano su un viaggio: creane uno per '
                    'iniziare.',
              ),
            ),
          ],
        ),
      );
    }
    final travelers = ref.watch(travelersProvider(trip.id)).value ?? const [];
    final saved = _saved;
    return Scaffold(
      body: AnimatedSwitcher(
        duration: Motion.of(context, Motion.emphasis),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween(begin: 0.96, end: 1.0).animate(animation),
            child: child,
          ),
        ),
        child: saved != null
            ? _SavedView(
                key: ValueKey(saved.id),
                saved: saved,
                tripId: trip.id,
                onDone: _leave,
                onAnother: _another,
                onUndo: _undo,
              )
            : Column(
                key: const ValueKey('form'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(
                    trip: trip,
                    onClose: _leave,
                    onPickTrip: trips.length > 1
                        ? () => _pickTrip(trips)
                        : null,
                  ),
                  Expanded(child: _form(trip, travelers)),
                ],
              ),
      ),
    );
  }

  Widget _form(Trip trip, List<Traveler> travelers) {
    final texts = context.texts;
    final payerId = _payerFor(travelers);
    final payer = travelers.where((t) => t.id == payerId).firstOrNull;
    final split = _splitFor(travelers);
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      for (final c in quickExpenseCategories)
                        Padding(
                          key: _chipKeys[c],
                          padding: const EdgeInsets.only(right: 8),
                          child: _CategoryChip(
                            category: c,
                            selected: c == _category,
                            selectedColor: Cartolina.sole,
                            onTap: () => _setCategory(c),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ShakeOnTrue(
                  trigger: _rejected,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '€ ${_amount.display}',
                        style: texts.displayLarge?.copyWith(
                          fontSize: 60,
                          height: 1.1,
                          color: _amount.isEmpty
                              ? context.scheme.onSurfaceVariant.withValues(
                                  alpha: 0.5,
                                )
                              : context.scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  '${_category.label} · oggi',
                  textAlign: TextAlign.center,
                  style: texts.bodyMedium?.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _descCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Descrizione (facoltativa)',
                      hintText: 'Es. pranzo al porto',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MenuChip<String?>(
                        label: payer == null
                            ? 'Nessun pagante'
                            : 'Pagata da ${payer.isSelfUser ? 'Tu' : payer.name}',
                        items: {
                          for (final t in travelers)
                            t.id: t.isSelfUser ? '${t.name} (tu)' : t.name,
                          null: 'Nessuno',
                        },
                        selected: payerId,
                        onSelected: (id) => setState(() {
                          _payerSet = true;
                          _payer = id;
                        }),
                      ),
                      _MenuChip<SplitMethod>(
                        label: split.label,
                        items: {
                          for (final m in const [
                            SplitMethod.equal,
                            SplitMethod.weighted,
                            SplitMethod.none,
                          ])
                            m: m.label,
                        },
                        selected: split,
                        onSelected: (m) => setState(() => _split = m),
                      ),
                    ],
                  ),
                ),
                // Per quota: le quote di questa spesa, sotto le scelte.
                AnimatedSize(
                  duration: Motion.of(context, Motion.standard),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: split == SplitMethod.weighted && travelers.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                          child: ShareWeightsEditor(
                            travelers: travelers,
                            shares: ShareWeightsEditor.resolve(
                              travelers,
                              _weights,
                            ),
                            amountCents: _amount.cents,
                            payerId: payerId,
                            onChanged: (w) => setState(() => _weights = w),
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
                const Spacer(),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _Keypad(onKey: _press),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SafeArea(
                    top: false,
                    child: FilledButton(
                      onPressed: _amount.cents > 0 && !_saving
                          ? () => _save(trip, travelers)
                          : null,
                      child: const Text('Salva spesa'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Testata laguna compatta: chiudi, titolo e viaggio (toccabile se ce n'e'
/// piu' d'uno).
class _Header extends StatelessWidget {
  const _Header({
    required this.trip,
    required this.onClose,
    required this.onPickTrip,
  });

  final Trip? trip;
  final VoidCallback onClose;
  final VoidCallback? onPickTrip;

  @override
  Widget build(BuildContext context) {
    const style = ModuleStyle.costi;
    final texts = context.texts;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyleOn(style.background),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Cartolina.laguna,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 48,
                  child: Transform.translate(
                    offset: const Offset(-12, 0),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      color: style.foreground,
                      tooltip: 'Chiudi',
                      onPressed: onClose,
                    ),
                  ),
                ),
                Text(
                  'Spesa rapida',
                  style: texts.displaySmall?.copyWith(
                    fontSize: 30,
                    height: 1.08,
                    color: style.foreground,
                  ),
                ),
                if (trip != null) ...[
                  const SizedBox(height: 10),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: onPickTrip,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          14,
                          7,
                          onPickTrip == null ? 14 : 8,
                          7,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                trip!.name,
                                overflow: TextOverflow.ellipsis,
                                style: texts.labelLarge?.copyWith(
                                  color: Cartolina.inchiostro,
                                ),
                              ),
                            ),
                            if (onPickTrip != null)
                              const Icon(
                                Icons.arrow_drop_down,
                                size: 20,
                                color: Cartolina.inchiostro,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final CostCategory category;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(category.label),
      selected: selected,
      showCheckmark: false,
      selectedColor: selectedColor,
      backgroundColor: context.scheme.surfaceContainerLow,
      labelStyle: context.texts.labelLarge?.copyWith(
        color: selected ? Cartolina.inchiostro : context.scheme.onSurface,
      ),
      side: BorderSide(
        color: selected ? Colors.transparent : context.tokens.hairline,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onSelected: (_) => onTap(),
    );
  }
}

/// Pillola con freccia che apre un menu di scelte.
class _MenuChip<T> extends StatelessWidget {
  const _MenuChip({
    required this.label,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final Map<T, String> items;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    return Material(
      color: context.scheme.surfaceContainerLow,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () async {
          final box = context.findRenderObject()! as RenderBox;
          final overlay =
              Overlay.of(context).context.findRenderObject()! as RenderBox;
          final origin = box.localToGlobal(Offset.zero, ancestor: overlay);
          // Il menu restituisce un record: anche null e' una scelta valida.
          final picked = await showMenu<(T,)>(
            context: context,
            position: RelativeRect.fromLTRB(
              origin.dx,
              origin.dy + box.size.height + 4,
              overlay.size.width - origin.dx - box.size.width,
              0,
            ),
            items: [
              for (final e in items.entries)
                CheckedPopupMenuItem<(T,)>(
                  value: (e.key,),
                  checked: e.key == selected,
                  child: Text(e.value, overflow: TextOverflow.ellipsis),
                ),
            ],
          );
          if (picked != null) onSelected(picked.$1);
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: context.tokens.hairline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: context.texts.labelLarge),
              Icon(
                Icons.arrow_drop_down,
                size: 20,
                color: context.scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tastierino numerico: 1-9, virgola, 0 e cancella (tenuto premuto svuota).
class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKey});

  final ValueChanged<String> onKey;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    [',', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    // Sugli schermi bassi i tasti si accorciano.
    final keyHeight = MediaQuery.sizeOf(context).height < 720 ? 50.0 : 58.0;
    return Column(
      children: [
        for (final (i, row) in _rows.indexed) ...[
          if (i > 0) const SizedBox(height: 8),
          Row(
            children: [
              for (final (j, key) in row.indexed) ...[
                if (j > 0) const SizedBox(width: 8),
                Expanded(
                  child: _Key(
                    label: key,
                    height: keyHeight,
                    onTap: () => onKey(key),
                    onLongPress: key == '⌫'
                        ? () {
                            for (var n = 0; n < 12; n++) {
                              onKey('⌫');
                            }
                          }
                        : null,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    required this.label,
    required this.height,
    required this.onTap,
    this.onLongPress,
  });

  final String label;
  final double height;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    final on = context.scheme.onSurface;
    return Material(
      color: context.scheme.surfaceContainerLow,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: context.tokens.hairline),
          ),
          child: label == '⌫'
              ? Icon(Icons.backspace, color: on, semanticLabel: 'Cancella')
              : Text(
                  label,
                  style: context.texts.headlineSmall?.copyWith(
                    fontFamily: context.tokens.displayFont,
                    fontWeight: FontWeight.w700,
                    color: on,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Conferma: spunta che scatta, riepilogo e nuovo totale del viaggio.
class _SavedView extends ConsumerWidget {
  const _SavedView({
    super.key,
    required this.saved,
    required this.tripId,
    required this.onDone,
    required this.onAnother,
    required this.onUndo,
  });

  final _Saved saved;
  final String tripId;
  final VoidCallback onDone;
  final VoidCallback onAnother;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texts = context.texts;
    final expenses = ref.watch(expensesProvider(tripId)).value ?? const [];
    // Finche' la lista non si aggiorna, la spesa nuova si somma a mano.
    final listed = expenses.any((e) => e.id == saved.id);
    final total =
        expenses
            .where((e) => e.status == CostStatus.actual)
            .fold<int>(0, (a, e) => a + e.amountCents) +
        (listed ? 0 : saved.cents);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Motion.of(context, Motion.emphasis),
                    curve: Motion.pop,
                    builder: (context, t, child) =>
                        Transform.scale(scale: t, child: child),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Cartolina.laguna,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 64,
                        color: Cartolina.inchiostro,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Spesa salvata',
                    style: texts.displaySmall?.copyWith(fontSize: 30),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${saved.category.label} · '
                    '${Fmt.currencyCents(saved.cents)} · ${saved.trip}',
                    textAlign: TextAlign.center,
                    style: texts.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: (total - saved.cents).toDouble(),
                      end: total.toDouble(),
                    ),
                    duration: Motion.of(context, Motion.scene),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => Text(
                      'In questo viaggio hai speso '
                      '${Fmt.currencyCents(v.round())}',
                      textAlign: TextAlign.center,
                      style: texts.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(onPressed: onDone, child: const Text('Fatto')),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: onAnother,
              child: const Text("Aggiungi un'altra"),
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: onUndo,
              icon: const Icon(Icons.undo, size: 18),
              label: const Text('Annulla la spesa'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tutte le categorie, come pillole (laguna la scelta).
class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({required this.selected});

  final CostCategory selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHeader('Categoria'),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in quickExpenseCategories)
                  _CategoryChip(
                    category: c,
                    selected: c == selected,
                    selectedColor: Cartolina.laguna,
                    onTap: () => Navigator.pop(context, c),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Scelta del viaggio: prima quelli in corso o in arrivo.
class _TripPicker extends StatelessWidget {
  const _TripPicker({required this.trips, required this.selected});

  final List<Trip> trips;
  final String selected;

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    bool upcoming(Trip t) {
      final end = t.endDate ?? t.startDate;
      return end != null && !DateUtils.dateOnly(end).isBefore(today);
    }

    final sorted = [
      ...trips.where(upcoming),
      ...trips.where((t) => !upcoming(t)),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHeader('Viaggio'),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final t in sorted)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(t.name, overflow: TextOverflow.ellipsis),
                      subtitle: t.startDate == null
                          ? null
                          : Text(Fmt.date(t.startDate!)),
                      trailing: t.id == selected
                          ? Icon(Icons.check, color: context.tokens.accent)
                          : null,
                      onTap: () => Navigator.pop(context, t.id),
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
