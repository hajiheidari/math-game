import 'package:flutter_test/flutter_test.dart';
import 'package:numcross/i18n/jalali.dart';

void main() {
  test('known dates', () {
    // Nowruz dates and a mid-year date.
    expect(
      JalaliDate.fromGregorian(DateTime(2024, 3, 20)),
      const JalaliDate(1403, 1, 1),
    );
    expect(
      JalaliDate.fromGregorian(DateTime(2025, 3, 21)),
      const JalaliDate(1404, 1, 1),
    );
    expect(
      JalaliDate.fromGregorian(DateTime(2026, 3, 21)),
      const JalaliDate(1405, 1, 1),
    );
    expect(
      JalaliDate.fromGregorian(DateTime(2026, 9, 30)),
      const JalaliDate(1405, 7, 8),
    );
    expect(
      JalaliDate.fromGregorian(DateTime(1979, 2, 11)),
      const JalaliDate(1357, 11, 22),
    );
  });

  test('leap years and month lengths', () {
    expect(JalaliDate.isLeap(1403), isTrue);
    expect(JalaliDate.isLeap(1404), isFalse);
    expect(JalaliDate.monthLength(1403, 12), 30);
    expect(JalaliDate.monthLength(1404, 12), 29);
    expect(JalaliDate.monthLength(1404, 1), 31);
    expect(JalaliDate.monthLength(1404, 7), 30);
  });

  test('round trip every day for 30 years', () {
    var d = DateTime.utc(2000, 1, 1);
    JalaliDate? prev;
    while (d.year < 2030) {
      final j = JalaliDate.fromGregorian(d);
      final back = j.toGregorian();
      expect([back.year, back.month, back.day], [d.year, d.month, d.day]);
      if (prev != null) {
        final consecutive =
            (j.year == prev.year &&
                j.month == prev.month &&
                j.day == prev.day + 1) ||
            (j.day == 1 &&
                (j.month == prev.month + 1 ||
                    (j.month == 1 && prev.month == 12)));
        expect(consecutive, isTrue, reason: '$prev -> $j');
      }
      prev = j;
      d = d.add(const Duration(days: 1));
    }
  });
}
