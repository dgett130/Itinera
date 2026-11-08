import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/format.dart';
import '../../core/supabase_config.dart';
import '../../data/database.dart';
import '../../providers.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
import '../../ui/widgets.dart';
import '../weather/weather_providers.dart';
import '../auth/auth_providers.dart';
import '../notifications/notifications_providers.dart';
import 'theme_controller.dart';

/// Impostazioni: modalità, backup/ripristino, valori carburante.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    final hasAccount = SupabaseConfig.hasCredentials && supabaseReady;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PlainHeader(title: 'Impostazioni'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Section('Account', first: true),
                  const StaggerIn(child: _AccountCard()),
                  const _Section('Aspetto'),
                  const StaggerIn(index: 1, child: _ThemeSelector()),
                  const SizedBox(height: 12),
                  const StaggerIn(index: 1, child: _PosterWeatherSwitch()),
                  if (hasAccount) ...[
                    const _Section('Notifiche'),
                    const StaggerIn(index: 2, child: _NotificationsSettings()),
                  ],
                  const _Section('Percorsi e avvisi'),
                  StaggerIn(
                    index: 3,
                    child: _NavCard(
                      icon: Icons.route,
                      color: Cartolina.corallo,
                      title: 'Avvisi sui percorsi',
                      onTap: () => context.push('/settings/route-warnings'),
                    ),
                  ),
                  const _Section('Backup ed esporta'),
                  StaggerIn(
                    index: 4,
                    child: _NavCard(
                      icon: Icons.file_upload,
                      color: Cartolina.laguna,
                      title: 'Esporta backup',
                      onTap: () => _export(context, ref),
                    ),
                  ),
                  const SizedBox(height: 12),
                  StaggerIn(
                    index: 5,
                    child: _NavCard(
                      icon: Icons.file_download,
                      color: Cartolina.laguna,
                      title: 'Importa backup',
                      onTap: () => _import(context, ref),
                    ),
                  ),
                  const _Section('Valori predefiniti carburante'),
                  if (settings != null)
                    _FuelDefaults(settings: settings)
                  else
                    const Skeleton(height: 56, radius: 16),
                  const _Section('Informazioni'),
                  ItineraCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Itinera', style: context.texts.titleMedium),
                              Text(
                                'Organizzatore viaggi · offline-first',
                                style: context.texts.bodySmall?.copyWith(
                                  color: context.scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        MonoTag('v2.0.0', background: context.tokens.hairline),
                      ],
                    ),
                  ),
                ],
              ),
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
    final warning = context.tokens.warning;
    final content = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importa backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Incolla qui il contenuto del file di backup. '
              'Tutti i dati attuali verranno sostituiti.',
              style: context.texts.bodyMedium?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              minLines: 1,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Contenuto del backup',
                hintText: '{ "app": "itinera", ... }',
              ),
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
            style: FilledButton.styleFrom(backgroundColor: warning),
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

/// Titolo di sezione della pagina.
class _Section extends StatelessWidget {
  const _Section(this.title, {this.first = false});

  final String title;
  final bool first;

  @override
  Widget build(BuildContext context) {
    return SectionHeader(
      title,
      padding: EdgeInsets.fromLTRB(0, first ? 4 : 18, 0, 10),
    );
  }
}

/// Riga di navigazione: tessera con icona, titolo e freccia.
class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
    this.iconColor = Cartolina.inchiostro,
  });

  final IconData icon;
  final Color color;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ItineraCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          IconTile(icon, color: color, iconColor: iconColor, size: 40),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: context.texts.titleMedium)),
          Icon(Icons.chevron_right, color: context.scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _NotificationsSettings extends ConsumerWidget {
  const _NotificationsSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider).value ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NavCard(
          icon: Icons.notifications,
          color: Cartolina.corallo,
          title: 'Preferenze notifiche',
          onTap: () => context.push('/settings/notifications'),
        ),
        if (isAdmin) ...[
          const SizedBox(height: 12),
          _NavCard(
            icon: Icons.send,
            color: Cartolina.cobalto,
            iconColor: Colors.white,
            title: 'Invia messaggio di sistema',
            onTap: () => context.push('/admin/message'),
          ),
        ],
      ],
    );
  }
}

class _AccountCard extends ConsumerWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!SupabaseConfig.hasCredentials || !supabaseReady) {
      return ItineraCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              Icons.cloud_off_outlined,
              color: context.scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Account non disponibile su questo dispositivo.',
                style: context.texts.bodyMedium?.copyWith(
                  color: context.scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return _AccountRow(
        leading: const IconTile(
          Icons.person,
          color: Cartolina.sole,
          round: true,
          size: 44,
        ),
        title: 'Accedi o registrati',
        subtitle: 'Sincronizza e condividi i tuoi viaggi',
        onTap: () => context.push('/auth'),
      );
    }

    final profile = ref.watch(profileProvider).value;
    final name = (profile?.displayName?.isNotEmpty == true)
        ? profile!.displayName!
        : (user.email ?? 'Account');
    final avatar = InitialAvatar(name, color: Cartolina.sole);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AccountRow(
          leading: profile?.avatarUrl != null
              ? ClipOval(
                  child: Image.network(
                    profile!.avatarUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => avatar,
                  ),
                )
              : avatar,
          title: name,
          subtitle: user.email != name ? user.email : null,
          onTap: () => context.push('/profile'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(46),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          icon: const Icon(Icons.logout),
          label: const Text('Esci'),
          onPressed: () async {
            await ref.read(authServiceProvider).signOut();
            if (context.mounted) context.go('/');
          },
        ),
      ],
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.leading,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ItineraCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.titleMedium,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.bodySmall?.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: context.scheme.onSurfaceVariant),
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
      text: widget.settings.defaultFuelConsumption.toString().replaceAll(
        '.',
        ',',
      ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Valori salvati')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _consumption,
                decoration: const InputDecoration(
                  labelText: 'Consumo (L/100km)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _price,
                decoration: const InputDecoration(labelText: 'Prezzo (€/L)'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(46)),
          onPressed: _save,
          child: const Text('Salva'),
        ),
      ],
    );
  }
}

/// Selettore del tema dell'app: Sistema / Chiaro / Scuro.
class _ThemeSelector extends ConsumerWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PillSelector<ThemeMode>(
      items: const {
        ThemeMode.system: 'Sistema',
        ThemeMode.light: 'Chiaro',
        ThemeMode.dark: 'Scuro',
      },
      selected: ref.watch(themeModeProvider),
      onChanged: (m) => ref.read(themeModeProvider.notifier).setMode(m),
    );
  }
}

/// "Meteo sul poster": il cielo del poster segue il meteo della destinazione.
class _PosterWeatherSwitch extends ConsumerWidget {
  const _PosterWeatherSwitch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(posterWeatherProvider);
    return ItineraCard(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      onTap: () => ref.read(posterWeatherProvider.notifier).set(!on),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Meteo sul poster', style: context.texts.titleMedium),
                const SizedBox(height: 2),
                Text(
                  'Il cielo del poster segue il meteo della destinazione '
                  '(Open-Meteo, solo con la rete). Spento resta l\'ora del giorno.',
                  style: context.texts.bodySmall?.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: on,
            onChanged: (v) => ref.read(posterWeatherProvider.notifier).set(v),
          ),
        ],
      ),
    );
  }
}
