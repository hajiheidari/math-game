import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/palette.dart';
import '../i18n/locale_controller.dart';
import '../l10n/app_localizations.dart';
import '../share/share_result.dart';
import 'friend_hints.dart';

/// Out of coins: how to get some. A rewarded ad (where the build has an ad
/// network) or friends opening the player's challenge / invite link.
Future<void> showCoinsDialog(BuildContext context, {ThemeData? theme}) =>
    showDialog<void>(
      context: context,
      builder: (context) {
        final dialog = const _CoinsDialog();
        return theme == null ? dialog : Theme(data: theme, child: dialog);
      },
    );

class _CoinsDialog extends StatefulWidget {
  const _CoinsDialog();

  @override
  State<_CoinsDialog> createState() => _CoinsDialogState();
}

class _CoinsDialogState extends State<_CoinsDialog> {
  bool _watching = false;

  Future<void> _watch() async {
    setState(() => _watching = true);
    final money = AppScope.of(context).monetization;
    final earned = await money.watchAdForCoin();
    if (!mounted) return;
    setState(() => _watching = false);
    if (earned) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = LocaleScope.of(context);
    final money = AppScope.of(context).monetization;
    return AlertDialog(
      icon: const CoinIcon(size: 40),
      title: Text(t.coinsTitle, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t.coinsBody(locale.n(FriendHints.dailyMax)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const _TodayCount(),
          if (money.canWatchAd) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              key: const ValueKey('watch-ad'),
              onPressed: _watching ? null : _watch,
              icon: const Icon(Icons.play_circle_outline),
              label: Text(t.watchAdForCoin, textAlign: TextAlign.center),
            ),
          ],
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
        const InviteButton(),
      ],
    );
  }
}

/// A gold coin with a lightbulb: what a hint costs.
class CoinIcon extends StatelessWidget {
  final double size;
  const CoinIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFDE68A), Palette.sun, Color(0xFFD97706)],
      ),
      border: Border.all(color: const Color(0xFFB45309), width: size * 0.05),
    ),
    child: Icon(Icons.lightbulb, color: Colors.white, size: size * 0.58),
  );
}

/// "Today: 1/3".
class _TodayCount extends StatelessWidget {
  const _TodayCount();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = LocaleScope.of(context);
    final hints = AppScope.of(context).hints;
    return ListenableBuilder(
      listenable: hints,
      builder: (context, _) => Text(
        t.friendHintsToday(
          locale.n(hints.earnedToday),
          locale.n(FriendHints.dailyMax),
        ),
        key: const ValueKey('friend-hints-today'),
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

/// Opens the share sheet with the invite message (says "Copied" only when
/// there is no share sheet, e.g. a desktop browser).
class InviteButton extends StatefulWidget {
  /// "Invite" instead of "Invite friends" (the menu card).
  final bool short;
  const InviteButton({super.key, this.short = false});

  @override
  State<InviteButton> createState() => _InviteButtonState();
}

class _InviteButtonState extends State<InviteButton> {
  bool _copied = false;

  Future<void> _invite() async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    final outcome = await shareInvite(context, origin: origin);
    if (mounted) setState(() => _copied = outcome == ShareOutcome.copied);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return FilledButton.icon(
      key: const ValueKey('invite'),
      onPressed: _invite,
      icon: Icon(_copied ? Icons.check : Icons.ios_share_rounded, size: 20),
      label: Text(
        _copied
            ? t.shareCopied
            : widget.short
            ? t.invite
            : t.inviteFriends,
      ),
    );
  }
}

/// Menu: the player's coins, today's count from friends and the invite
/// (share) button, in one compact row. Tapping the coin opens the coins
/// dialog (rewarded ad, where there is one).
class CoinsCard extends StatelessWidget {
  const CoinsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = LocaleScope.of(context);
    final app = AppScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      key: const ValueKey('friend-hints-card'),
      color: Palette.sun.withValues(alpha: dark ? 0.2 : 0.16),
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            // The coin bank: a coin with the count on it.
            ListenableBuilder(
              listenable: app.monetization,
              builder: (context, _) => InkResponse(
                onTap: () => showCoinsDialog(context),
                child: SizedBox(
                  key: const ValueKey('hint-bank'),
                  width: 50,
                  height: 50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const CoinIcon(size: 46),
                      PositionedDirectional(
                        end: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          constraints: const BoxConstraints(minWidth: 20),
                          decoration: BoxDecoration(
                            color: Palette.ink,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            locale.n(app.monetization.coins),
                            key: const ValueKey('coin-count'),
                            textAlign: TextAlign.center,
                            style: textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.coinsTitle,
                    maxLines: 2,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const _TodayCount(),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const InviteButton(short: true),
          ],
        ),
      ),
    );
  }
}
