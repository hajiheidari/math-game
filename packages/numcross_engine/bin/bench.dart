// Generation speed and shape stats for every band x difficulty.
//   dart run bin/bench.dart [levelsPerConfig]
import 'package:numcross_engine/numcross_engine.dart';

void main(List<String> args) {
  final n = args.isNotEmpty ? int.parse(args[0]) : 50;
  print('band   difficulty  avg ms  p95 ms  max ms  eqs    blank%  decoys');
  for (final band in kBands) {
    for (final d in Difficulty.values) {
      final times = <int>[];
      var eqs = 0, blanks = 0.0, decoys = 0;
      for (var level = 1; level <= n; level++) {
        final sw = Stopwatch()..start();
        final p = generateLevel(band, d, level);
        times.add(sw.elapsedMicroseconds);
        eqs += p.slots.length;
        blanks += p.blanks.length / p.solution.length;
        decoys += p.decoyCount;
      }
      times.sort();
      String ms(int us) => (us / 1000).toStringAsFixed(1).padLeft(6);
      final avg = times.reduce((a, b) => a + b) ~/ n;
      print('${band.id.padRight(6)} ${d.name.padRight(10)} ${ms(avg)}  '
          '${ms(times[(n * 0.95).floor().clamp(0, n - 1)])}  ${ms(times.last)}  '
          '${(eqs / n).toStringAsFixed(1).padLeft(5)}  '
          '${(blanks / n * 100).toStringAsFixed(0).padLeft(5)}%  '
          '${(decoys / n).toStringAsFixed(1).padLeft(5)}');
    }
  }
}
