import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/presentation/bloc/auth/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth/auth_event.dart';
import '../features/auth/presentation/bloc/auth/auth_state.dart';
import '../features/auth/presentation/screens/login/login_screen.dart';
import 'app_shell.dart';

/// Root widget: resolves whether a session already exists and shows
/// [LoginScreen] or [AppShell] accordingly. Also the screen the app
/// returns to after "Cerrar sesión" pops back to it.
///
/// [AuthStatus.loading] is reused by the login/register submit flows, so
/// this only reacts to it during the very first session check — once
/// resolved, later `loading` blips (mid-submit) must not swap LoginScreen
/// out for a spinner while the user is looking at it.
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
        if (!_sessionResolved) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return state.status == AuthStatus.authenticated ? const AppShell() : const LoginScreen();
      },
    );
  }
}
