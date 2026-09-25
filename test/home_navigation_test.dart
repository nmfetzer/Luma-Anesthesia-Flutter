import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/widgets/luma_home_button.dart';
import 'package:luma_anesthesia/screens/subscription_screen.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('Home clears nested section routes and opens tile dashboard',
      (tester) async {
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigator,
      home: const Scaffold(body: Text('Welcome')),
      routes: {
        '/home': (_) => const Scaffold(body: Text('Tile dashboard')),
        '/section': (_) => const Scaffold(body: LumaHomeButton()),
      },
    ));
    navigator.currentState!.pushNamed('/section');
    await tester.pumpAndSettle();
    navigator.currentState!.pushNamed('/section');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Tile dashboard'), findsOneWidget);
    expect(navigator.currentState!.canPop(), isFalse);
  });

  testWidgets('paywall Home opens dashboard without buying or signing in',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: const SubscriptionScreen(),
      routes: {
        '/home': (_) => const Scaffold(body: Text('Tile dashboard')),
      },
    ));
    await tester.pump();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Tile dashboard'), findsOneWidget);
  });
}
