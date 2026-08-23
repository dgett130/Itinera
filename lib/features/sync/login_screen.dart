import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../ui/itinera_theme.dart';

/// Login alla versione remota: URL del server + credenziali (pre-impostate).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlCtrl = TextEditingController();
  final _userCtrl = TextEditingController(text: 'dgett130');
  final _passCtrl = TextEditingController(text: 'password');
  bool _loading = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  Future<void> _prefill() async {
    final s = await ref.read(settingsRepositoryProvider).get();
    if (!mounted) return;
    if (s.serverUrl != null) _urlCtrl.text = s.serverUrl!;
    if (s.remoteUsername != null) _userCtrl.text = s.remoteUsername!;
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final outcome = await ref.read(syncServiceProvider).loginAndInit(
            _urlCtrl.text.trim(),
            _userCtrl.text.trim(),
            _passCtrl.text,
          );
      // Al successo il RootGate mostra la home da solo (token salvato).
      messenger.showSnackBar(SnackBar(content: Text(outcome.message)));
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      messenger.showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accedi al server'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              ref.read(settingsRepositoryProvider).resetModeChoice(),
        ),
      ),
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
                child: Icon(Icons.cloud_sync, size: 32, color: tokens.accent),
              ),
              const SizedBox(height: 20),
              Text('Sincronizza i tuoi viaggi',
                  style: context.texts.headlineSmall),
              const SizedBox(height: 6),
              Text(
                'Accedi al tuo server per avere i viaggi su tutti i dispositivi.',
                style: context.texts.bodyMedium
                    ?.copyWith(color: context.scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _urlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Indirizzo del server',
                  hintText: 'http://100.x.y.z:8080',
                  prefixIcon: Icon(Icons.dns),
                ),
                keyboardType: TextInputType.url,
                autocorrect: false,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Inserisci l\'indirizzo del server'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _userCtrl,
                decoration: const InputDecoration(
                  labelText: 'Utente',
                  prefixIcon: Icon(Icons.person),
                ),
                autocorrect: false,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Inserisci l\'utente'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loading ? null : _login,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: Text(_loading ? 'Accesso...' : 'Accedi e sincronizza'),
              ),
              const SizedBox(height: 12),
              Text(
                'Il dispositivo deve essere sulla stessa rete Tailscale del server.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
