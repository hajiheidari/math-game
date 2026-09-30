import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'jalali.dart';
import 'locale_controller.dart';

/// Persian uses the Solar Hijri (Jalali) calendar; other languages use
/// Gregorian with localized month names.
bool usesJalali(LocaleController locale) => locale.language.code == 'fa';

/// "8 Mehr 1405" (fa) / "30 September 2026" (others), digits per setting.
String formatLongDate(LocaleController locale, DateTime date) {
  if (usesJalali(locale)) {
    final j = JalaliDate.fromGregorian(date);
    return '${locale.n(j.day)} ${jalaliMonthNames[j.month - 1]} ${locale.n(j.year)}';
  }
  final code = locale.language.code;
  final month = DateFormat.MMMM(code).format(date);
  return '${locale.n(date.day)} $month ${locale.n(date.year)}';
}

/// One month of a calendar grid, in the user's calendar system.
class CalendarMonth {
  final String title;

  /// Gregorian dates of the month's days, in order.
  final List<DateTime> days;

  /// Empty cells before day 1 (week starts on [firstDayOfWeek]).
  final int leadingBlanks;

  /// Day-of-month labels (1..n in the user's calendar), same order as [days].
  final List<int> dayNumbers;

  const CalendarMonth(
    this.title,
    this.days,
    this.leadingBlanks,
    this.dayNumbers,
  );
}

/// First day of week, 0 = Sunday (MaterialLocalizations convention).
int firstDayOfWeek(BuildContext context, LocaleController locale) =>
    usesJalali(locale)
    ? 6
    : MaterialLocalizations.of(context).firstDayOfWeekIndex;

/// Month [offset] months away from the month containing [today].
CalendarMonth calendarMonth(
  BuildContext context,
  LocaleController locale,
  DateTime today,
  int offset,
) {
  final start = firstDayOfWeek(context, locale);
  int blanksFor(DateTime first) => (first.weekday % 7 - start + 7) % 7;

  if (usesJalali(locale)) {
    final jt = JalaliDate.fromGregorian(today);
    final total = jt.year * 12 + (jt.month - 1) + offset;
    final y = total ~/ 12, m = total % 12 + 1;
    final first = JalaliDate(y, m, 1).toGregorian();
    final n = JalaliDate.monthLength(y, m);
    return CalendarMonth(
      '${jalaliMonthNames[m - 1]} ${locale.n(y)}',
      [
        for (var i = 0; i < n; i++)
          DateTime(first.year, first.month, first.day + i),
      ],
      blanksFor(first),
      [for (var i = 1; i <= n; i++) i],
    );
  }
  final first = DateTime(today.year, today.month + offset, 1);
  final n = DateTime(first.year, first.month + 1, 0).day;
  final month = DateFormat.MMMM(locale.language.code).format(first);
  return CalendarMonth(
    '$month ${locale.n(first.year)}',
    [for (var i = 0; i < n; i++) DateTime(first.year, first.month, i + 1)],
    blanksFor(first),
    [for (var i = 1; i <= n; i++) i],
  );
}

/// Narrow weekday labels in grid order.
List<String> weekdayLabels(BuildContext context, LocaleController locale) {
  final names = MaterialLocalizations.of(context)
      .narrowWeekdays; // Sunday first
  final start = firstDayOfWeek(context, locale);
  return [for (var i = 0; i < 7; i++) names[(start + i) % 7]];
}
