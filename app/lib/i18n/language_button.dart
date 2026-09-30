import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'languages.dart';
import 'locale_controller.dart';

/// App-bar button to switch language (usable before the age gate too).
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = LocaleScope.of(context);
    return PopupMenuButton<AppLanguage>(
      key: const ValueKey('language-button'),
      tooltip: AppLocalizations.of(context).language,
      icon: const Icon(Icons.translate),
      initialValue: locale.language,
      onSelected: (l) => locale.language = l,
      itemBuilder: (_) => [
        for (final l in kLanguages)
          PopupMenuItem(value: l, child: Text(l.nativeName)),
      ],
    );
  }
}
