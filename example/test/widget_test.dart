// Smoke test: boots the Scrivener-like workspace and verifies that the
// binder shows the default project structure and that the README file
// (Research ▸ README) is selected/visible on startup.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('Workspace boots with binder and README selected',
      (WidgetTester tester) async {
    // Desktop-like viewport so MiddlewareView renders the desktop view.
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());

    // QuillSimpleToolbar starts a periodic timer in initState.
    // pumpAndSettle drains pending timers so _verifyInvariants does
    // not fail at the end of the test.
    await tester.pumpAndSettle();

    // Binder header (project name).
    expect(find.text('The Hollow Forest'), findsWidgets);

    // Default root directories from default_files_nodes.dart.
    expect(find.text('Manuscript'), findsOneWidget);
    // 'Research' appears twice: binder row + editor breadcrumb
    // (Research ▸ README), since README is the initial selection.
    expect(find.text('Research'), findsNWidgets(2));
    expect(find.text('Characters'), findsOneWidget);
    expect(find.text('Places'), findsOneWidget);

    // README is the initial selection (root.atPath([1, 0])) and its
    // name must appear in the binder and in the editor breadcrumb.
    expect(find.text('README'), findsWidgets);
  });
}
