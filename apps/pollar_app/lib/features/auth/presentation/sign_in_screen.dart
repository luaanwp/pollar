// THESIS: A entrada é um limiar de privacidade explícito; recusa promessas vagas de segurança e formulários promocionais.
// OWN-WORLD: Fundo clínico, painel único contornado, teal restrito e feedback semântico do Pollar.
// STORY: A pessoa entende por que existe uma conta, escolhe senha ou link e entra sem perder o trabalho local.
// FIRST VIEWPORT: Marca e propósito formam a coluna curta; o formulário concentra dados, recuperação e ação principal.
// FORM: Portal operacional contido, extensão direta do livro-caixa sereno e do sistema estabelecido.
// FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, and DESIGN.md

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/pollar_theme.dart';
import '../../../shared/presentation/pollar_banner.dart';
import '../../../shared/presentation/pollar_button.dart';
import '../../../shared/presentation/pollar_card.dart';
import '../../../shared/presentation/status_badge.dart';
import '../application/auth_gateway.dart';
import 'auth_controller.dart';

enum _AuthMode { signIn, signUp }

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _mode = _AuthMode.signIn;
  var _loading = false;
  String? _message;
  PollarStatusTone _messageTone = PollarStatusTone.info;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide =
        MediaQuery.sizeOf(context).width >= PollarBreakpoints.expandedMin;
    final intro = const _AuthIntroduction();
    final form = _AuthForm(
      formKey: _formKey,
      mode: _mode,
      email: _email,
      password: _password,
      loading: _loading,
      message: _message,
      messageTone: _messageTone,
      onSubmit: _submit,
      onMagicLink: _sendMagicLink,
      onModeChanged: (mode) => setState(() {
        _mode = mode;
        _message = null;
      }),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: intro),
                      const SizedBox(width: PollarSpacing.x10),
                      SizedBox(width: 430, child: form),
                    ],
                  )
                else ...[
                  intro,
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final controller = ref.read(authControllerProvider);
      if (_mode == _AuthMode.signIn) {
        await controller.signIn(email: _email.text, password: _password.text);
        if (mounted) context.go('/overview');
      } else {
        final result = await controller.signUp(
          email: _email.text,
          password: _password.text,
        );
        if (!mounted) return;
        if (result.needsEmailConfirmation) {
          setState(() {
            _message = 'Cadastro recebido. Confirme o e-mail antes de entrar.';
            _messageTone = PollarStatusTone.success;
            _mode = _AuthMode.signIn;
          });
        } else {
          context.go('/overview');
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

  Future<void> _sendMagicLink() async {
    final emailError = _validateEmail(_email.text);
    if (emailError != null) {
      setState(() {
        _message = emailError;
        _messageTone = PollarStatusTone.danger;
      });
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await ref.read(authControllerProvider).sendMagicLink(_email.text);
      if (mounted) {
        setState(() {
          _message = 'Link de acesso enviado. Verifique sua caixa de entrada.';
          _messageTone = PollarStatusTone.success;
        });
      }
    } on AuthFailure catch (error) {
      if (mounted) {
        setState(() {
          _message = error.message;
          _messageTone = PollarStatusTone.danger;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _AuthIntroduction extends StatelessWidget {
  const _AuthIntroduction();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.pollar.primary,
              borderRadius: BorderRadius.circular(PollarRadii.small),
            ),
          ),
          const SizedBox(width: PollarSpacing.x3),
          Text('Pollar', style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
      const SizedBox(height: PollarSpacing.x8),
      Text(
        'Seus registros, no dispositivo e entre dispositivos',
        style: Theme.of(context).textTheme.displaySmall,
      ),
      const SizedBox(height: PollarSpacing.x3),
      Text(
        'A conta identifica seus dados no servidor. O livro-caixa continua disponível offline e envia mudanças quando a conexão volta.',
        style: Theme.of(context).textTheme.bodyLarge
            ?.copyWith(color: context.pollar.textSecondary),
      ),
      const SizedBox(height: PollarSpacing.x5),
      const _TrustLine(
        icon: LucideIcons.hardDrive,
        text: 'Leitura e registro continuam locais',
      ),
      const SizedBox(height: PollarSpacing.x3),
      const _TrustLine(
        icon: LucideIcons.shieldCheck,
        text: 'Sessão guardada no armazenamento seguro do sistema',
      ),
      const SizedBox(height: PollarSpacing.x3),
      const _TrustLine(
        icon: LucideIcons.refreshCw,
        text: 'Conflitos financeiros nunca são sobrescritos em silêncio',
      ),
    ],
  );
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

class _AuthForm extends StatelessWidget {
  const _AuthForm({
    required this.formKey,
    required this.mode,
    required this.email,
    required this.password,
    required this.loading,
    required this.message,
    required this.messageTone,
    required this.onSubmit,
    required this.onMagicLink,
    required this.onModeChanged,
  });

  final GlobalKey<FormState> formKey;
  final _AuthMode mode;
  final TextEditingController email;
  final TextEditingController password;
  final bool loading;
  final String? message;
  final PollarStatusTone messageTone;
  final VoidCallback onSubmit;
  final VoidCallback onMagicLink;
  final ValueChanged<_AuthMode> onModeChanged;

  @override
  Widget build(BuildContext context) => PollarCard(
    child: Form(
      key: formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              mode == _AuthMode.signIn ? 'Entrar na conta' : 'Criar conta',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: PollarSpacing.x2),
            Text(
              mode == _AuthMode.signIn
                  ? 'Use o mesmo acesso nos seus dispositivos.'
                  : 'O e-mail pode precisar de confirmação antes do primeiro acesso.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: context.pollar.textSecondary),
            ),
            if (message != null) ...[
              const SizedBox(height: PollarSpacing.x4),
              PollarBanner(message: message!, tone: messageTone),
            ],
            const SizedBox(height: PollarSpacing.x5),
            TextFormField(
              key: const Key('auth-email'),
              controller: email,
              enabled: !loading,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                hintText: 'nome@dominio.com',
                prefixIcon: Icon(LucideIcons.mail, size: 20),
              ),
              validator: _validateEmail,
            ),
            const SizedBox(height: PollarSpacing.x4),
            TextFormField(
              key: const Key('auth-password'),
              controller: password,
              enabled: !loading,
              obscureText: true,
              autofillHints: [
                mode == _AuthMode.signIn
                    ? AutofillHints.password
                    : AutofillHints.newPassword,
              ],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => onSubmit(),
              decoration: const InputDecoration(
                labelText: 'Senha',
                prefixIcon: Icon(LucideIcons.lockKeyhole, size: 20),
              ),
              validator: (value) {
                if ((value ?? '').length < 8) {
                  return 'Use pelo menos 8 caracteres.';
                }
                return null;
              },
            ),
            const SizedBox(height: PollarSpacing.x5),
            PollarButton(
              label: mode == _AuthMode.signIn
                  ? 'Entrar na conta'
                  : 'Criar conta',
              onPressed: loading ? null : onSubmit,
              loading: loading,
              fullWidth: true,
            ),
            const SizedBox(height: PollarSpacing.x2),
            PollarButton(
              label: 'Receber link de acesso',
              variant: PollarButtonVariant.secondary,
              leadingIcon: LucideIcons.send,
              onPressed: loading ? null : onMagicLink,
              fullWidth: true,
            ),
            const SizedBox(height: PollarSpacing.x4),
            PollarButton(
              label: mode == _AuthMode.signIn
                  ? 'Criar uma conta'
                  : 'Já tenho uma conta',
              variant: PollarButtonVariant.ghost,
              onPressed: loading
                  ? null
                  : () => onModeChanged(
                      mode == _AuthMode.signIn
                          ? _AuthMode.signUp
                          : _AuthMode.signIn,
                    ),
              fullWidth: true,
            ),
          ],
        ),
      ),
    ),
  );
}

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  final separator = email.indexOf('@');
  if (separator <= 0 ||
      separator == email.length - 1 ||
      !email.substring(separator + 1).contains('.')) {
    return 'Informe um e-mail válido, como nome@dominio.com.';
  }
  return null;
}
