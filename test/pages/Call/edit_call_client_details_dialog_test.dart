import 'dart:async';

import 'package:crm_flutter/pages/Call/edit_call_client_details_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('prefills fields, validates values, and saves edits', (
    tester,
  ) async {
    String? savedName;
    String? savedMobile;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showDialog<bool>(
                context: context,
                builder: (_) => EditCallClientDetailsDialog(
                  clientName: 'Ada Lovelace',
                  mobileNumber: '1234567890',
                  onSave: (name, mobile) async {
                    savedName = name;
                    savedMobile = mobile;
                  },
                ),
              ),
              child: const Text('Open editor'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Client Details'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('edit-client-name-field')),
          )
          .controller
          ?.text,
      'Ada Lovelace',
    );
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('edit-client-mobile-field')),
          )
          .controller
          ?.text,
      '1234567890',
    );

    await tester.enterText(
      find.byKey(const ValueKey('edit-client-name-field')),
      ' ',
    );
    await tester.enterText(
      find.byKey(const ValueKey('edit-client-mobile-field')),
      '12345',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Client name is required'), findsOneWidget);
    expect(find.text('Enter a valid 10-digit mobile number'), findsOneWidget);
    expect(savedName, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('edit-client-name-field')),
      'Grace Hopper',
    );
    await tester.enterText(
      find.byKey(const ValueKey('edit-client-mobile-field')),
      '9876543210',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(savedName, 'Grace Hopper');
    expect(savedMobile, '9876543210');
    expect(find.text('Edit Client Details'), findsNothing);
  });

  testWidgets('shows API errors and prevents duplicate submissions', (
    tester,
  ) async {
    final completer = Completer<void>();
    var submitCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showDialog<bool>(
                context: context,
                builder: (_) => EditCallClientDetailsDialog(
                  clientName: 'Ada Lovelace',
                  mobileNumber: '1234567890',
                  onSave: (name, mobile) {
                    submitCount++;
                    return completer.future;
                  },
                ),
              ),
              child: const Text('Open editor'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(submitCount, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.completeError(Exception('Save failed'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Save failed'), findsOneWidget);
    expect(find.text('Edit Client Details'), findsOneWidget);
  });
}
