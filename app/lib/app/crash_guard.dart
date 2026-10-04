import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows any uncaught error on screen instead of a blank or frozen app,
/// with the stack trace and a Copy button, so testers can send it back.
///
/// Native Android crashes (before Dart runs) are shown by CrashActivity on
/// the Kotlin side instead.
class CrashGuard {
  CrashGuard._();

  static final ValueNotifier<String?> report = ValueNotifier(null);

  /// Runs [body] (which should end in runApp) with every error hook set.
  /// If [body] itself throws, an error-only app is started instead.
  static void run(Future<void> Function() body) {
    runZonedGuarded(() async {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        _record(details.exception, details.stack, details.context);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        _record(error, stack);
        return true;
      };
      ErrorWidget.builder = (details) => _InlineError(details.exception);
      try {
        await body();
      } catch (e, s) {
        _record(e, s, 'while starting the app');
        runApp(const CrashView(fatal: true));
      }
    }, (error, stack) => _record(error, stack));
  }

  static void _record(Object error, StackTrace? stack, [Object? context]) {
    // Keep the first error: later ones are usually knock-on effects.
    if (report.value != null) return;
    final b = StringBuffer()
      ..writeln('Adadi error report')
      ..writeln(
        'Platform: ${defaultTargetPlatform.name}, '
        'release: $kReleaseMode',
      )
      ..writeln();
    if (context != null) b.writeln('Context: $context');
    b
      ..writeln('Error: $error')
      ..writeln()
      ..writeln(stack ?? '(no stack trace)');
    report.value = b.toString();
  }
}

/// Wraps the app: shows [child], or the error report on top when one exists.
class CrashOverlay extends StatelessWidget {
  final Widget child;
  const CrashOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: CrashGuard.report,
      builder: (context, report, _) => report == null
          ? child
          : Stack(
              textDirection: TextDirection.ltr,
              children: [child, const CrashView(fatal: false)],
            ),
    );
  }
}

/// Self-contained error screen (own MaterialApp, English, LTR) so it works
/// even when the app's own localization or theme is what failed.
class CrashView extends StatelessWidget {
  final bool fatal;
  const CrashView({super.key, required this.fatal});

  @override
  Widget build(BuildContext context) {
    final text = CrashGuard.report.value ?? 'Unknown error';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFFFFF4F2),
          appBar: AppBar(
            backgroundColor: const Color(0xFFB3261E),
            foregroundColor: Colors.white,
            title: const Text('Something went wrong'),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Please tap Copy and send this report to the developer.\n'
                    'لطفاً «Copy» را بزنید و این گزارش را برای سازنده بفرستید.',
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      text,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy'),
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: text));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copied')),
                              );
                            }
                          },
                        ),
                      ),
                      if (!fatal) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => CrashGuard.report.value = null,
                            child: const Text('Continue'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Replaces Flutter's grey release-mode error box inside a broken widget.
class _InlineError extends StatelessWidget {
  final Object error;
  const _InlineError(this.error);

  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFFFFDAD6),
    padding: const EdgeInsets.all(8),
    child: Text(
      '$error',
      textDirection: TextDirection.ltr,
      style: const TextStyle(color: Color(0xFF410002), fontSize: 12),
    ),
  );
}
