/// Seeded pseudo-random generator (Mulberry32).
///
/// Implemented with 16-bit partial products so it gives identical results on
/// the Dart VM (Android/iOS) and on the web. `dart:math` Random makes no
/// cross-platform or cross-version guarantee, which would break
/// "same level number => same puzzle".
class SeededRandom {
  static const int _mask = 0xFFFFFFFF;
  int _state;

  SeededRandom(int seed) : _state = seed & _mask;

  /// 32-bit multiply, low 32 bits (like JavaScript's Math.imul, unsigned).
  static int imul(int a, int b) {
    final al = a & 0xFFFF, ah = (a >> 16) & 0xFFFF;
    final bl = b & 0xFFFF, bh = (b >> 16) & 0xFFFF;
    final hi = ((ah * bl + al * bh) & 0xFFFF) * 65536;
    return (hi + al * bl) & _mask;
  }

  int nextUint32() {
    _state = (_state + 0x6D2B79F5) & _mask;
    var t = _state;
    t = imul(t ^ (t >> 15), t | 1);
    t = (t ^ ((t + imul(t ^ (t >> 7), t | 61)) & _mask)) & _mask;
    return (t ^ (t >> 14)) & _mask;
  }

  /// Uniform double in [0, 1).
  double nextDouble() => nextUint32() / 4294967296.0;

  /// Uniform int in [0, max).
  int nextInt(int max) {
    assert(max > 0);
    return (nextDouble() * max).floor();
  }

  /// Uniform int in [lo, hi] (inclusive).
  int range(int lo, int hi) {
    assert(lo <= hi);
    return lo + nextInt(hi - lo + 1);
  }

  bool chance(double p) => nextDouble() < p;

  T pick<T>(List<T> items) => items[nextInt(items.length)];

  void shuffle<T>(List<T> items) {
    for (var i = items.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final tmp = items[i];
      items[i] = items[j];
      items[j] = tmp;
    }
  }

  /// Index chosen with probability proportional to [weights].
  int weightedIndex(List<double> weights) {
    var total = 0.0;
    for (final w in weights) {
      total += w;
    }
    var roll = nextDouble() * total;
    for (var i = 0; i < weights.length; i++) {
      roll -= weights[i];
      if (roll < 0) return i;
    }
    return weights.length - 1;
  }
}
