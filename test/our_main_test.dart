import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redditech/main.dart';
import 'package:mockito/mockito.dart';

// Unit Test

// Mock Test

// Widget Test

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  testWidgets('LoginDemo to WebView', (WidgetTester tester) async {
    final mockObserver = MockNavigatorObserver();
    await tester.pumpWidget(MaterialApp(
      home: LoginDemo(),
      navigatorObservers: [mockObserver],
    ));
    expect(find.byKey(ValueKey("LoginButton")), findsOneWidget);
    await tester.tap(find.byKey(ValueKey("LoginButton")));
    await tester.pumpAndSettle();

    expect(find.byKey(ValueKey("WebView")), findsOneWidget);
  });
}
