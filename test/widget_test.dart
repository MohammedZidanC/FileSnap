import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filesnap/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filesnap/providers/settings_provider.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const FileSnapApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
