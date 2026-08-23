import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../ui/itinera_theme.dart';
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

  bool _register = false;
  bool _obscure = true;
  bool _loading = false;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
      _info = null;
    });
    final auth = ref.read(authServiceProvider);
    try {
      if (_register) {
        final res = await auth.signUp(
          email: _emailCtrl.text,
          password: _passCtrl.text,
          displayName: _nameCtrl.text,
        );
        if (res.session == null) {
          // Conferma via email richiesta dal progetto.
          setState(() {
            _info = 'Ti abbiamo inviato una email di conferma. '
                'Confermala, poi accedi.';
            _register = false;
          });
          return;
        }
      } else {
        await auth.signIn(email: _emailCtrl.text, password: _passCtrl.text);
      }
      // Se aperta come pagina (da Impostazioni) torna indietro; se e' la radice
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

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      appBar: AppBar(title: Text(_register ? 'Crea account' : 'Accedi')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: tokens.accentSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(Icons.account_circle_outlined,
                    size: 34, color: tokens.accent),
              ),
              const SizedBox(height: 20),
              Text(
                _register ? 'Crea il tuo account' : 'Bentornato',
                style: context.texts.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                _register
                    ? 'Un account ti permette di sincronizzare e condividere i viaggi.'
                    : 'Accedi per ritrovare e condividere i tuoi viaggi.',
                style: context.texts.bodyMedium
                    ?.copyWith(color: context.scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              if (_register) ...[
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Inserisci un nome'
                      : null,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty || !s.contains('@')) return 'Email non valida';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) => (v == null || v.length < 6)
                    ? 'Almeno 6 caratteri'
                    : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                _Banner(
                  icon: Icons.error_outline,
                  text: _error!,
                  color: tokens.warning,
                ),
              ],
              if (_info != null) ...[
                const SizedBox(height: 16),
                _Banner(
                  icon: Icons.mark_email_read_outlined,
                  text: _info!,
                  color: tokens.positive,
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_register ? Icons.person_add : Icons.login),
                label: Text(_register ? 'Registrati' : 'Accedi'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loading
                    ? null
                    : () => setState(() {
                          _register = !_register;
                          _error = null;
                          _info = null;
                        }),
                child: Text(_register
                    ? 'Hai gia\' un account? Accedi'
                    : 'Non hai un account? Registrati'),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(color: color, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
