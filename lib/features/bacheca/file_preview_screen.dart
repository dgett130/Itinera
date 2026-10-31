import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
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
  Uint8List?
  _bytes; // scaricati per l'anteprima PDF e per download/condivisione
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

  /// Scarica e condividi, nel colore della barra in cui stanno.
  List<Widget> _actions(AppLocalizations l10n, {Color? color}) {
    final ready = _url != null && !_busy;
    return [
      IconButton(
        icon: _busy
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            : const Icon(Icons.download),
        color: color,
        disabledColor: color?.withValues(alpha: 0.4),
        tooltip: l10n.bachecaDownload,
        onPressed: ready ? _download : null,
      ),
      IconButton(
        icon: const Icon(Icons.share),
        color: color,
        disabledColor: color?.withValues(alpha: 0.4),
        tooltip: l10n.bachecaShare,
        onPressed: ready ? _share : null,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewer = _error == null && (_isImage || _isPdf);
    if (!viewer) {
      return Scaffold(
        body: Column(
          children: [
            PlainHeader(
              title: widget.file.name,
              size: 28,
              actions: _actions(l10n),
            ),
            Expanded(
              child: _error != null ? ErrorView(_error!) : _buildOther(l10n),
            ),
          ],
        ),
      );
    }

    // Immagini e PDF stanno su un fondo scuro, in entrambi i temi.
    final dark = Theme.of(context).brightness == Brightness.dark;
    final Color background = _isImage || dark
        ? Colors.black
        : const Color(0xFF20255A);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        titleTextStyle: context.texts.titleMedium?.copyWith(
          color: Colors.white,
        ),
        title: Text(widget.file.name, overflow: TextOverflow.ellipsis),
        actions: _actions(l10n, color: Colors.white),
      ),
      body: _isImage ? _buildImage() : _buildPdf(),
    );
  }

  Widget _buildImage() {
    if (_url == null) return const _ImageSkeleton();
    return Center(
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 5,
        child: Image.network(
          _url!,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : const _ImageSkeleton(),
          // Sul nero i testi dell'errore restano chiari anche in tema chiaro.
          errorBuilder: (context, error, _) => Theme(
            data: ItineraTheme.brand(Brightness.dark),
            child: ErrorView(error),
          ),
        ),
      ),
    );
  }

  Widget _buildPdf() {
    final bytes = _bytes;
    if (_url == null || bytes == null) return const _PdfSkeleton();
    return PDFView(
      pdfData: bytes,
      swipeHorizontal: false,
      fitPolicy: FitPolicy.WIDTH,
    );
  }

  /// Tipo non visualizzabile: scarica o apri esternamente.
  Widget _buildOther(AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: EmptyState(
            icon: Icons.description,
            color: Cartolina.sole,
            iconColor: Cartolina.inchiostro,
            title: widget.file.name,
            message: widget.file.sizeBytes != null
                ? Fmt.fileSize(widget.file.sizeBytes!)
                : null,
            action: Column(
              children: [
                FilledButton.icon(
                  onPressed: _busy || _url == null ? null : _download,
                  icon: const Icon(Icons.download),
                  label: Text(l10n.bachecaDownload),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _url == null ? null : _openExternal,
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l10n.bachecaOpenExternal),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Segnaposto dell'immagine sul fondo nero.
class _ImageSkeleton extends StatelessWidget {
  const _ImageSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Opacity(
        opacity: 0.3,
        child: Skeleton(width: 260, height: 200, radius: 20),
      ),
    );
  }
}

/// Segnaposto del PDF: un foglio con le righe di testo che respirano.
class _PdfSkeleton extends StatelessWidget {
  const _PdfSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(width: 150, height: 20),
          SizedBox(height: 20),
          Skeleton(height: 8),
          SizedBox(height: 12),
          Skeleton(width: 200, height: 8),
          SizedBox(height: 12),
          Skeleton(height: 8),
          SizedBox(height: 12),
          Skeleton(width: 160, height: 8),
          SizedBox(height: 12),
          Skeleton(width: 220, height: 8),
        ],
      ),
    );
  }
}
