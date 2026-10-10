import 'package:flutter/material.dart';

import '../app/app_scope.dart';
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
      icon: const Icon(Icons.lightbulb, color: Color(0xFFF2B01E)),
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

/// Shares the invite message; says "Copied" when it went to the clipboard.
class InviteButton extends StatefulWidget {
  const InviteButton({super.key});

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
      icon: Icon(_copied ? Icons.check : Icons.person_add_alt_1),
      label: Text(_copied ? t.shareCopied : t.inviteFriends),
    );
  }
}

/// Menu: hints in the bank, today's count and the invite button.
class FriendHintsCard extends StatelessWidget {
  const FriendHintsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = LocaleScope.of(context);
    final app = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      key: const ValueKey('friend-hints-card'),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Color(0xFFF2B01E)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t.friendHintsTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ListenableBuilder(
                  listenable: app.monetization,
                  builder: (context, _) => Chip(
                    key: const ValueKey('hint-bank'),
                    avatar: Icon(
                      Icons.lightbulb_outline,
                      color: scheme.primary,
                    ),
                    label: Text(locale.n(app.monetization.coins)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              t.friendHintsBody(locale.n(FriendHints.dailyMax)),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: const [InviteButton(), _TodayCount()],
            ),
          ],
        ),
      ),
    );
  }
}
