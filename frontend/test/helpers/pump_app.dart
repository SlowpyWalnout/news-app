import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/config/theme/app_colors.dart';
import 'package:news_app/config/theme/app_themes.dart';
import 'package:news_app/l10n/app_localizations.dart';

/// Widget-test harness. `pumpApp(child)` is byte-for-byte equivalent to the
/// `_wrap()` that used to be duplicated in `accessibility_test.dart` —
/// `meetsGuideline()` reads real rendered geometry, so changing the theme
/// args or the Scaffold/Center nesting can flip a tap-target assertion.
/// No `providers:` param: `flutter_bloc` doesn't re-export `SingleChildWidget`,
/// and importing `package:provider` here trips `depend_on_referenced_packages`.
/// Callers wrap their own `BlocProvider.value` around `child` when needed.
extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget child, {
    bool dark = false,
    AppAccent accent = AppAccent.lime,
    bool accessible = false,
    bool centerInScaffold = true,
  }) {
    return pumpWidget(MaterialApp(
      theme: appTheme(brightness: Brightness.light, accent: accent, accessible: accessible),
      darkTheme: appTheme(brightness: Brightness.dark, accent: accent, accessible: accessible),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: centerInScaffold ? Scaffold(body: Center(child: child)) : child,
    ));
  }
}
