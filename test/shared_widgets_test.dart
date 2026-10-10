import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_management/services/sla_service.dart';
import 'package:project_management/widgets/app_text_field.dart';
import 'package:project_management/widgets/status_pill.dart';
import 'package:project_management/widgets/user_avatar.dart';

void main() {
  group('UserAvatar.initialsOf', () {
    test('two words give two letters', () {
      expect(UserAvatar.initialsOf('Sarah Lee'), 'SL');
    });
    test('small letters become capitals', () {
      expect(UserAvatar.initialsOf('emily wong'), 'EW');
    });
    test('one word with extra spaces gives one letter', () {
      expect(UserAvatar.initialsOf('  David  '), 'D');
    });
    test('three words use the first and the last', () {
      expect(UserAvatar.initialsOf('Grace Uwase Mukamana'), 'GM');
    });
    test('empty name gives a question mark', () {
      expect(UserAvatar.initialsOf(''), '?');
    });
  });

  test('the same name always gets the same palette colour', () {
    final first = UserAvatar.colorValueForName('Grace Uwase');
    expect(UserAvatar.colorValueForName('Grace Uwase'), first);
    expect(UserAvatar.palette, contains(first));
  });

  group('Validators', () {
    test('required rejects empty and spaces only', () {
      final check = Validators.required('Full name');
      expect(check(''), 'Full name is required');
      expect(check('   '), 'Full name is required');
      expect(check('Grace'), isNull);
    });
    test('email checks the format', () {
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email('grace'), isNotNull);
      expect(Validators.email('grace@email'), isNotNull);
      expect(Validators.email('grace@email.com'), isNull);
    });
    test('optionalEmail allows empty but not a bad format', () {
      expect(Validators.optionalEmail(''), isNull);
      expect(Validators.optionalEmail('bad'), isNotNull);
    });
    test('password needs at least 6 characters', () {
      expect(
        Validators.password('12345'),
        'Password must be at least 6 characters',
      );
      expect(Validators.password('123456'), isNull);
    });
    test('confirm password must match', () {
      final original = TextEditingController(text: 'secret1');
      final check = Validators.confirmPassword(original);
      expect(check('secret2'), 'Passwords do not match');
      expect(check('secret1'), isNull);
    });
  });

  testWidgets('StatusPill shows the right label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatusPill(status: SlaStatus.atRisk)),
      ),
    );
    expect(find.text('At Risk'), findsOneWidget);
  });
}
