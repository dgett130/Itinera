import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/widgets.dart';
import 'auth_providers.dart';

/// Preferenza locale: c'e' un cambio password lasciato a meta'. Il link di
/// recupero apre gia' una sessione valida, quindi riaprendo l'app si torna qui
/// invece di ritrovarsi dentro senza aver scelto la password.
const kPasswordRecoveryPref = 'password_recovery_pending';

/// Impostazione di una nuova password dopo aver aperto il link di recupero.
/// Da qui si esce solo salvando, oppure uscendo anche dall'account.
class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  ConsumerState<PasswordResetScreen> createState() =>
      _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
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
    try {
      await ref.read(authServiceProvider).updatePassword(_passCtrl.text);
      await ref.read(databaseProvider).setPref(kPasswordRecoveryPref, '0');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Password aggiornata')));
        context.go('/');
      }
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Chiede conferma e, se si lascia, esce anche dall'account.
  Future<void> _leave() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lasciare il cambio password?'),
        content: const Text(
          'La password resta quella di prima e dovrai accedere di nuovo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Resta'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Esci'),
          ),
        ],
      ),
    );
    if (leave != true || !mounted) return;
    await ref.read(databaseProvider).setPref(kPasswordRecoveryPref, '0');
    await ref.read(authServiceProvider).signOut();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_loading) _leave();
      },
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Si arriva dal link dell'email: non c'è nulla a cui tornare.
            const SizedBox(height: 32),
            const PlainHeader(
              title: 'Scegli una nuova password',
              showBack: false,
              size: 32,
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Nuova password',
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Almeno 6 caratteri'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Conferma password',
                      ),
                      validator: (v) => (v != _passCtrl.text)
                          ? 'Le password non coincidono'
                          : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(_error!, style: TextStyle(color: tokens.warning)),
                    ],
                    const SizedBox(height: 12),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Salva password'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      onPressed: _loading ? null : _leave,
                      child: const Text('Annulla'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
