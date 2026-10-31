import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
import '../../ui/widgets.dart';
import 'auth_providers.dart';

/// Accesso e registrazione a un account Itinera (Supabase).
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _register = false;
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = ref.read(authServiceProvider);
    try {
      if (_register) {
        final res = await auth.signUp(
          email: _emailCtrl.text,
          password: _passCtrl.text,
          displayName: _nameCtrl.text,
        );
        // La conferma via email è disattivata: l'accesso è immediato. Se per
        // qualche motivo non arriva subito una sessione, la completo io.
        if (res.session == null) {
          await auth.signIn(email: _emailCtrl.text, password: _passCtrl.text);
        }
      } else {
        await auth.signIn(email: _emailCtrl.text, password: _passCtrl.text);
      }
      // Se aperta come pagina (da Impostazioni) torna indietro; se è la radice
      // (utente non loggato), ci pensa il RootGate a mostrare la home.
      if (mounted && context.canPop()) context.pop();
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Errore imprevisto: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final ctrl = TextEditingController(text: _emailCtrl.text.trim());
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reimposta password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ti mandiamo un link via email. Funziona una sola volta.',
              style: context.texts.bodyMedium?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'Email'),
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
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Invia link'),
          ),
        ],
      ),
    );
    if (email == null || !email.contains('@')) return;
    try {
      await ref.read(authServiceProvider).sendPasswordReset(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Se l\'email è registrata, ti invieremo le istruzioni.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  /// Avvia un accesso social (Google/Apple): apre il browser e torna via deep
  /// link. La sessione la stabilisce supabase_flutter; il pop della pagina lo
  /// gestisce il listener su currentUserProvider in [build].
  Future<void> _oauth(Future<void> Function() start) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await start();
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Errore di accesso: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final auth = ref.read(authServiceProvider);
    // Dopo un accesso riuscito (anche social, che torna via deep link) chiudo
    // la pagina se è stata aperta da Impostazioni; alla radice ci pensa il gate.
    ref.listen(currentUserProvider, (_, next) {
      if (next != null && mounted && context.canPop()) context.pop();
    });
    // AnimatedSize non regge la durata zero: con le animazioni ridotte, 1 ms.
    final resize = Motion.off(context)
        ? const Duration(milliseconds: 1)
        : Motion.standard;
    const tall = Size.fromHeight(56);
    final label = TextStyle(
      fontFamily: tokens.displayFont,
      fontWeight: FontWeight.w700,
      fontSize: 16,
    );
    return Scaffold(
      // Tutto in un'unica colonna: i campi fuori schermo restano nel Form.
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AuthPoster(register: _register),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  24 + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PillSelector<bool>(
                      items: const {false: 'Accedi', true: 'Crea account'},
                      selected: _register,
                      onChanged: (v) {
                        if (_loading) return;
                        setState(() {
                          _register = v;
                          _error = null;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    // Il nome entra sopra l'email, solo per la registrazione.
                    AnimatedSize(
                      duration: resize,
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: _register
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TextFormField(
                                controller: _nameCtrl,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  labelText: 'Nome',
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Inserisci un nome'
                                    : null,
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) {
                        final s = (v ?? '').trim();
                        if (s.isEmpty || !s.contains('@')) {
                          return 'Email non valida';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          tooltip: _obscure
                              ? 'Mostra password'
                              : 'Nascondi password',
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Almeno 6 caratteri'
                          : null,
                    ),
                    // Conferma per chi si registra, link di recupero per chi accede.
                    AnimatedSize(
                      duration: resize,
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: _register
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: TextFormField(
                                controller: _confirmCtrl,
                                obscureText: _obscure,
                                decoration: const InputDecoration(
                                  labelText: 'Conferma password',
                                ),
                                validator: (v) => (v != _passCtrl.text)
                                    ? 'Le password non coincidono'
                                    : null,
                              ),
                            )
                          : Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _loading ? null : _forgotPassword,
                                child: const Text('Password dimenticata?'),
                              ),
                            ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      _Banner(
                        icon: Icons.error_outline,
                        text: _error!,
                        color: tokens.warning,
                      ),
                    ],
                    SizedBox(height: _register ? 12 : 4),
                    FilledButton(
                      style: FilledButton.styleFrom(minimumSize: tall),
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_register ? 'Crea account' : 'Accedi'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: Divider(color: tokens.hairline)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'oppure',
                            style: context.texts.bodySmall?.copyWith(
                              color: context.scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: tokens.hairline)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: tall,
                        textStyle: label,
                      ),
                      onPressed: _loading
                          ? null
                          : () => _oauth(auth.signInWithGoogle),
                      icon: Text(
                        'G',
                        style: label.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: context.scheme.onSurface,
                        ),
                      ),
                      label: const Text('Continua con Google'),
                    ),
                    // Login con Apple: pulsante rimosso finché non è disponibile
                    // un Apple Developer account. Il metodo
                    // AuthService.signInWithApple resta pronto per riattivarlo.
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Poster dell'accesso: sole e onde. Si abbassa in "Crea account", così i campi
/// in più restano in vista.
class _AuthPoster extends StatelessWidget {
  const _AuthPoster({required this.register});

  final bool register;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final canPop = context.canPop();
    final texts = context.texts;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyleOn(Cartolina.cobalto),
      child: AnimatedContainer(
        duration: Motion.of(context, Motion.standard),
        curve: Curves.easeOutCubic,
        height: register ? 220 : 280,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          color: Cartolina.cobalto,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _SunAndWavesPainter(topInset: top)),
            Positioned(
              top: top + 18,
              left: canPop ? 4 : 20,
              right: 120,
              child: Row(
                children: [
                  // Aperta da Impostazioni: serve la via del ritorno.
                  if (canPop) const BackButton(color: Colors.white),
                  Flexible(
                    child: Text(
                      'Itinera',
                      maxLines: 1,
                      style: texts.displaySmall?.copyWith(
                        fontSize: 44,
                        height: 1.1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
              child: AnimatedSwitcher(
                duration: Motion.of(context, Motion.fast),
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.centerLeft,
                  children: [...previous, ?current],
                ),
                child: Text(
                  register ? 'Crea il tuo account' : 'Bentornato',
                  key: ValueKey(register),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: texts.titleLarge?.copyWith(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sole in alto a destra, onde ancorate in basso: quando il poster si abbassa il
/// mare sale davanti al sole.
class _SunAndWavesPainter extends CustomPainter {
  const _SunAndWavesPainter({required this.topInset});

  final double topInset;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawCircle(
      Offset(w * 0.806, topInset + 50),
      46,
      Paint()..color = Cartolina.sole,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, h - 97)
        ..cubicTo(w * 0.12, h - 118, w * 0.30, h - 118, w * 0.45, h - 100)
        ..cubicTo(w * 0.60, h - 82, w * 0.82, h - 72, w, h - 97)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      Paint()..color = Cartolina.laguna,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, h - 52)
        ..cubicTo(w * 0.20, h - 40, w * 0.35, h - 52, w * 0.55, h - 60)
        ..cubicTo(w * 0.72, h - 66, w * 0.88, h - 62, w, h - 52)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      Paint()..color = Cartolina.cobaltoScuro,
    );
  }

  @override
  bool shouldRepaint(_SunAndWavesPainter old) => old.topInset != topInset;
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
