import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/palette.dart';
import '../i18n/locale_controller.dart';
import '../l10n/app_localizations.dart';
import '../share/share_result.dart';
import 'friend_hints.dart';

/// Out of hints: how to get some (friends), with the invite button.
Future<void> showFriendHintsDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) {
    final t = AppLocalizations.of(context);
    return AlertDialog(
      icon: const Icon(Icons.lightbulb, color: Palette.sun),
      title: Text(t.friendHintsTitle, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t.friendHintsBody(LocaleScope.of(context).n(FriendHints.dailyMax)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const _TodayCount(),
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
  },
);

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

/// Menu: hints in the bank, today's count and the invite (share) button,
/// in one compact row.
class FriendHintsCard extends StatelessWidget {
  const FriendHintsCard({super.key});

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
            // The hint bank: a bulb with the count on it.
            ListenableBuilder(
              listenable: app.monetization,
              builder: (context, _) => Container(
                key: const ValueKey('hint-bank'),
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Palette.sun,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.white, size: 26),
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.friendHintsTitle,
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
