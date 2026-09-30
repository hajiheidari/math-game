import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../i18n/dates.dart';
import '../i18n/locale_controller.dart';
import '../l10n/app_localizations.dart';

/// Streaks and a month calendar of days with a solved daily puzzle.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _offset = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = LocaleScope.of(context);
    final app = AppScope.of(context);
    final store = app.progress;
    final today = app.today;
    final solved = store.solvedDays();
    final month = calendarMonth(context, locale, today, _offset);
    final streak = store.currentStreak(today);
    final ml = MaterialLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(t.calendar)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Color(0xFFE8672A),
                  size: 32,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.streakDays(streak, locale.n(streak)),
                        key: const ValueKey('calendar-streak'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(t.bestStreak(locale.n(store.bestStreak()))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                IconButton(
                  tooltip: ml.previousMonthTooltip,
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => _offset--),
                ),
                Expanded(
                  child: Text(
                    month.title,
                    key: const ValueKey('month-title'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: ml.nextMonthTooltip,
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _offset < 0
                      ? () => setState(() => _offset++)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final w in weekdayLabels(context, locale))
                  Center(
                    child: Text(
                      w,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ),
                for (var i = 0; i < month.leadingBlanks; i++) const SizedBox(),
                for (var i = 0; i < month.days.length; i++)
                  _DayCell(
                    label: locale.n(month.dayNumbers[i]),
                    solved: solved.contains(month.days[i]),
                    isToday: month.days[i] == today,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final String label;
  final bool solved;
  final bool isToday;
  const _DayCell({
    required this.label,
    required this.solved,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(3),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: solved ? s.primary : null,
          border: isToday ? Border.all(color: s.primary, width: 2) : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: solved ? s.onPrimary : s.onSurface,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
