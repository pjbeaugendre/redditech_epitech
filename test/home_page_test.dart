import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redditech/home_page.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('BottomNavBar', () {
    testWidgets("Check existing buttons", (WidgetTester tester) async {
      await tester
          .pumpWidget(MaterialApp(home: MyHomePage(title: "Redditech")));

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.add_sharp), findsOneWidget);
    });
  });
  group('Drawer', () {
    testWidgets("Test Drawer Button", (WidgetTester tester) async {
      final drawerButton = find.byKey(ValueKey("DrawerButton"));

      await tester.pumpWidget(MaterialApp(home: MyHomePage(title: "Test")));
      await tester.tap(drawerButton);
      await tester.pump();

      expect(find.byKey(ValueKey("MyProfileButton")), findsOneWidget);
      expect(find.byKey(ValueKey("CreateCommunityButton")), findsOneWidget);
      expect(find.byKey(ValueKey("SavedButton")), findsOneWidget);
      expect(find.byKey(ValueKey("HistoryButton")), findsOneWidget);
    });
    /*testWidgets('to Profile Page', (WidgetTester tester) async {
      final mockObserver = MockNavigatorObserver();
      final drawerButton = find.byKey(ValueKey("DrawerButton"));

      await tester.pumpWidget(MaterialApp(
        home: MyHomePage(title: "Test"),
        navigatorObservers: [mockObserver],
      ));
      await tester.tap(drawerButton);
      await tester.pump();
      final profileB = find.byKey(ValueKey("MyProfileButton"));
      await tester.tap(profileB);
      await tester.pumpAndSettle();

      //verify(mockObserver.didPush(any, any));
      expect(find.byIcon(Icons.lens_rounded), findsOneWidget);
    });*/
  });
}
