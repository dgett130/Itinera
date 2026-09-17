import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/format.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';
import 'bacheca_providers.dart';

/// Anteprima in-app di un file della bacheca: le immagini e i PDF si vedono
/// (con zoom), tutti i file si possono scaricare sul dispositivo o condividere.
/// Niente browser.
class FilePreviewScreen extends ConsumerStatefulWidget {
  const FilePreviewScreen({super.key, required this.file});
  final TripFile file;

  @override
  ConsumerState<FilePreviewScreen> createState() => _FilePreviewScreenState();
}

class _FilePreviewScreenState extends ConsumerState<FilePreviewScreen> {
  String? _url;
  Uint8List? _bytes; // scaricati per l'anteprima PDF e per download/condivisione
  Object? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool get _isImage {
    final m = widget.file.mimeType;
    if (m != null && m.startsWith('image/')) return true;
    final n = widget.file.name.toLowerCase();
    return n.endsWith('.jpg') ||
        n.endsWith('.jpeg') ||
        n.endsWith('.png') ||
        n.endsWith('.gif') ||
        n.endsWith('.webp') ||
        n.endsWith('.heic');
  }

  bool get _isPdf =>
      widget.file.mimeType == 'application/pdf' ||
      widget.file.name.toLowerCase().endsWith('.pdf');

  Future<void> _load() async {
    try {
      final url = await ref
          .read(bachecaControllerProvider)
          .signedUrl(widget.file);
      if (!mounted) return;
      setState(() => _url = url);
      // I PDF si mostrano dai byte: li scarico subito.
      if (_isPdf) await _ensureBytes();
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<Uint8List?> _ensureBytes() async {
    if (_bytes != null) return _bytes;
    final url = _url;
    if (url == null) return null;
    final res = await http.get(Uri.parse(url));
    if (res.statusCode >= 400) throw Exception('HTTP ${res.statusCode}');
    if (mounted) setState(() => _bytes = res.bodyBytes);
    return res.bodyBytes;
  }

  /// Salva il file sul dispositivo (dialog di sistema "Salva con nome").
  Future<void> _download() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final bytes = await _ensureBytes();
      if (bytes == null) return;
      final saved = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(data: bytes, fileName: widget.file.name),
      );
      if (saved != null && mounted) _snack(l10n.bachecaDownloaded);
    } catch (e) {
      if (mounted) _snack(l10n.bachecaDownloadError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Condivide il file con un'altra app (foglio di condivisione).
  Future<void> _share() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final bytes = await _ensureBytes();
      if (bytes == null) return;
      final dir = await getTemporaryDirectory();
      final safe = widget.file.name.replaceAll(RegExp(r'[^\w\-. ]'), '_');
      final f = File('${dir.path}/$safe');
      await f.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(f.path)], subject: widget.file.name),
      );
    } catch (e) {
      if (mounted) _snack(l10n.bachecaDownloadError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openExternal() async {
    final url = _url;
    if (url == null) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ready = _url != null && !_busy;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined),
            tooltip: l10n.bachecaDownload,
            onPressed: ready ? _download : null,
          ),
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: l10n.bachecaShare,
            onPressed: ready ? _share : null,
          ),
        ],
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_error != null) return ErrorView(_error!);
    if (_url == null) return const LoadingView();

    if (_isImage) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Image.network(
            _url!,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : const LoadingView(),
            errorBuilder: (context, error, _) => ErrorView(error),
          ),
        ),
      );
    }

    if (_isPdf) {
      final bytes = _bytes;
      if (bytes == null) return const LoadingView();
      return PDFView(
        pdfData: bytes,
        swipeHorizontal: false,
        fitPolicy: FitPolicy.WIDTH,
      );
    }

    // Tipo non visualizzabile: scarica o apri esternamente.
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmptyState(
              icon: Icons.insert_drive_file_outlined,
              title: widget.file.name,
              message: widget.file.sizeBytes != null
                  ? Fmt.fileSize(widget.file.sizeBytes!)
                  : null,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _busy ? null : _download,
              icon: const Icon(Icons.download_outlined),
              label: Text(l10n.bachecaDownload),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _openExternal,
              icon: const Icon(Icons.open_in_new),
              label: Text(l10n.bachecaOpenExternal),
            ),
          ],
        ),
      ),
    );
  }
}
