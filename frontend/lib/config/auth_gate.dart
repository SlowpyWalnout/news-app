import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/presentation/bloc/auth/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth/auth_event.dart';
import '../features/auth/presentation/bloc/auth/auth_state.dart';
import '../features/auth/presentation/screens/login/login_screen.dart';
import '../shared/widgets/branded_splash.dart';
import 'app_shell.dart';

/// Root widget: resolves whether a session already exists and shows
/// [LoginScreen] or [AppShell] accordingly, with [BrandedSplash] as the
/// transition for both directions ([AuthStatus.signingIn] after a
/// successful login/register/Google sign-in, [AuthStatus.signingOut] after
/// "Cerrar sesión").
///
/// [AuthStatus.loading] is reused by the login/register submit flows, so
/// this only reacts to it during the very first session check — once
/// resolved, later `loading` blips (mid-submit) must not swap LoginScreen
/// out for a spinner while the user is looking at it. `signingIn`/
/// `signingOut` are separate statuses precisely so they don't share that
/// exemption.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _sessionResolved = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthSessionChecked());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (a, b) => !_sessionResolved && b.status != AuthStatus.loading,
      listener: (context, state) => setState(() => _sessionResolved = true),
      buildWhen: (a, b) => !_sessionResolved || a.status != b.status,
      builder: (context, state) {
        final Widget child;
        if (!_sessionResolved) {
          child = const Scaffold(
            key: ValueKey('resolving'),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state.status == AuthStatus.signingIn || state.status == AuthStatus.signingOut) {
          child = const BrandedSplash(key: ValueKey('splash'));
        } else if (state.status == AuthStatus.authenticated) {
          child = const AppShell(key: ValueKey('shell'));
        } else {
          child = const LoginScreen(key: ValueKey('login'));
        }
        // AnimatedSwitcher's default transitionBuilder is already a
        // FadeTransition — crossfading in/out of BrandedSplash (and every
        // other branch here) instead of the hard cut a plain widget swap
        // would give.
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: child,
        );
      },
    );
  }
}
