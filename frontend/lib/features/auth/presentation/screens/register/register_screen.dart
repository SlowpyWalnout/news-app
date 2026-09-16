import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/app_palette.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/widgets/app_buttons.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const routeName = '/Register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onFieldsChanged(BuildContext context) {
    context.read<AuthBloc>().add(AuthRegisterFieldsChanged(
          displayName: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (a, b) => b.status == AuthStatus.authenticated,
          listener: (context, state) => Navigator.of(context).pop(),
          builder: (context, state) {
            final loading = state.status == AuthStatus.loading;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: Text(l10n.back, style: const TextStyle(fontWeight: FontWeight.w700)),
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.createAccountTitle,
                    style: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w600, fontSize: 28, letterSpacing: -0.03 * 28),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.createAccountSubtitle, style: TextStyle(fontSize: 17.5, height: 1.5, color: palette.ink2)),
                  const SizedBox(height: 22),
                  if (state.submitError != null) ...[
                    _PlainDangerCard(message: state.submitError!.message),
                    const SizedBox(height: 18),
                  ],
                  AppTextField(
                    label: l10n.displayNameLabel,
                    controller: _nameController,
                    placeholder: l10n.displayNamePlaceholder,
                    errorText: state.registerNameError,
                    counterText: l10n.displayNameCounter(_nameController.text.length),
                    onChanged: (v) {
                      if (v.length > 60) {
                        _nameController.text = v.substring(0, 60);
                        _nameController.selection = TextSelection.collapsed(offset: 60);
                      }
                      _onFieldsChanged(context);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: l10n.emailLabel,
                    controller: _emailController,
                    placeholder: l10n.emailPlaceholder,
                    keyboardType: TextInputType.emailAddress,
                    errorText: state.registerEmailError,
                    onChanged: (_) => _onFieldsChanged(context),
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: l10n.passwordLabel,
                    controller: _passwordController,
                    placeholder: l10n.passwordPlaceholder,
                    obscureText: true,
                    errorText: state.registerPasswordError,
                    onChanged: (_) => _onFieldsChanged(context),
                  ),
                  if (state.registerPasswordValid && state.registerPasswordError == null) ...[
                    const SizedBox(height: 6),
                    Text(l10n.passwordValid, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: palette.ok)),
                  ],
                  const SizedBox(height: 18),
                  PrimaryButton(
                    label: loading ? l10n.creatingAccount : l10n.createAccount,
                    loading: loading,
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthSignUpSubmitted(
                            displayName: _nameController.text.trim(),
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                          ));
                    },
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

class _PlainDangerCard extends StatelessWidget {
  const _PlainDangerCard({required this.message});
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
