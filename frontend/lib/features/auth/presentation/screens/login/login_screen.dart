import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/app_dimensions.dart';
import '../../../../../config/theme/app_palette.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/presentation/failure_localizer.dart';
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
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthSubmitErrorCleared());
  }

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
    final dims = Theme.of(context).extension<AppDimensions>()!;

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
            final showAuthError = state.submitError != null && !_hasFieldErrors;

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
                        fontSize: dims.fH,
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
                    style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w600, fontSize: dims.fHero, height: 1.06),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.loginHeroSubtitle, style: TextStyle(fontSize: dims.fMd, height: 1.5, color: palette.ink2)),
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
                  if (showAuthError) ...[
                    const SizedBox(height: 18),
                    _AuthErrorCard(message: describeFailure(l10n, state.submitError!)),
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
                  Row(
                    children: [
                      Expanded(child: Divider(color: palette.line)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(l10n.orDivider, style: TextStyle(color: palette.ink2)),
                      ),
                      Expanded(child: Divider(color: palette.line)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SecondaryButton(
                    label: l10n.continueWithGoogle,
                    expand: true,
                    onPressed: loading
                        ? null
                        : () => context.read<AuthBloc>().add(const AuthGoogleSignInRequested()),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(l10n.noAccountYet, style: TextStyle(fontSize: dims.fMd, color: palette.ink2)),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          ),
                          child: Text(
                            l10n.signUp,
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: dims.fMd, color: palette.accentInk),
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

class _AuthErrorCard extends StatelessWidget {
  const _AuthErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;
    final dims = Theme.of(context).extension<AppDimensions>()!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
      decoration: BoxDecoration(
        color: palette.dangerSoft,
        border: Border.all(color: scheme.error),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(message, style: TextStyle(fontWeight: FontWeight.w600, fontSize: dims.fSm, height: 1.5, color: scheme.error)),
    );
  }
}
