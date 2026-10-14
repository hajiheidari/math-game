import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../i18n/locale_controller.dart';
import '../l10n/app_localizations.dart';
import 'board_view.dart';
import 'game_controller.dart';

/// Interactive grid: drop or tap tiles onto blank cells.
class GameBoard extends StatelessWidget {
  final GameController game;
  const GameBoard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final locale = LocaleScope.of(context);
    final puzzle = game.puzzle;
    return BoardGrid(
      puzzle: puzzle,
      numberCell: (context, pos, size) {
        final value = puzzle.solution[pos]!;
        if (!game.isBlank(pos)) {
          return CellFace(
            text: locale.n(value),
            tone: CellTone.given,
            size: size,
          );
        }
        if (game.isFilled(pos)) {
          return CellFace(
            key: ValueKey('cell-${pos.row}-${pos.col}'),
            text: locale.n(value),
            tone: game.isHinted(pos) ? CellTone.hinted : CellTone.filled,
            size: size,
          );
        }
        return DragTarget<int>(
          key: ValueKey('cell-${pos.row}-${pos.col}'),
          onWillAcceptWithDetails: (d) => !game.isTileUsed(d.data),
          onAcceptWithDetails: (d) => game.place(d.data, pos),
          builder: (context, candidates, _) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => game.tapCell(pos),
            child: _Shake(
              // Restart the shake on every new mistake.
              key: ValueKey(game.errorCell == pos ? game.mistakes : -1),
              active: game.errorCell == pos,
              distance: size * 0.12,
              child: CellFace(
                text: '',
                size: size,
                tone: game.errorCell == pos
                    ? CellTone.error
                    : candidates.isNotEmpty
                    ? CellTone.hover
                    : game.selectedCell == pos
                    ? CellTone.selected
                    : CellTone.blank,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Large boards (hard and expert) can be zoomed: pinch, or the zoom button
/// (2x around the middle, then pan with a finger). Tiles still drop onto
/// the zoomed cells. Small boards are shown as they are.
class ZoomableBoard extends StatefulWidget {
  final GameController game;
  const ZoomableBoard({super.key, required this.game});

  /// Boards at least this many cells wide or tall can be zoomed.
  static const int minCells = 9;

  static bool zoomable(GameController game) =>
      game.puzzle.cols >= minCells || game.puzzle.rows >= minCells;

  @override
  State<ZoomableBoard> createState() => _ZoomableBoardState();
}

class _ZoomableBoardState extends State<ZoomableBoard> {
  final _zoom = TransformationController();
  Size _viewport = Size.zero;

  @override
  void initState() {
    super.initState();
    _zoom.addListener(_changed);
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  bool get _zoomed => _zoom.value.getMaxScaleOnAxis() > 1.01;

  void _toggle() {
    if (_zoomed) {
      _zoom.value = Matrix4.identity();
      return;
    }
    const scale = 2.0;
    final c = _viewport.center(Offset.zero);
    _zoom.value = Matrix4.identity()
      ..translateByDouble(c.dx * (1 - scale), c.dy * (1 - scale), 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    final board = GameBoard(game: widget.game);
    if (!ZoomableBoard.zoomable(widget.game)) return Center(child: board);
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewport = constraints.biggest;
        return Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                key: const ValueKey('board-zoom'),
                transformationController: _zoom,
                minScale: 1,
                maxScale: 3,
                child: Center(child: board),
              ),
            ),
            PositionedDirectional(
              end: 0,
              bottom: 0,
              child: Material(
                color: scheme.surfaceContainerHigh.withValues(alpha: 0.92),
                shape: CircleBorder(
                  side: BorderSide(color: scheme.outlineVariant),
                ),
                child: IconButton(
                  key: const ValueKey('zoom'),
                  tooltip: _zoomed ? t.zoomOut : t.zoomIn,
                  icon: Icon(_zoomed ? Icons.zoom_out : Icons.zoom_in),
                  onPressed: _toggle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The tiles to place, with a sort toggle.
class TileBank extends StatelessWidget {
  final GameController game;

  /// Called when a tile is picked up or selected (for sound/vibration).
  final VoidCallback? onPick;

  const TileBank({super.key, required this.game, this.onPick});

  static const double tileWidth = 56, tileHeight = 48;

  /// Banks with more tiles than this use smaller tiles, so a big board keeps
  /// more of the screen.
  static const int compactAbove = 12;

  bool get _compact => game.bankOrder.length > compactAbove;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(t.tiles, style: Theme.of(context).textTheme.labelLarge),
                const Spacer(),
                TextButton.icon(
                  key: const ValueKey('sort'),
                  onPressed: game.toggleSort,
                  icon: Icon(game.isSorted ? Icons.shuffle : Icons.sort),
                  label: Text(t.sortBank),
                ),
              ],
            ),
            // Tiles may flow RTL; every number is its own LTR digit run.
            Wrap(
              alignment: WrapAlignment.center,
              spacing: _compact ? 6 : 8,
              runSpacing: _compact ? 6 : 8,
              children: [for (final i in game.bankOrder) _tile(context, i)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, int index) {
    final locale = LocaleScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = locale.n(game.tileValue(index));
    if (game.isTileUsed(index)) {
      // Keep the slot so the other tiles don't jump around.
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: SizedBox(
          width: _compact ? TileFace.compactWidth : tileWidth,
          height: _compact ? TileFace.compactHeight : tileHeight,
        ),
      );
    }
    final face = TileFace(
      text: text,
      selected: game.selectedTile == index,
      compact: _compact,
    );
    return Draggable<int>(
      key: ValueKey('tile-$index'),
      data: index,
      feedback: Material(
        type: MaterialType.transparency,
        child: Transform.scale(
          scale: 1.12,
          child: TileFace(text: text, selected: true, lifted: true),
        ),
      ),
      onDragStarted: onPick,
      childWhenDragging: Opacity(opacity: 0.3, child: face),
      child: GestureDetector(
        onTap: () {
          onPick?.call();
          game.tapTile(index);
        },
        child: face,
      ),
    );
  }
}

/// Look of one bank tile.
class TileFace extends StatelessWidget {
  final String text;
  final bool selected;
  final bool lifted;

  /// Smaller tile for long banks ([TileBank.compactAbove]).
  final bool compact;
  static const double compactWidth = 48, compactHeight = 40;

  const TileFace({
    super.key,
    required this.text,
    this.selected = false,
    this.lifted = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: compact ? compactWidth : TileBank.tileWidth,
      height: compact ? compactHeight : TileBank.tileHeight,
      decoration: BoxDecoration(
        color: selected ? s.primary : s.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? s.primary : s.outlineVariant,
          width: 1.5,
        ),
        // A soft shadow: tiles look like pieces to pick up.
        boxShadow: [
          BoxShadow(
            blurRadius: lifted ? 12 : 4,
            offset: Offset(0, lifted ? 4 : 2),
            color: Color(lifted ? 0x33000000 : 0x14000000),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            text,
            style: numeralStyle(context).copyWith(
              fontSize: compact ? 18 : 20,
              fontWeight: FontWeight.w600,
              color: selected ? s.onPrimary : s.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal shake (wrong tile). Skipped when the OS asks for reduced motion.
class _Shake extends StatelessWidget {
  final bool active;
  final double distance;
  final Widget child;

  const _Shake({
    super.key,
    required this.active,
    required this.distance,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!active || MediaQuery.of(context).disableAnimations) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 380),
      builder: (context, t, child) => Transform.translate(
        offset: Offset(math.sin(t * math.pi * 6) * (1 - t) * distance, 0),
        child: child,
      ),
      child: child,
    );
  }
}
