import 'package:flutter/widgets.dart';

import 'digits.dart';
import 'languages.dart';

/// Current language and digit preference. Saved by the listener set up in
/// `main.dart`.
class LocaleController extends ChangeNotifier {
  AppLanguage _language;
  DigitMode _digitMode;

  LocaleController({AppLanguage? initial, this._digitMode = DigitMode.auto})
    : _language = initial ?? kLanguages.first;

  AppLanguage get language => _language;
  DigitMode get digitMode => _digitMode;

  DigitSet get digits => switch (_digitMode) {
    DigitMode.auto => _language.defaultDigits,
    DigitMode.western => DigitSet.western,
    DigitMode.native => _language.nativeDigits,
  };

  /// Formats a number (or any text containing digits) for display.
  String n(Object value) => localizeDigits(value.toString(), digits);

  set language(AppLanguage value) {
    if (value == _language) return;
    _language = value;
    notifyListeners();
  }

  set digitMode(DigitMode value) {
    if (value == _digitMode) return;
    _digitMode = value;
    notifyListeners();
  }
}

/// Makes the [LocaleController] available below it.
class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({
    super.key,
    required LocaleController controller,
    required super.child,
  }) : super(notifier: controller);

  static LocaleController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LocaleScope>()!.notifier!;
}
