import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'config/auth_gate.dart';
import 'config/routes/routes.dart';
import 'config/theme/app_themes.dart';
import 'features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'firebase_options.dart';
import 'injection_container.dart';
import 'l10n/app_localizations.dart';
import 'shared/presentation/connectivity_cubit.dart';
import 'shared/settings/domain/entities/app_settings_entity.dart';
import 'shared/settings/presentation/cubit/settings_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDependencies();
  await initializeDateFormatting();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>.value(value: sl<SettingsCubit>()),
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<ConnectivityCubit>.value(value: sl<ConnectivityCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, AppSettingsEntity>(
        builder: (context, settings) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: appTheme(brightness: Brightness.light, accent: settings.accent, accessible: settings.accessible),
            darkTheme: appTheme(brightness: Brightness.dark, accent: settings.accent, accessible: settings.accessible),
            themeMode: settings.themeMode,
            locale: settings.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            onGenerateRoute: AppRoutes.onGenerateRoutes,
            // The app already has its own larger accessible-mode font ramp
            // (AppDimensions.accessible); without a clamp here, the OS text
            // scale compounds on top of that and blows out fixed-height
            // cards (e.g. featured_article_card.dart's 330px hero).
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: MediaQuery.of(context).textScaler.clamp(maxScaleFactor: 1.5),
              ),
              child: child!,
            ),
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
