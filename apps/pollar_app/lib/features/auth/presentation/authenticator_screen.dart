import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

class AuthenticatorScreen extends ConsumerStatefulWidget {
  const AuthenticatorScreen({super.key});

  @override
  ConsumerState<AuthenticatorScreen> createState() =>
      _AuthenticatorScreenState();
}

class _AuthenticatorScreenState extends ConsumerState<AuthenticatorScreen> {
  final _code = TextEditingController();
  AuthenticatorEnrollment? _enrollment;
  String? _error;
  var _loading = true;
  var _canUnlockLocally = false;
  var _localBusy = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_prepare);
    Future.microtask(_checkLocalUnlock);
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _prepare() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(authControllerProvider)
          .prepareAuthenticator();
      if (mounted) setState(() => _enrollment = result);
    } on AuthFailure catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Não foi possível preparar o autenticador. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _checkLocalUnlock() async {
    final auth = ref.read(authGatewayProvider);
    if (!auth.isSecondFactorVerified || !auth.hasRecentEmailCode) return;
    final supported = await ref.read(deviceUnlockGatewayProvider).isSupported();
    if (mounted) setState(() => _canUnlockLocally = supported);
  }

  Future<void> _unlockLocally() async {
    if (_localBusy || !_canUnlockLocally) return;
    setState(() {
      _localBusy = true;
      _error = null;
    });
    try {
      final verified = await ref
          .read(deviceUnlockGatewayProvider)
          .authenticate();
      if (!mounted) return;
      if (verified) {
        ref.read(authenticatorUnlockedProvider.notifier).unlock();
        context.go('/overview');
      } else {
        setState(
          () => _error = 'O dispositivo não confirmou sua identidade. Tente novamente ou use o autenticador.',
        );
      }
    } finally {
      if (mounted) setState(() => _localBusy = false);
    }
  }

  Future<void> _verify() async {
    final factor = _enrollment;
    if (factor == null || _loading) return;
    if (!RegExp(r'^\d{6}$').hasMatch(_code.text.trim())) {
      setState(() => _error = 'Informe os 6 dígitos do app autenticador.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authControllerProvider)
          .verifyAuthenticator(factorId: factor.factorId, code: _code.text);
      ref.read(authenticatorUnlockedProvider.notifier).unlock();
      if (mounted) context.go('/overview');
    } on AuthFailure catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = 'Não foi possível confirmar o código. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enrollment = _enrollment;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(PollarSpacing.x4),
              children: [
                const SizedBox(height: PollarSpacing.x8),
                Text(
                  'Pollar',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: PollarSpacing.x8),
                Text(
                  enrollment?.secret == null
                      ? 'Confirme no autenticador'
                      : 'Conecte seu autenticador',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: PollarSpacing.x3),
                Text(
                  enrollment?.secret == null
                      ? 'Abra o app autenticador do celular e informe o código do Pollar.'
                      : 'Adicione uma conta no seu app autenticador usando esta chave. Depois, informe o código gerado.',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: context.pollar.textSecondary),
                ),
                const SizedBox(height: PollarSpacing.x6),
                PollarCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (enrollment?.secret case final secret?) ...[
                        const PollarBanner(
                          title: 'Chave de configuração',
                          message: 'Guarde esta chave apenas no autenticador. Ela não será mostrada novamente após a confirmação.',
                          tone: PollarStatusTone.info,
                        ),
                        const SizedBox(height: PollarSpacing.x4),
                        SelectableText(
                          secret,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: PollarSpacing.x5),
                      ],
                      if (_error != null) ...[
                        PollarBanner(
                          message: _error!,
                          tone: PollarStatusTone.danger,
                        ),
                        const SizedBox(height: PollarSpacing.x4),
                      ],
                      TextField(
                        key: const Key('auth-totp-code'),
                        controller: _code,
                        enabled: !_loading && enrollment != null,
                        autofocus: enrollment != null,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.oneTimeCode],
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        onSubmitted: (_) => _verify(),
                        decoration: const InputDecoration(
                          labelText: 'Código do autenticador',
                          prefixIcon: Icon(LucideIcons.shieldCheck, size: 20),
                        ),
                      ),
                      const SizedBox(height: PollarSpacing.x5),
                      PollarButton(
                        label: 'Confirmar autenticador',
                        onPressed: _loading || enrollment == null
                            ? null
                            : _verify,
                        loading: _loading,
                        fullWidth: true,
                      ),
                      if (_canUnlockLocally) ...[
                        const SizedBox(height: PollarSpacing.x2),
                        PollarButton(
                          label: defaultTargetPlatform == TargetPlatform.windows
                              ? 'Desbloquear com Windows Hello'
                              : 'Desbloquear com biometria ou PIN',
                          variant: PollarButtonVariant.secondary,
                          onPressed: _localBusy ? null : _unlockLocally,
                          loading: _localBusy,
                          fullWidth: true,
                        ),
                        const SizedBox(height: PollarSpacing.x2),
                        Text(
                          'Usa a confirmação do sistema neste dispositivo; não substitui o cadastro inicial do autenticador.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: context.pollar.textSecondary),
                        ),
                      ],
                      if (_error != null && enrollment == null) ...[
                        const SizedBox(height: PollarSpacing.x2),
                        PollarButton(
                          label: 'Tentar novamente',
                          variant: PollarButtonVariant.secondary,
                          onPressed: _prepare,
                          fullWidth: true,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: PollarSpacing.x4),
                PollarButton(
                  label: 'Sair da conta',
                  variant: PollarButtonVariant.ghost,
                  onPressed: _loading
                      ? null
                      : () => ref.read(authControllerProvider).signOut(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
