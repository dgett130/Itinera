import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/enums.dart';
import '../../core/format.dart';
import '../../core/supabase_config.dart';
import '../../data/database.dart';
import '../../providers.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/widgets.dart';
import '../auth/auth_providers.dart';

/// Impostazioni: modalita', backup/ripristino, valori carburante.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        children: [
          SectionHeader('Account'),
          const _AccountCard(),
          if (settings != null) ...[
            SectionHeader('Modalità'),
            ItineraCard(
              padding: EdgeInsets.zero,
              child: _ModeSection(settings: settings),
            ),
          ],
          SectionHeader('Backup ed esporta'),
          ItineraCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.upload_file, color: context.tokens.accent),
                  title: const Text('Esporta backup'),
                  subtitle: const Text('Salva tutti i dati in un file JSON'),
                  onTap: () => _export(context, ref),
                ),
                Divider(height: 1, color: context.tokens.hairline),
                ListTile(
                  leading: Icon(Icons.download, color: context.tokens.accent),
                  title: const Text('Importa backup'),
                  subtitle:
                      const Text('Incolla un backup JSON (sostituisce tutto)'),
                  onTap: () => _import(context, ref),
                ),
              ],
            ),
          ),
          SectionHeader('Valori predefiniti carburante'),
          if (settings != null)
            ItineraCard(child: _FuelDefaults(settings: settings))
          else
            const ItineraCard(child: Center(child: LoadingView())),
          SectionHeader('Informazioni'),
          ItineraCard(
            child: Row(
              children: [
                Icon(Icons.info_outline, color: context.scheme.onSurfaceVariant),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Itinera', style: context.texts.titleSmall),
                      Text(
                        'Organizzatore viaggi · offline-first',
                        style: context.texts.bodySmall
                            ?.copyWith(color: context.scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Text('v1.0.0',
                    style: TextStyle(
                      fontFamily: context.tokens.monoFont,
                      fontSize: 12,
                      color: context.scheme.onSurfaceVariant,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final json = await ref.read(backupServiceProvider).exportJson();
      final dir = await getTemporaryDirectory();
      final stamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final file = File('${dir.path}/itinera_backup_$stamp.json');
      await file.writeAsString(json);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Backup Itinera',
          subject: 'Backup Itinera',
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Errore nell\'esportazione: $e')),
      );
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final content = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importa backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Incolla qui il contenuto del file di backup. '
              'Tutti i dati attuali verranno sostituiti.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: '{ "app": "itinera", ... }',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Importa'),
          ),
        ],
      ),
    );
    if (content == null || content.isEmpty || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(backupServiceProvider).importJson(content);
      messenger.showSnackBar(
        const SnackBar(content: Text('Backup importato correttamente')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Errore nell\'importazione: $e')),
      );
    }
  }
}

class _AccountCard extends ConsumerWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    if (!SupabaseConfig.hasCredentials || !supabaseReady) {
      return ItineraCard(
        child: Row(
          children: [
            Icon(Icons.cloud_off_outlined, color: context.scheme.onSurfaceVariant),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Account non disponibile su questo dispositivo.',
                style: context.texts.bodyMedium
                    ?.copyWith(color: context.scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
    }

    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return ItineraCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(Icons.account_circle_outlined, color: tokens.accent),
          title: const Text('Accedi o registrati'),
          subtitle: const Text('Sincronizza e condividi i tuoi viaggi'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/auth'),
        ),
      );
    }

    final profile = ref.watch(profileProvider).value;
    final name = (profile?.displayName?.isNotEmpty == true)
        ? profile!.displayName!
        : (user.email ?? 'Account');
    final initial = name.characters.first.toUpperCase();

    return ItineraCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: tokens.accent,
              foregroundColor: tokens.onAccent,
              child: Text(initial,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            title: Text(name),
            subtitle: user.email != null ? Text(user.email!) : null,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile'),
          ),
          Divider(height: 1, color: tokens.hairline),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Esci'),
            onTap: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
    );
  }
}

class _FuelDefaults extends ConsumerStatefulWidget {
  const _FuelDefaults({required this.settings});
  final AppSetting settings;

  @override
  ConsumerState<_FuelDefaults> createState() => _FuelDefaultsState();
}

class _FuelDefaultsState extends ConsumerState<_FuelDefaults> {
  late final TextEditingController _consumption;
  late final TextEditingController _price;

  @override
  void initState() {
    super.initState();
    _consumption = TextEditingController(
      text:
          widget.settings.defaultFuelConsumption.toString().replaceAll('.', ','),
    );
    _price = TextEditingController(
      text: (widget.settings.defaultFuelPriceCents / 100)
          .toStringAsFixed(2)
          .replaceAll('.', ','),
    );
  }

  @override
  void dispose() {
    _consumption.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final consumption = Fmt.parseDecimal(_consumption.text) ?? 6.5;
    final priceCents = Fmt.parseMoneyToCents(_price.text) ?? 185;
    final db = ref.read(databaseProvider);
    await (db.update(db.appSettings)..where((s) => s.id.equals(1))).write(
      AppSettingsCompanion(
        defaultFuelConsumption: Value(consumption),
        defaultFuelPriceCents: Value(priceCents),
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valori salvati')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _consumption,
                decoration:
                    const InputDecoration(labelText: 'Consumo (L/100km)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _price,
                decoration: const InputDecoration(labelText: 'Prezzo (EUR/L)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(onPressed: _save, child: const Text('Salva')),
        ),
      ],
    );
  }
}

class _ModeSection extends ConsumerWidget {
  const _ModeSection({required this.settings});
  final AppSetting settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final isRemote = settings.appMode == AppMode.remote;
    return Column(
      children: [
        ListTile(
          leading: Icon(
            isRemote ? Icons.cloud_done : Icons.phone_iphone,
            color: isRemote ? tokens.positive : tokens.accent,
          ),
          title: Text(isRemote ? 'Server (sincronizzata)' : 'Solo locale'),
          subtitle: Text(
            isRemote
                ? '${settings.serverUrl ?? '-'}'
                    '${settings.lastSyncAt != null ? '\nUltima sync: ${Fmt.date(settings.lastSyncAt!)}' : ''}'
                : 'I dati restano su questo dispositivo',
          ),
          isThreeLine: isRemote && settings.lastSyncAt != null,
        ),
        if (isRemote) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _sync(context, ref, push: false),
                    icon: const Icon(Icons.cloud_download),
                    label: const Text('Scarica'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _sync(context, ref, push: true),
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Carica'),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: tokens.hairline),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Disconnetti'),
            onTap: () async {
              await ref.read(settingsRepositoryProvider).clearRemoteSession();
              if (context.mounted) context.go('/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone_iphone),
            title: const Text('Passa alla modalità solo locale'),
            onTap: () async {
              await ref
                  .read(settingsRepositoryProvider)
                  .chooseMode(AppMode.local);
              if (context.mounted) context.go('/');
            },
          ),
        ] else
          ListTile(
            leading: Icon(Icons.cloud_sync, color: tokens.accent),
            title: const Text('Passa alla modalità server'),
            subtitle: const Text('Accedi e sincronizza con il tuo server'),
            onTap: () async {
              await ref
                  .read(settingsRepositoryProvider)
                  .chooseMode(AppMode.remote);
              if (context.mounted) context.go('/');
            },
          ),
      ],
    );
  }

  Future<void> _sync(BuildContext context, WidgetRef ref,
      {required bool push}) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final sync = ref.read(syncServiceProvider);
      final outcome = push ? await sync.push() : await sync.pull();
      messenger.showSnackBar(SnackBar(content: Text(outcome.message)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('$e')));
      final s = await ref.read(settingsRepositoryProvider).get();
      if (s.authToken == null) router.go('/');
    }
  }
}
