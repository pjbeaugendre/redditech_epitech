import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redditech/profile_page.dart';

// Unit Test
// Mock Test
// Widget Test

class CustomBindings extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}
void main() {
  CustomBindings();
  testWidgets("Check existing buttons", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ProfilePage()));
    /*expect(find.byKey(ValueKey("ProfilePicture")), findsOneWidget);
    expect(find.byKey(ValueKey("ProfileImage")), findsOneWidget);
    expect(find.byKey(ValueKey("ProfileName")), findsOneWidget);
    expect(find.byKey(ValueKey("ProfileEditButton")), findsOneWidget);*/
  });
}
