import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../core/enums.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/widgets.dart';
import '../trip/trip_providers.dart';
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
    final trip = ref.watch(tripProvider(widget.tripId)).value;
    final style = trip == null
        ? TripStyle.atlante
        : ItineraTheme.effectiveStyle(trip);
    return TripThemeScope(style: style, child: _buildBody());
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context);
    final controller = ref.watch(bachecaControllerProvider);
    final filesAsync = ref.watch(tripFilesProvider(widget.tripId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bachecaTitle)),
      floatingActionButton: controller.isReady
          ? FloatingActionButton.extended(
              onPressed: _uploading ? null : _onUpload,
              icon: _uploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file_outlined),
              label: Text(l10n.bachecaAdd),
            )
          : null,
      body: filesAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(e),
        data: (files) {
          if (!controller.isReady) {
            return EmptyState(
              icon: Icons.cloud_off_outlined,
              title: l10n.bachecaNoAccountTitle,
              message: l10n.bachecaNoAccountMessage,
            );
          }
          if (files.isEmpty) {
            return EmptyState(
              icon: Icons.folder_open_outlined,
              title: l10n.bachecaEmptyTitle,
              message: l10n.bachecaEmptyMessage,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            itemCount: files.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _FileTile(
              file: files[i],
              onOpen: () => _onOpen(files[i]),
              onDelete: () => _onDelete(files[i]),
            ),
          );
        },
      ),
    );
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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FilePreviewScreen(file: file)),
    );
  }

  Future<void> _onDelete(TripFile file) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.commonDelete),
        content: Text(l10n.bachecaDeleteConfirm(file.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
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
      accentEdge: tokens.accent,
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tokens.accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_iconFor(file.mimeType), color: tokens.accent),
          ),
          const SizedBox(width: 14),
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
              PopupMenuItem(value: 'open', child: Text(l10n.bachecaOpen)),
              PopupMenuItem(value: 'delete', child: Text(l10n.commonDelete)),
            ],
          ),
        ],
      ),
    );
  }

  String _subtitle() {
    final parts = <String>[];
    final size = file.sizeBytes;
    if (size != null && size > 0) parts.add(Fmt.fileSize(size));
    parts.add(Fmt.date(file.createdAt));
    return parts.join(' · ');
  }

  IconData _iconFor(String? mime) {
    if (mime == null) return Icons.insert_drive_file_outlined;
    if (mime.startsWith('image/')) return Icons.image_outlined;
    if (mime == 'application/pdf') return Icons.picture_as_pdf_outlined;
    if (mime.contains('word') || mime.contains('document')) {
      return Icons.description_outlined;
    }
    if (mime.contains('sheet') || mime.contains('excel')) {
      return Icons.table_chart_outlined;
    }
    if (mime.contains('presentation') || mime.contains('powerpoint')) {
      return Icons.slideshow_outlined;
    }
    if (mime.contains('zip')) return Icons.folder_zip_outlined;
    if (mime.startsWith('text/')) return Icons.article_outlined;
    return Icons.insert_drive_file_outlined;
  }
}
