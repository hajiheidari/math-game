import 'package:flutter/material.dart';
import 'package:numcross_engine/numcross_engine.dart';

import '../app/app_scope.dart';
import '../i18n/language_button.dart';
import '../i18n/locale_controller.dart';
import '../l10n/app_localizations.dart';

/// First-launch age question. Neutral on purpose: nothing is preselected and
/// nothing hints that a higher age unlocks anything.
class AgeGateScreen extends StatefulWidget {
  const AgeGateScreen({super.key});

  /// Ages offered in the picker.
  static const int minPickable = 5, maxPickable = 99;

  @override
  State<AgeGateScreen> createState() => _AgeGateScreenState();
}

class _AgeGateScreenState extends State<AgeGateScreen> {
  int? _age;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = LocaleScope.of(context);
    return Scaffold(
      appBar: AppBar(actions: const [LanguageButton(), SizedBox(width: 8)]),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    t.ageGateTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<int>(
                    key: const ValueKey('age-picker'),
                    initialValue: _age,
                    hint: Text(t.ageGatePickerHint),
                    menuMaxHeight: 360,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (
                        var a = AgeGateScreen.minPickable;
                        a <= AgeGateScreen.maxPickable;
                        a++
                      )
                        DropdownMenuItem(value: a, child: Text(locale.n(a))),
                    ],
                    onChanged: (a) => setState(() => _age = a),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const ValueKey('age-continue'),
                    onPressed: _age == null
                        ? null
                        : () => AppScope.of(context).submitAge(_age!),
                    child: Text(t.ageGateContinue),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown forever (on this device) after an under-13 answer. No way back.
class BlockedScreen extends StatelessWidget {
  const BlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = LocaleScope.of(context);
    return Scaffold(
      appBar: AppBar(actions: const [LanguageButton(), SizedBox(width: 8)]),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              t.ageGateBlocked(locale.n(kMinimumAge)),
              key: const ValueKey('blocked-message'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
      ),
    );
  }
}
