import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:numcross_engine/numcross_engine.dart';

import '../app/app_scope.dart';
import '../i18n/digits.dart';
import '../i18n/labels.dart';
import '../i18n/languages.dart';
import '../i18n/locale_controller.dart';
import '../l10n/app_localizations.dart';
import '../monetization/ad_config.dart';
import '../preview_screen.dart';
import 'backup_section.dart';
import 'tutorial_screen.dart';

import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = LocaleScope.of(context);
    final app = AppScope.of(context);
    final textTheme = Theme.of(context).textTheme;

    Widget header(String text) => Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 8),
      child: Text(text, style: textTheme.titleSmall),
    );

    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: SafeArea(
        child: ListView(
          children: [
            header(t.language),
            RadioGroup<AppLanguage>(
              groupValue: locale.language,
              onChanged: (l) => locale.language = l!,
              child: Column(
                children: [
                  for (final l in kLanguages)
                    RadioListTile<AppLanguage>(
                      key: ValueKey('lang-${l.code}'),
                      value: l,
                      title: Text(l.nativeName),
                    ),
                ],
              ),
            ),
            // Only languages with their own digits get a choice (English has
            // nothing to switch, so the option looked broken there).
            if (locale.language.nativeDigits != DigitSet.western) ...[
              header(t.digits),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (set, mode, label) in [
                      (
                        locale.language.nativeDigits,
                        DigitMode.native,
                        '${t.digitsNative} (${localizeDigits('123', locale.language.nativeDigits)})',
                      ),
                      (
                        DigitSet.western,
                        DigitMode.western,
                        '${t.digitsWestern} (123)',
                      ),
                    ])
                      ChoiceChip(
                        key: ValueKey('digits-${mode.name}'),
                        label: Text(label),
                        selected: locale.digits == set,
                        onSelected: (_) => locale.digitMode = mode,
                      ),
                  ],
                ),
              ),
            ],
            header(t.ageGroup),
            RadioGroup<BandConfig>(
              groupValue: app.band,
              onChanged: (b) => app.setBand(b!),
              child: Column(
                children: [
                  // Only 13+ bands exist in this app, so every band is offered.
                  for (final b in kBands)
                    RadioListTile<BandConfig>(
                      key: ValueKey('band-${b.id}'),
                      value: b,
                      title: Text(bandLabel(t, locale, b)),
                    ),
                ],
              ),
            ),
            const Divider(height: 32),
            ListenableBuilder(
              listenable: app.feedback,
              builder: (context, _) => Column(
                children: [
                  SwitchListTile(
                    key: const ValueKey('sound'),
                    secondary: const Icon(Icons.volume_up_outlined),
                    title: Text(t.sound),
                    value: app.feedback.soundOn,
                    onChanged: (v) => app.feedback.soundOn = v,
                  ),
                  SwitchListTile(
                    key: const ValueKey('haptics'),
                    secondary: const Icon(Icons.vibration),
                    title: Text(t.haptics),
                    value: app.feedback.hapticsOn,
                    onChanged: (v) => app.feedback.hapticsOn = v,
                  ),
                ],
              ),
            ),
            ListTile(
              key: const ValueKey('how-to-play'),
              leading: const Icon(Icons.school_outlined),
              title: Text(t.tutorialTitle),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const TutorialScreen()),
              ),
            ),
            const Divider(height: 32),
            const BackupSection(),
            const Divider(height: 32),
            const _PurchaseAndPrivacySection(),
            if (kDebugMode) ...[
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.grid_view),
                title: Text(t.previewTitle),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PreviewScreen()),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Consent choices (ad network), the privacy policy and support.
class _PurchaseAndPrivacySection extends StatefulWidget {
  const _PurchaseAndPrivacySection();

  @override
  State<_PurchaseAndPrivacySection> createState() =>
      _PurchaseAndPrivacySectionState();
}

class _PurchaseAndPrivacySectionState
    extends State<_PurchaseAndPrivacySection> {
  bool _privacyOptions = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppScope.of(context).monetization.ads.privacyOptionsRequired().then((v) {
      if (mounted && v != _privacyOptions) setState(() => _privacyOptions = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final money = AppScope.of(context).monetization;
    return Column(
      children: [
        if (_privacyOptions)
          ListTile(
            key: const ValueKey('privacy-choices'),
            leading: const Icon(Icons.tune),
            title: Text(t.privacyChoices),
            onTap: money.ads.showPrivacyOptions,
          ),
        ListTile(
          key: const ValueKey('privacy-policy'),
          leading: const Icon(Icons.privacy_tip_outlined),
          title: Text(t.privacyPolicy),
          onTap: () => launchUrl(
            Uri.parse(kPrivacyPolicyUrl),
            mode: LaunchMode.externalApplication,
          ),
        ),
        ListTile(
          key: const ValueKey('contact-support'),
          leading: const Icon(Icons.mail_outline),
          title: Text(t.contactSupport),
          subtitle: const Text(kSupportEmail, textDirection: TextDirection.ltr),
          onTap: () => launchUrl(
            Uri(
              scheme: 'mailto',
              path: kSupportEmail,
              queryParameters: {'subject': 'Adadi'},
            ),
          ),
        ),
      ],
    );
  }
}
