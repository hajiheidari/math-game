import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numcross/app/crash_guard.dart';

void main() {
  tearDown(() => CrashGuard.report.value = null);

  testWidgets('error report covers the app and can be dismissed', (
    tester,
  ) async {
    await tester.pumpWidget(
      const CrashOverlay(child: MaterialApp(home: Text('game'))),
    );
    expect(find.text('Something went wrong'), findsNothing);

    CrashGuard.report.value = 'Error: boom\n#0 main';
    await tester.pump();
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.textContaining('boom'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Something went wrong'), findsNothing);
    expect(find.text('game'), findsOneWidget);
  });
}
