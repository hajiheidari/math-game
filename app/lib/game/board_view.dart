import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:numcross_engine/numcross_engine.dart';

import '../i18n/locale_controller.dart';

typedef NumberCellBuilder = Widget Function(
  BuildContext context,
  Pos pos,
  double size,
);

/// Positions a puzzle's cells; number cells come from [numberCell].
///
/// The grid is always laid out left-to-right, top-to-bottom, even when the
/// app runs in an RTL language: equations are read "7 + 5 = 12" in Persian,
/// Arabic and Urdu school math too, and mirroring would turn "12 − 5 = 7"
/// into "7 = 5 − 12". Only the digits change with the language.
class BoardGrid extends StatelessWidget {
  final Puzzle puzzle;
  final NumberCellBuilder numberCell;
  final double maxCellSize;

  const BoardGrid({
    super.key,
    required this.puzzle,
    required this.numberCell,
    this.maxCellSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final byWidth = constraints.maxWidth / puzzle.cols;
          final byHeight = constraints.hasBoundedHeight
              ? constraints.maxHeight / puzzle.rows
              : double.infinity;
          final size = math.min(byWidth, byHeight).clamp(16.0, maxCellSize);
          return SizedBox(
            width: size * puzzle.cols,
            height: size * puzzle.rows,
            child: Stack(
              children: [
                for (var r = 0; r < puzzle.rows; r++)
                  for (var c = 0; c < puzzle.cols; c++)
                    if (puzzle.cellAt(Pos(r, c)) case final info
                        when info.kind != CellKind.empty)
                      Positioned(
                        left: c * size,
                        top: r * size,
                        width: size,
                        height: size,
                        child: info.kind == CellKind.number
                            ? numberCell(context, Pos(r, c), size)
                            : Center(
                                child: Text(
                                  info.kind == CellKind.equals
                                      ? '='
                                      : info.op!.symbol,
                                  style: TextStyle(
                                    fontSize: size * 0.5,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}

enum CellTone { given, blank, selected, hover, filled, hinted, error }

/// Look of one number cell.
class CellFace extends StatelessWidget {
  final String text;
  final CellTone tone;
  final double size;

  const CellFace({
    super.key,
    required this.text,
    required this.tone,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final (
      Color bg,
      Color fg,
      Color? border,
      double borderWidth,
    ) = switch (tone) {
      CellTone.given => (s.surfaceContainerHighest, s.onSurface, null, 0.0),
      CellTone.blank => (
        s.primaryContainer.withValues(alpha: 0.55),
        s.onPrimaryContainer,
        s.primary,
        1.2,
      ),
      CellTone.selected => (
        s.primaryContainer,
        s.onPrimaryContainer,
        s.primary,
        2.6,
      ),
      CellTone.hover => (
        s.secondaryContainer,
        s.onSecondaryContainer,
        s.secondary,
        2.6,
      ),
      CellTone.filled => (s.primary, s.onPrimary, null, 0.0),
      CellTone.hinted => (s.tertiary, s.onTertiary, null, 0.0),
      CellTone.error => (s.errorContainer, s.onErrorContainer, s.error, 2.6),
    };
    final face = Padding(
      padding: EdgeInsets.all(size * 0.05),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(size * 0.18),
          border: border != null
              ? Border.all(color: border, width: borderWidth)
              : null,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.w600,
                  color: fg,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // A placed tile "lands" with a small pop (skipped for reduced motion).
    final placed = tone == CellTone.filled || tone == CellTone.hinted;
    if (!placed || MediaQuery.of(context).disableAnimations) return face;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.7, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: face,
    );
  }
}

/// Read-only board (design preview).
class BoardView extends StatelessWidget {
  final Puzzle puzzle;
  final bool showSolution;

  const BoardView({super.key, required this.puzzle, this.showSolution = false});

  @override
  Widget build(BuildContext context) {
    final locale = LocaleScope.of(context);
    final blanks = puzzle.blanks.toSet();
    return BoardGrid(
      puzzle: puzzle,
      maxCellSize: 56,
      numberCell: (context, pos, size) {
        final blank = blanks.contains(pos);
        return CellFace(
          text: blank && !showSolution ? '' : locale.n(puzzle.solution[pos]!),
          tone: blank ? CellTone.blank : CellTone.given,
          size: size,
        );
      },
    );
  }
}
