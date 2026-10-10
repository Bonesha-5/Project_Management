import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:project_management/screens/team_screen.dart';
import 'package:project_management/services/storage_service.dart';

void main() {
  // Every test starts with fresh fake storage, so the sample data loads.
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    StorageService.resetCacheForTests();
  });

  Future<void> openTeamScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TeamScreen())),
    );
    await tester.pumpAndSettle();
  }

  // Lets any SnackBar finish, so no timer is left running.
  Future<void> finishSnackBars(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  Future<void> tapSave(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Save Member'));
    await tester.tap(find.text('Save Member'));
    await tester.pumpAndSettle();
  }

  testWidgets('Team Members shows the 5 sample members and all badges', (
    tester,
  ) async {
    await openTeamScreen(tester);
    expect(find.text('Sarah Lee'), findsOneWidget);
    expect(find.text('Emily Wong'), findsOneWidget);
    expect(find.text('Overloaded'), findsOneWidget); // Emily, 5 open
    expect(find.text('Heavy'), findsOneWidget); // Michael, 3 open
    expect(find.text('Balanced'), findsNWidgets(3));
    expect(find.text('QA Tester · 5 open'), findsOneWidget);
  });

  testWidgets('tapping a member shows only their tasks', (tester) async {
    await openTeamScreen(tester);
    await tester.tap(find.text('Emily Wong'));
    await tester.pumpAndSettle();

    expect(find.text('Member Tasks'), findsOneWidget);
    expect(find.text('Open tasks (5)'), findsOneWidget);
    expect(find.text('Create Task Model'), findsOneWidget); // Emily's
    expect(find.text('Design Login Screen'), findsNothing); // Sarah's
  });

  testWidgets('a member with only completed tasks sees "All caught up"', (
    tester,
  ) async {
    await openTeamScreen(tester);
    await tester.tap(find.text('John Doe'));
    await tester.pumpAndSettle();

    expect(find.text('Open tasks (0)'), findsOneWidget);
    expect(find.text('Nothing open. All caught up!'), findsOneWidget);
    expect(find.text('Completed (1)'), findsOneWidget);
  });

  testWidgets('Add Member shows errors, then saves a valid member', (
    tester,
  ) async {
    await openTeamScreen(tester);
    await tester.tap(find.byTooltip('Add member'));
    await tester.pumpAndSettle();
    expect(find.text('Add Member'), findsOneWidget);

    // 1. Empty name is refused.
    await tapSave(tester);
    expect(find.text('Full name is required'), findsOneWidget);

    // 2. A badly written email is refused.
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Grace Uwase');
    await tester.enterText(fields.at(2), 'grace-at-email');
    await tapSave(tester);
    expect(find.textContaining('Enter a valid email'), findsOneWidget);

    // The avatar preview already shows the initials.
    expect(find.text('GU'), findsOneWidget);

    // 3. A valid member is saved and appears in the list.
    await tester.enterText(fields.at(1), 'Backend Developer');
    await tester.enterText(fields.at(2), 'grace@email.com');
    await tapSave(tester);

    expect(find.text('Team Members'), findsOneWidget);
    expect(find.text('Grace Uwase'), findsOneWidget);
    expect(find.text('Backend Developer · 0 open'), findsOneWidget);
    expect((await StorageService.getMembers()).length, 6);
    await finishSnackBars(tester);
  });

  testWidgets('Add Member refuses an email that is already used', (
    tester,
  ) async {
    await openTeamScreen(tester);
    await tester.tap(find.byTooltip('Add member'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Another Sarah');
    await tester.enterText(fields.at(2), 'sarah@email.com');
    await tapSave(tester);

    expect(find.text('This email is already used by a member'), findsOneWidget);
    expect((await StorageService.getMembers()).length, 5); // nothing saved
  });

  testWidgets('no overflow on a small phone in dark mode', (tester) async {
    // A small phone: 320 x 568 (like an iPhone SE, 1st generation).
    tester.view.physicalSize = const Size(640, 1136);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: const Scaffold(body: TeamScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Visit every one of Kevine's screens. An overflow would fail the test.
    await tester.tap(find.text('Emily Wong'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add member'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'A Very Long Member Name Indeed',
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
