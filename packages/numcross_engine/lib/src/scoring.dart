import 'config.dart';

/// Stars for a completed level: 3 = no mistakes within par time,
/// 2 = at most one mistake within double par, 1 = completed.
int computeStars(DifficultyConfig cfg, {required int mistakes, required int seconds}) {
  if (mistakes == 0 && seconds <= cfg.parTimeSeconds) return 3;
  if (mistakes <= 1 && seconds <= cfg.parTimeSeconds * 2) return 2;
  return 1;
}

/// True when [mistakes] ends the level.
bool isOutOfMistakes(DifficultyConfig cfg, int mistakes) =>
    cfg.mistakesAllowed != null && mistakes >= cfg.mistakesAllowed!;
