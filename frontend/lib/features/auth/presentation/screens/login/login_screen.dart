import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/app_dimensions.dart';
import '../../../../../config/theme/app_palette.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/presentation/failure_localizer.dart';
import '../../../../../shared/widgets/app_buttons.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../../../../shared/widgets/app_wordmark.dart';
import '../../../../../shared/widgets/inline_banner.dart';
import '../../../../../shared/widgets/legal_links_notice.dart';
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

  void _onFieldsChanged(BuildContext context) {
    context.read<AuthBloc>().add(AuthLoginFieldsChanged(
          email: _emailController.text,
          password: _passwordController.text,
        ));
  }

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
            final emailError = state.loginEmailValid ? null : l10n.emailInvalid;
            final passwordError = state.loginPasswordValid ? null : l10n.passwordTooShort;
            final showAuthError = state.submitError != null &&
                state.loginEmailValid &&
                state.loginPasswordValid;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppWordmark(text: l10n.appWordmark, letterSpacing: -1.05),
                        const SizedBox(height: 20),
                        Text(
                          l10n.loginHeroTitle,
                          style: TextStyle(
                              fontFamily: 'Space Grotesk',
                              fontWeight: FontWeight.w600,
                              fontSize: dims.fHero,
                              height: 1.06),
                        ),
                        const SizedBox(height: 8),
                        Text(l10n.loginHeroSubtitle,
                            style: TextStyle(
                                fontSize: dims.fMd,
                                height: 1.5,
                                color: palette.ink2)),
                        const SizedBox(height: 26),
                        AppTextField(
                          label: l10n.emailLabel,
                          controller: _emailController,
                          placeholder: l10n.emailPlaceholder,
                          keyboardType: TextInputType.emailAddress,
                          errorText: emailError,
                          onChanged: (_) => _onFieldsChanged(context),
                        ),
                        const SizedBox(height: 18),
                        AppTextField(
                          label: l10n.passwordLabel,
                          controller: _passwordController,
                          placeholder: l10n.passwordPlaceholder,
                          obscureText: true,
                          errorText: passwordError,
                          onChanged: (_) => _onFieldsChanged(context),
                        ),
                        if (showAuthError) ...[
                          const SizedBox(height: 18),
                          InlineBanner(body: describeFailure(l10n, state.submitError!)),
                        ],
                        const SizedBox(height: 18),
                        PrimaryButton(
                          label: loading ? l10n.signingIn : l10n.signIn,
                          loading: loading,
                          onPressed: () => context.read<AuthBloc>().add(AuthSignInSubmitted(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              )),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(child: Divider(color: palette.line)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(l10n.orDivider,
                                  style: TextStyle(color: palette.ink2)),
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
                              : () => context
                                  .read<AuthBloc>()
                                  .add(const AuthGoogleSignInRequested()),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            children: [
                              Text(l10n.noAccountYet,
                                  style: TextStyle(
                                      fontSize: dims.fMd, color: palette.ink2)),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                ),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const RegisterScreen()),
                                ),
                                child: Text(
                                  l10n.signUp,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: dims.fMd,
                                      color: palette.accentInk),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 18),
                  child: LegalLinksNotice(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
