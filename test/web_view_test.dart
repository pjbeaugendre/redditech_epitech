import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';

void GlobalTestWebView() {}

// Unit Test

// Mock Test

// Widget Test

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

/*void OurMainTest() {
  testWidgets('Webviex to homepage', (WidgetTester tester) async {
    final mockObserver = MockNavigatorObserver();

    await tester.pumpWidget(MaterialApp(
      home: MyWebView(""),
      navigatorObservers: [mockObserver],
    ));
    expect(find.byKey(ValueKey("LoginButton")), findsOneWidget);
    await tester.tap(find.byKey(ValueKey("LoginButton")));
    await tester.pumpAndSettle();

    //verify(mockObserver.didPush(any, any));
    expect(find.byKey(ValueKey("WebView")), findsOneWidget);
  });
}*/