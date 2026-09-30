import 'package:flutter/widgets.dart';

import 'digits.dart';

/// Every language the app ships. To add one:
///   1. add `lib/l10n/app_<code>.arb` (copy app_en.arb and translate),
///   2. add an entry below.
/// Text direction comes from Flutter automatically (fa/ar/ur are RTL).
class AppLanguage {
  final String code;

  /// Name shown in the language picker, in the language itself.
  final String nativeName;

  /// Digits used when the digit setting is "Automatic".
  final DigitSet defaultDigits;

  /// The language's own digits, offered as the "local digits" option.
  final DigitSet nativeDigits;

  /// Bundled font for this script; null = platform default.
  final String? fontFamily;

  const AppLanguage({
    required this.code,
    required this.nativeName,
    required this.defaultDigits,
    required this.nativeDigits,
    this.fontFamily,
  });

  Locale get locale => Locale(code);
}

const List<AppLanguage> kLanguages = [
  AppLanguage(
    code: 'en',
    nativeName: 'English',
    defaultDigits: DigitSet.western,
    nativeDigits: DigitSet.western,
  ),
  AppLanguage(
    code: 'fa',
    nativeName: 'فارسی',
    defaultDigits: DigitSet.persian,
    nativeDigits: DigitSet.persian,
    fontFamily: 'Vazirmatn',
  ),
  AppLanguage(
    code: 'ar',
    nativeName: 'العربية',
    defaultDigits: DigitSet.arabicIndic,
    nativeDigits: DigitSet.arabicIndic,
    fontFamily: 'Vazirmatn',
  ),
  AppLanguage(
    code: 'ur',
    nativeName: 'اردو',
    // Western digits are the norm in Urdu apps; local digits are optional.
    defaultDigits: DigitSet.western,
    nativeDigits: DigitSet.persian,
    fontFamily: 'NotoNastaliqUrdu',
  ),
];

AppLanguage languageFor(Locale locale) => languageForCode(locale.languageCode);

/// Supported language for [code], falling back to English.
AppLanguage languageForCode(String? code) => kLanguages.firstWhere(
  (l) => l.code == code,
  orElse: () => kLanguages.first,
);
