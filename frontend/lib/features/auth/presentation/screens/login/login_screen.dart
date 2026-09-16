import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/app_palette.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/widgets/app_buttons.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../register/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/Login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _hasFieldErrors =>
      _emailController.text.trim().isEmpty ||
      !_emailPattern.hasMatch(_emailController.text) ||
      _passwordController.text.length < 6;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final loading = state.status == AuthStatus.loading;
            final emailError = !_submitted
                ? null
                : (_emailController.text.trim().isEmpty
                    ? l10n.emailRequired
                    : (!_emailPattern.hasMatch(_emailController.text) ? l10n.emailInvalid : null));
            final passwordError = !_submitted
                ? null
                : (_passwordController.text.isEmpty
                    ? l10n.passwordRequired
                    : (_passwordController.text.length < 6 ? l10n.passwordTooShort : null));
            final showCredentialError = state.submitError != null && !_hasFieldErrors;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontWeight: FontWeight.w700,
                        fontSize: 30,
                        letterSpacing: -1.05,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      children: [
                        TextSpan(text: l10n.appWordmark),
                        TextSpan(text: '.', style: TextStyle(color: palette.accentInk)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.loginHeroTitle,
                    style: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w600, fontSize: 36, height: 1.06),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.loginHeroSubtitle, style: TextStyle(fontSize: 17.5, height: 1.5, color: palette.ink2)),
                  const SizedBox(height: 26),
                  AppTextField(
                    label: l10n.emailLabel,
                    controller: _emailController,
                    placeholder: l10n.emailPlaceholder,
                    keyboardType: TextInputType.emailAddress,
                    errorText: emailError,
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: l10n.passwordLabel,
                    controller: _passwordController,
                    placeholder: l10n.passwordPlaceholder,
                    obscureText: true,
                    errorText: passwordError,
                  ),
                  if (showCredentialError) ...[
                    const SizedBox(height: 18),
                    _CredentialErrorCard(message: l10n.loginCredentialError),
                  ],
                  const SizedBox(height: 18),
                  PrimaryButton(
                    label: loading ? l10n.signingIn : l10n.signIn,
                    loading: loading,
                    onPressed: () {
                      setState(() => _submitted = true);
                      if (_hasFieldErrors) return;
                      context.read<AuthBloc>().add(AuthSignInSubmitted(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                          ));
                    },
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      children: [
                        Text(l10n.noAccountYet, style: TextStyle(fontSize: 17.5, color: palette.ink2)),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          ),
                          child: Text(
                            l10n.signUp,
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17.5, color: palette.accentInk),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CredentialErrorCard extends StatelessWidget {
  const _CredentialErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
      decoration: BoxDecoration(
        color: palette.dangerSoft,
        border: Border.all(color: scheme.error),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(message, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, height: 1.5, color: scheme.error)),
    );
  }
}
