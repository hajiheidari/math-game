import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/app_controller.dart';
import 'app/feedback.dart';
import 'app/app_prefs.dart';
import 'app/app_scope.dart';
import 'i18n/languages.dart';
import 'i18n/locale_controller.dart';
import 'l10n/app_localizations.dart';
import 'monetization/admob_ad_service.dart';
import 'monetization/monetization.dart';
import 'monetization/store_purchase_service.dart';
import 'screens/age_gate_screen.dart';
import 'screens/menu_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerFontLicenses();
  final prefs = await AppPrefs.load();
  runApp(NumCrossApp.fromPrefs(prefs));
}

class NumCrossApp extends StatelessWidget {
  final LocaleController locale;
  final AppController app;

  const NumCrossApp({super.key, required this.locale, required this.app});

  /// Restores saved language/digits (or the device language on first run)
  /// and saves them whenever they change.
  factory NumCrossApp.fromPrefs(AppPrefs prefs) {
    final device =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final locale = LocaleController(
      initial: languageForCode(prefs.languageCode ?? device),
      digitMode: prefs.digitMode,
    );
    locale.addListener(
      () => prefs.setLocale(locale.language.code, locale.digitMode),
    );
    // Real ads and store only on phones; web/desktop builds run ad-free.
    final mobile =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    final monetization = Monetization(
      prefs.shared,
      ads: mobile ? AdMobAdService() : null,
      purchases: mobile ? StorePurchaseService() : null,
    );
    return NumCrossApp(
      locale: locale,
      app: AppController(
        prefs,
        monetization: monetization,
        feedback: GameFeedback(prefs.shared, sound: AssetSoundPlayer()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: app,
      child: LocaleScope(
        controller: locale,
        child: ListenableBuilder(
          listenable: Listenable.merge([locale, app]),
          builder: (context, _) => MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            locale: locale.language.locale,
            supportedLocales: [for (final l in kLanguages) l.locale],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: _theme(Brightness.light, locale.language),
            darkTheme: _theme(Brightness.dark, locale.language),
            home: switch (app.gate) {
              GateState.needsAge => const AgeGateScreen(),
              GateState.blocked => const BlockedScreen(),
              GateState.ready => const MenuScreen(),
            },
          ),
        ),
      ),
    );
  }
}

ThemeData _theme(Brightness brightness, AppLanguage language) {
  final base = ThemeData(
    fontFamily: language.fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2F5D8A),
      brightness: brightness,
    ),
    useMaterial3: true,
  );
  final height = language.lineHeight;
  if (height == null) return base;
  TextTheme tall(TextTheme t) => t.merge(
    TextTheme(
      displayLarge: TextStyle(height: height),
      displayMedium: TextStyle(height: height),
      displaySmall: TextStyle(height: height),
      headlineLarge: TextStyle(height: height),
      headlineMedium: TextStyle(height: height),
      headlineSmall: TextStyle(height: height),
      titleLarge: TextStyle(height: height),
      titleMedium: TextStyle(height: height),
      titleSmall: TextStyle(height: height),
      bodyLarge: TextStyle(height: height),
      bodyMedium: TextStyle(height: height),
      bodySmall: TextStyle(height: height),
      labelLarge: TextStyle(height: height),
      labelMedium: TextStyle(height: height),
      labelSmall: TextStyle(height: height),
    ),
  );
  return base.copyWith(
    textTheme: tall(base.textTheme),
    primaryTextTheme: tall(base.primaryTextTheme),
  );
}

/// Shows the bundled fonts' OFL licenses on the licenses page.
void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (name, file) in [
      ('Vazirmatn', 'assets/fonts/Vazirmatn-OFL.txt'),
      ('Noto Nastaliq Urdu', 'assets/fonts/NotoNastaliqUrdu-OFL.txt'),
    ]) {
      yield LicenseEntryWithLineBreaks([
        name,
      ], await rootBundle.loadString(file));
    }
  });
}
