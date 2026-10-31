import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
import '../../ui/widgets.dart';
import 'bacheca_providers.dart';
import 'file_preview_screen.dart';

/// Modulo Bacheca: file/documenti condivisi del viaggio (biglietti, programmi…).
///
/// I metadati vivono in locale (consultabili offline); i byte stanno su
/// Supabase Storage e richiedono la rete per caricamento/apertura.
class BachecaScreen extends ConsumerStatefulWidget {
  const BachecaScreen({super.key, required this.tripId});
  final String tripId;

  @override
  ConsumerState<BachecaScreen> createState() => _BachecaScreenState();
}

class _BachecaScreenState extends ConsumerState<BachecaScreen> {
  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.watch(bachecaControllerProvider);
    final filesAsync = ref.watch(tripFilesProvider(widget.tripId));
    final style = ModuleStyle.bacheca(context);
    final count = filesAsync.value?.length ?? 0;

    return Scaffold(
      floatingActionButton: controller.isReady && count > 0
          ? CartolinaFab(
              label: l10n.bachecaAdd,
              onPressed: _uploading ? null : _onUpload,
            )
          : null,
      body: Column(
        children: [
          ModuleHeader(
            style: style,
            title: l10n.bachecaTitle,
            note: !controller.isReady || count == 0
                ? null
                : count == 1
                ? '1 file condiviso con il gruppo'
                : '$count file condivisi con il gruppo',
          ),
          Expanded(
            child: filesAsync.when(
              loading: () => const _FilesSkeleton(),
              error: (e, _) => ErrorView(e),
              data: (files) {
                if (!controller.isReady) {
                  return EmptyState(
                    icon: Icons.person,
                    color: style.background,
                    iconColor: style.foreground,
                    title: l10n.bachecaNoAccountTitle,
                    message: l10n.bachecaNoAccountMessage,
                    action: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _onLogin,
                        child: const Text('Accedi'),
                      ),
                    ),
                  );
                }
                if (files.isEmpty && !_uploading) {
                  return EmptyState(
                    icon: Icons.description,
                    color: style.background,
                    iconColor: style.foreground,
                    title: l10n.bachecaEmptyTitle,
                    message: l10n.bachecaEmptyMessage,
                    action: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _onUpload,
                        child: Text(l10n.bachecaAdd),
                      ),
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_uploading) ...[
                        const _UploadTile(),
                        const SizedBox(height: 12),
                      ],
                      for (var i = 0; i < files.length; i++) ...[
                        StaggerIn(
                          key: ValueKey(files[i].id),
                          index: i,
                          child: _FileTile(
                            file: files[i],
                            onOpen: () => _onOpen(files[i]),
                            onDelete: () => _onDelete(files[i]),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Al ritorno dall'accesso la bacheca riflette il nuovo stato dell'account.
  Future<void> _onLogin() async {
    await context.push('/auth');
    if (mounted) setState(() {});
  }

  Future<void> _onUpload() async {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(bachecaControllerProvider);
    setState(() => _uploading = true);
    try {
      final res = await controller.pickAndUpload(widget.tripId);
      if (!mounted) return;
      switch (res.outcome) {
        case UploadOutcome.added:
          _snack(l10n.bachecaUploaded);
        case UploadOutcome.tooBig:
          _snack(l10n.bachecaTooBig);
        case UploadOutcome.noAccount:
          _snack(l10n.bachecaNoAccountMessage);
        case UploadOutcome.cancelled:
          break;
      }
    } catch (e) {
      if (mounted) _snack(l10n.bachecaUploadError);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _onOpen(TripFile file) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => FilePreviewScreen(file: file)));
  }

  Future<void> _onDelete(TripFile file) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        final tokens = context.tokens;
        final dark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          title: Text(l10n.commonDelete),
          content: Text(l10n.bachecaDeleteConfirm(file.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                foregroundColor: context.scheme.onSurface,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: tokens.warning,
                foregroundColor: dark ? Cartolina.inchiostro : Colors.white,
              ),
              child: Text(l10n.commonDelete),
            ),
          ],
        );
      },
    );
    if (ok != true) return;
    try {
      await ref.read(bachecaControllerProvider).delete(file);
      if (mounted) _snack(l10n.bachecaDeleted);
    } catch (e) {
      if (mounted) _snack(l10n.bachecaDeleteError);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _FileTile extends StatelessWidget {
  const _FileTile({
    required this.file,
    required this.onOpen,
    required this.onDelete,
  });

  final TripFile file;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final scheme = context.scheme;
    return ItineraCard(
      onTap: onOpen,
      padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
      child: Row(
        children: [
          IconTile(_iconFor(file.mimeType), color: _colorFor(), size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  _subtitle(),
                  style: context.texts.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              if (v == 'open') onOpen();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'open',
                child: Row(
                  children: [
                    const Icon(Icons.open_in_new, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.bachecaOpen),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: tokens.warning),
                    const SizedBox(width: 12),
                    Text(
                      l10n.commonDelete,
                      style: TextStyle(color: tokens.warning),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _colorFor() {
    final mime = file.mimeType;
    if (mime == 'application/pdf') return Cartolina.corallo;
    if (mime != null && mime.startsWith('image/')) return Cartolina.laguna;
    return Cartolina.sole;
  }

  String _subtitle() {
    final parts = <String>[];
    final size = file.sizeBytes;
    if (size != null && size > 0) parts.add(Fmt.fileSize(size));
    parts.add(Fmt.date(file.createdAt));
    return parts.join(' · ');
  }

  IconData _iconFor(String? mime) {
    if (mime == null) return Icons.description;
    if (mime.startsWith('image/')) return Icons.image;
    if (mime == 'application/pdf') return Icons.description;
    if (mime.contains('word') || mime.contains('document')) {
      return Icons.description;
    }
    if (mime.contains('sheet') || mime.contains('excel')) {
      return Icons.table_chart;
    }
    if (mime.contains('presentation') || mime.contains('powerpoint')) {
      return Icons.slideshow;
    }
    if (mime.contains('zip')) return Icons.folder_zip;
    if (mime.startsWith('text/')) return Icons.article;
    return Icons.description;
  }
}

/// Riga del file in caricamento. Il servizio non espone la percentuale né il
/// nome del file prima della fine: la barra scorre senza un valore.
class _UploadTile extends StatelessWidget {
  const _UploadTile();

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return ItineraCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const IconTile(
                Icons.upload_file,
                color: Cartolina.laguna,
                size: 44,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Caricamento del file…',
                  style: context.texts.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              // Con le animazioni ridotte la barra resta ferma.
              value: Motion.off(context) ? 0.5 : null,
              minHeight: 6,
              color: Cartolina.laguna,
              backgroundColor: context.tokens.hairline,
              semanticsLabel: 'Caricamento del file',
              borderRadius: BorderRadius.circular(6),
              stopIndicatorColor: scheme.surface.withValues(alpha: 0),
            ),
          ),
        ],
      ),
    );
  }
}

/// Segnaposto mentre arrivano i file.
class _FilesSkeleton extends StatelessWidget {
  const _FilesSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          Skeleton(height: 72, radius: 20),
          SizedBox(height: 12),
          Skeleton(height: 72, radius: 20),
          SizedBox(height: 12),
          Skeleton(height: 72, radius: 20),
        ],
      ),
    );
  }
}
