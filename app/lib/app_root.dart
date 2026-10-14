import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/app_controller.dart';
import 'app/feedback.dart';
import 'app/app_prefs.dart';
import 'app/app_scope.dart';
import 'app/crash_guard.dart';
import 'app/palette.dart';
import 'challenge/challenge.dart';
import 'i18n/languages.dart';
import 'i18n/locale_controller.dart';
import 'l10n/app_localizations.dart';
import 'monetization/ad_service.dart';
import 'monetization/monetization.dart';
import 'store.dart';
import 'screens/age_gate_screen.dart';
import 'screens/menu_screen.dart';

/// Starts the app with the given store services (see lib/main.dart).
void runAdadi({AdService Function()? ads}) {
  CrashGuard.run(() async {
    registerFontLicenses();
    final prefs = await AppPrefs.load();
    runApp(CrashOverlay(child: AdadiApp.fromPrefs(prefs, ads: ads)));
  });
}

class AdadiApp extends StatelessWidget {
  final LocaleController locale;
  final AppController app;

  const AdadiApp({super.key, required this.locale, required this.app});

  /// Restores saved language/digits (or the device language on first run)
  /// and saves them whenever they change.
  /// [ads] is the store's rewarded-ad network (lib/main_bazaar.dart:
  /// Adivery). Only created on phones; web, desktop and tests run without.
  factory AdadiApp.fromPrefs(AppPrefs prefs, {AdService Function()? ads}) {
    final device =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    // Web links choose the language: adadi.espadna.com/?lang=fa (the
    // espadna.com cards link that way). Otherwise saved choice, then device.
    final urlLang = kIsWeb ? Uri.base.queryParameters['lang'] : null;
    final fromUrl = kLanguages.any((l) => l.code == urlLang) ? urlLang : null;
    final locale = LocaleController(
      initial: languageForCode(
        fromUrl ??
            prefs.languageCode ??
            kStore.defaultLanguage ??
            (iranianSite(Uri.base) ? 'fa' : null) ??
            device,
      ),
      digitMode: prefs.digitMode,
    );
    locale.addListener(
      () => prefs.setLocale(locale.language.code, locale.digitMode),
    );
    // Real ads only on phones; web/desktop builds run ad-free.
    final mobile =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    final monetization = Monetization(
      prefs.shared,
      ads: mobile ? ads?.call() : null,
    );
    final app = AppController(
      prefs,
      monetization: monetization,
      feedback: GameFeedback(prefs.shared, sound: AssetSoundPlayer()),
    );
    // Opened from a friend's link (?r=code): the friend gets a coin. A
    // challenge (?c=) opens their puzzle once the menu shows.
    if (kIsWeb) {
      app.hints.reportVisit(Uri.base);
      app.pendingChallenge = Challenge.fromUri(Uri.base);
    }
    return AdadiApp(locale: locale, app: app);
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
            builder: (context, child) => PhoneColumn(child: child!),
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

/// The web game on the Iranian mirror (adadi.espadna.ir) starts in Persian
/// when no language was chosen, whatever the browser's language.
bool iranianSite(Uri page) => kIsWeb && page.host.endsWith('.ir');

/// On wide screens (desktop browsers, tablets) the game stays a phone-width
/// column in the middle instead of stretching edge to edge, which made the
/// board huge and the controls far apart. Dialogs open inside the column.
class PhoneColumn extends StatelessWidget {
  final Widget child;
  const PhoneColumn({super.key, required this.child});

  /// Column width: grows with the screen's height (so the board and the
  /// tiles still fit) between [minWidth] and [maxWidth]: about 760 on an iPad
  /// in portrait, 590 on a 1080p monitor.
  static const minWidth = 560.0;
  static const maxWidth = 820.0;
  static double widthFor(Size screen) =>
      (screen.height * 0.55).clamp(minWidth, maxWidth).roundToDouble();

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = widthFor(media.size);
    if (media.size.width <= width) return child;
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.18),
                blurRadius: 24,
              ),
            ],
          ),
          child: SizedBox(
            width: width,
            child: MediaQuery(
              data: media.copyWith(size: Size(width, media.size.height)),
              child: ClipRect(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

ThemeData _theme(Brightness brightness, AppLanguage language) {
  final dark = brightness == Brightness.dark;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: Palette.brand,
        brightness: brightness,
        dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
      ).copyWith(
        // The seed itself, not the scheme's darker tone: bright, warm buttons.
        primary: dark ? const Color(0xFF2DD4BF) : Palette.brand,
        onPrimary: dark ? const Color(0xFF042F2E) : Colors.white,
        surface: dark ? Palette.plum : Palette.cream,
        surfaceContainerLowest: dark ? const Color(0xFF15101E) : Colors.white,
        surfaceContainerLow: dark ? const Color(0xFF241B31) : Colors.white,
      );
  final base = ThemeData(
    fontFamily: language.fontFamily,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      elevation: 0,
      margin: EdgeInsets.zero,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
    ),
    // No textStyle here: it would replace the theme's (and lose the
    // Persian/Urdu font).
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(shape: const StadiumBorder()),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
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
void registerFontLicenses() {
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
