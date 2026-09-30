import 'package:numcross_engine/numcross_engine.dart';

import '../l10n/app_localizations.dart';
import 'locale_controller.dart';

/// Localized age-band name, e.g. "13–15" / "۱۳ تا ۱۵ سال" / "18+".
String bandLabel(
  AppLocalizations t,
  LocaleController locale,
  BandConfig band,
) => band.maxAge == null
    ? t.bandAndUp(locale.n(band.minAge))
    : t.bandRange(locale.n(band.minAge), locale.n(band.maxAge!));

String difficultyName(AppLocalizations t, Difficulty d) => switch (d) {
  Difficulty.easy => t.difficultyEasy,
  Difficulty.medium => t.difficultyMedium,
  Difficulty.hard => t.difficultyHard,
  Difficulty.expert => t.difficultyExpert,
};
