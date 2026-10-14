import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../certificates/certificate_painter.dart';
import '../certificates/certificates.dart';
import '../i18n/dates.dart';
import '../i18n/jalali.dart';
import '../i18n/locale_controller.dart';
import '../l10n/app_localizations.dart';
import '../rewards/friend_hints.dart';
import '../share/share_result.dart';

/// Title and line of a certificate, in the current language.
(String, String) certWords(AppLocalizations t, LocaleController l, CertKind k) {
  final n = l.n(k.goal);
  return switch (k) {
    CertKind.streak7 ||
    CertKind.streak30 ||
    CertKind.streak100 => (t.certStreakTitle(n), t.certStreakBody(n)),
    CertKind.levels25 ||
    CertKind.levels100 ||
    CertKind.levels250 => (t.certLevelsTitle(n), t.certLevelsBody(n)),
    CertKind.expert10 => (t.certExpertTitle, t.certExpertBody(n)),
    CertKind.allDaily => (t.certAllDailyTitle, t.certAllDailyBody),
  };
}

CertificateTexts certTexts(
  AppLocalizations t,
  LocaleController locale,
  Cert cert,
  String name,
) {
  final (heading, body) = certWords(t, locale, cert.kind);
  final year = usesJalali(locale)
      ? JalaliDate.fromGregorian(cert.date).year
      : cert.date.year;
  return CertificateTexts(
    certificate: t.certCertificate,
    ofAchievement: t.certOfAchievement,
    heading: heading,
    presentedTo: t.certPresentedTo,
    name: name.isEmpty ? t.certNoName : name,
    body: body,
    date: formatLongDate(locale, cert.date),
    brand: t.appTitle,
    tagline: t.certTagline,
    site: FriendHints.siteFor(Uri.base).replaceFirst('https://', ''),
    medalYear: locale.n(year),
  );
}

/// The certificates: earned ones to open and share, the others with how far
/// along the player is.
class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  late final TextEditingController _name;
  Timer? _saveName;

  @override
  void initState() {
    super.initState();
    final certs = context
        .getInheritedWidgetOfExactType<AppScope>()!
        .notifier!
        .certificates;
    _name = TextEditingController(text: certs.name);
    WidgetsBinding.instance.addPostFrameCallback((_) => certs.markSeen());
  }

  @override
  void dispose() {
    _saveName?.cancel();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = LocaleScope.of(context);
    final app = AppScope.of(context);
    final certs = app.certificates;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(t.certificates)),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: certs,
          builder: (context, _) {
            final m = Milestones.of(app.progress);
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  key: const ValueKey('cert-name'),
                  controller: _name,
                  maxLength: 24,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: t.certNameLabel,
                    helperText: t.certNameHelp,
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v) {
                    _saveName?.cancel();
                    _saveName = Timer(
                      const Duration(milliseconds: 400),
                      () => certs.setName(v),
                    );
                  },
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 9 / 16,
                  children: [
                    for (final k in CertKind.values)
                      if (certs.of(k) case final cert?)
                        InkWell(
                          key: ValueKey('cert-${k.name}'),
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => CertificateView(cert: cert),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CustomPaint(
                              painter: CertificatePainter(
                                certTexts(t, locale, cert, certs.name),
                                locale.language,
                              ),
                            ),
                          ),
                        )
                      else
                        _Locked(
                          kind: k,
                          progress: m.progress(k),
                          name: certs.name,
                        ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  t.certHowTo,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A certificate not earned yet: the real design, faded and locked, with how
/// far along the player is, so they see what they are working towards.
class _Locked extends StatelessWidget {
  final CertKind kind;
  final int progress;
  final String name;
  const _Locked({
    required this.kind,
    required this.progress,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = LocaleScope.of(context);
    final text = Theme.of(context).textTheme;
    final shown = progress.clamp(0, kind.goal);
    final n = DateTime.now();
    final preview = CertificatePainter(
      certTexts(t, locale, Cert(kind, DateTime(n.year, n.month, n.day)), name),
      locale.language,
    );
    return ClipRRect(
      key: ValueKey('cert-locked-${kind.name}'),
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Faded, mostly grey: clearly not yours yet.
          Opacity(
            opacity: 0.55,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.5, 0.4, 0.1, 0, 0, //
                0.3, 0.6, 0.1, 0, 0, //
                0.3, 0.4, 0.3, 0, 0, //
                0, 0, 0, 1, 0, //
              ]),
              child: CustomPaint(painter: preview),
            ),
          ),
          PositionedDirectional(
            top: 8,
            end: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock, color: Colors.white, size: 20),
            ),
          ),
          PositionedDirectional(
            start: 8,
            end: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    certWords(t, locale, kind).$1,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: text.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: shown / kind.goal,
                    color: const Color(0xFFE9C46A),
                    backgroundColor: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${locale.n(shown)}/${locale.n(kind.goal)}',
                    style: text.labelMedium?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One certificate, full size, with the share (story) button.
class CertificateView extends StatefulWidget {
  final Cert cert;
  const CertificateView({super.key, required this.cert});

  @override
  State<CertificateView> createState() => _CertificateViewState();
}

class _CertificateViewState extends State<CertificateView> {
  bool _busy = false;
  bool _copied = false;

  Future<void> _share(CertificatePainter painter, String text) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    setState(() => _busy = true);
    final png = kIsWeb ? null : await painter.png();
    final outcome = await shareText(text, png: png, origin: origin);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _copied = outcome == ShareOutcome.copied;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = LocaleScope.of(context);
    final app = AppScope.of(context);
    final certs = app.certificates;
    final texts = certTexts(t, locale, widget.cert, certs.name);
    final painter = CertificatePainter(texts, locale.language);
    final link = app.hints.link(Uri.base);
    final message = [
      '${texts.heading} 🏅 ${certs.name}'.trim(),
      t.certShareLine,
      link,
    ].join('\n');
    return Scaffold(
      backgroundColor: const Color(0xFF062B29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF062B29),
        foregroundColor: Colors.white,
        title: Text(texts.heading),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CustomPaint(
                        key: const ValueKey('certificate'),
                        painter: painter,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const ValueKey('share-cert'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE9C46A),
                    foregroundColor: const Color(0xFF062B29),
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: _busy ? null : () => _share(painter, message),
                  icon: Icon(_copied ? Icons.check : Icons.ios_share_rounded),
                  label: Text(
                    _copied ? t.shareCopied : t.certShare,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "You earned a certificate!": opens it (to share as a story) or later.
Future<void> showNewCertificates(BuildContext context, List<Cert> certs) async {
  final t = AppLocalizations.of(context);
  final locale = LocaleScope.of(context);
  final open = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(
        Icons.workspace_premium,
        size: 48,
        color: Color(0xFFD4A537),
      ),
      title: Text(t.certEarned, textAlign: TextAlign.center),
      content: Text(
        [for (final c in certs) certWords(t, locale, c.kind).$1].join('\n'),
        key: const ValueKey('cert-earned'),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(t.later),
        ),
        FilledButton(
          key: const ValueKey('open-cert'),
          onPressed: () => Navigator.pop(context, true),
          child: Text(t.certOpen),
        ),
      ],
    ),
  );
  if (open != true || !context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => CertificateView(cert: certs.first)),
  );
}
