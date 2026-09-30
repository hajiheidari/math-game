import 'package:shared_preferences/shared_preferences.dart';

import '../i18n/digits.dart';

/// Everything the app keeps on the device. Nothing here leaves the device.
///
/// Privacy rules (brief): the age itself and the birth date are never
/// stored, only the resulting band id. An under-13 block stores a single
/// flag and wipes everything else.
class AppPrefs {
  static const _kBand = 'band';
  static const _kBlocked = 'blocked';
  static const _kLanguage = 'language';
  static const _kDigits = 'digits';
  static const _kTutorial = 'tutorialDone';

  final SharedPreferences _p;
  AppPrefs._(this._p);

  static Future<AppPrefs> load() async =>
      AppPrefs._(await SharedPreferences.getInstance());

  /// Shared store for other local data (progress). Wiped by [block] too.
  SharedPreferences get shared => _p;

  bool get isBlocked => _p.getBool(_kBlocked) ?? false;
  String? get bandId => isBlocked ? null : _p.getString(_kBand);
  String? get languageCode => _p.getString(_kLanguage);
  DigitMode get digitMode =>
      DigitMode.values.asNameMap()[_p.getString(_kDigits)] ?? DigitMode.auto;

  bool get tutorialDone => _p.getBool(_kTutorial) ?? false;

  Future<void> setTutorialDone() async {
    if (isBlocked) return;
    await _p.setBool(_kTutorial, true);
  }

  Future<void> setBand(String id) async {
    if (isBlocked) return;
    await _p.setString(_kBand, id);
  }

  /// Under-13: remember only the block, drop anything else we had.
  Future<void> block() async {
    await _p.clear();
    await _p.setBool(_kBlocked, true);
  }

  Future<void> setLocale(String languageCode, DigitMode digits) async {
    if (isBlocked) return;
    await _p.setString(_kLanguage, languageCode);
    await _p.setString(_kDigits, digits.name);
  }
}
