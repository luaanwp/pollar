import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/pollar_theme.dart';
import '../../../shared/presentation/pollar_banner.dart';
import '../../../shared/presentation/pollar_button.dart';
import '../../../shared/presentation/pollar_card.dart';
import '../../../shared/presentation/status_badge.dart';
import '../application/auth_gateway.dart';
import 'auth_controller.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  static const _emailStorageKey = 'pollar:last-sign-in-email';
  static const _storage = FlutterSecureStorage();
  final _email = TextEditingController();
  final _code = TextEditingController();
  var _codeSent = false;
  var _loading = false;
  String? _message;
  PollarStatusTone _messageTone = PollarStatusTone.info;

  @override
  void initState() {
    super.initState();
    _loadKnownEmail();
  }

  Future<void> _loadKnownEmail() async {
    final sessionEmail = ref.read(authGatewayProvider).currentSession?.email;
    String? storedEmail;
    try {
      storedEmail = await _storage.read(key: _emailStorageKey);
    } catch (_) {
      // A locked or unavailable OS credential store must not block sign-in.
    }
    if (mounted && _email.text.isEmpty) {
      _email.text = sessionEmail ?? storedEmail ?? '';
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    final email = _email.text.trim();
    if (email.isEmpty ||
        !email.contains('@') ||
        !email.split('@').last.contains('.')) {
      setState(() {
        _message = 'Informe um e-mail válido, como nome@dominio.com.';
        _messageTone = PollarStatusTone.danger;
      });
      return;
    }
    if (_codeSent && !RegExp(r'^\d{6}$').hasMatch(_code.text.trim())) {
      setState(() {
        _message = 'Informe os 6 dígitos enviados por e-mail.';
        _messageTone = PollarStatusTone.danger;
      });
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final auth = ref.read(authControllerProvider);
      if (_codeSent) {
        await auth.verifyEmailCode(email: email, code: _code.text);
        try {
          await _storage.write(key: _emailStorageKey, value: email);
        } catch (_) {
          // Remembering the address is convenience, not an auth requirement.
        }
      } else {
        await auth.sendEmailCode(email);
        if (mounted) {
          setState(() {
            _codeSent = true;
            _message = 'Código enviado. Confira seu e-mail para continuar.';
            _messageTone = PollarStatusTone.success;
          });
        }
      }
    } on AuthFailure catch (error) {
      if (mounted) {
        setState(() {
          _message = error.message;
          _messageTone = PollarStatusTone.danger;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _message = 'Não foi possível acessar a conta. Verifique a conexão e tente novamente.';
          _messageTone = PollarStatusTone.danger;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide =
        MediaQuery.sizeOf(context).width >= PollarBreakpoints.expandedMin;
    final introduction = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Pollar', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: PollarSpacing.x8),
        Text(
          'Seu livro-caixa começa com você',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: PollarSpacing.x3),
        Text(
          'Acesse com um código por e-mail e confirme no seu app autenticador. Nenhuma conta ou saldo de exemplo será criado.',
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: context.pollar.textSecondary),
        ),
        const SizedBox(height: PollarSpacing.x5),
        const _TrustLine(
          icon: LucideIcons.shieldCheck,
          text: 'Sessão guardada no armazenamento seguro do dispositivo',
        ),
        const SizedBox(height: PollarSpacing.x3),
        const _TrustLine(
          icon: LucideIcons.hardDrive,
          text: 'Registros financeiros permanecem disponíveis offline',
        ),
      ],
    );
    final form = PollarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _codeSent ? 'Confira seu e-mail' : 'Entrar na conta',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: PollarSpacing.x2),
          Text(
            _codeSent
                ? 'Digite o código de 6 dígitos enviado para ${_email.text.trim()}.'
                : 'Sem senha. O e-mail confirma o acesso neste dispositivo.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: context.pollar.textSecondary),
          ),
          if (_message != null) ...[
            const SizedBox(height: PollarSpacing.x4),
            PollarBanner(message: _message!, tone: _messageTone),
          ],
          const SizedBox(height: PollarSpacing.x5),
          TextField(
            key: const Key('auth-email'),
            controller: _email,
            enabled: !_loading && !_codeSent,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: _codeSent
                ? TextInputAction.done
                : TextInputAction.next,
            onSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'E-mail',
              prefixIcon: Icon(LucideIcons.mail, size: 20),
            ),
          ),
          if (_codeSent) ...[
            const SizedBox(height: PollarSpacing.x4),
            TextField(
              key: const Key('auth-email-code'),
              controller: _code,
              enabled: !_loading,
              autofocus: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Código do e-mail',
                prefixIcon: Icon(LucideIcons.mailCheck, size: 20),
              ),
            ),
          ],
          const SizedBox(height: PollarSpacing.x5),
          PollarButton(
            label: _codeSent
                ? 'Confirmar código do e-mail'
                : 'Receber código por e-mail',
            onPressed: _loading ? null : _submit,
            loading: _loading,
            fullWidth: true,
          ),
          if (_codeSent) ...[
            const SizedBox(height: PollarSpacing.x2),
            PollarButton(
              label: 'Usar outro e-mail',
              variant: PollarButtonVariant.ghost,
              onPressed: _loading
                  ? null
                  : () => setState(() {
                      _codeSent = false;
                      _code.clear();
                      _message = null;
                    }),
              fullWidth: true,
            ),
          ],
        ],
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: ListView(
              padding: EdgeInsets.all(
                wide ? PollarSpacing.x8 : PollarSpacing.x4,
              ),
              children: [
                if (wide)
                  Row(
                    children: [
                      Expanded(child: introduction),
                      const SizedBox(width: PollarSpacing.x10),
                      SizedBox(width: 430, child: form),
                    ],
                  )
                else ...[
                  introduction,
                  const SizedBox(height: PollarSpacing.x6),
                  form,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrustLine extends StatelessWidget {
  const _TrustLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: context.pollar.primary),
      const SizedBox(width: PollarSpacing.x3),
      Expanded(child: Text(text)),
    ],
  );
}
