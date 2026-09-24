// -----------------------------------------------------------------------------
// Luma Anesthesia — app entry point.
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'home/home_screen.dart';
import 'screens/drugs_categories_screen.dart';
import 'screens/account_screen.dart';
import 'screens/subscription_screen.dart';
import 'special_considerations/special_considerations_screen.dart';
import 'theme/luma_theme.dart';
import 'vasopressors/vasopressors_screen.dart';
import 'welcome/welcome_carousel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  if (LumaConfig.supabaseConfigured) {
    await Supabase.initialize(
      url: LumaConfig.supabaseUrl,
      anonKey: LumaConfig.supabaseAnonKey,
    );
  }

  runApp(const LumaApp());
}

class LumaApp extends StatelessWidget {
  const LumaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luma Anesthesia',
      debugShowCheckedModeBanner: false,
      theme: buildLumaTheme(),
      navigatorKey: _navKey,
      home: WelcomeCarousel(
        onFinish: () {
          final navigator = _navKey.currentState;
          navigator?.pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        },
      ),
      onGenerateRoute: (settings) {
        if (settings.name == '/special-considerations') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => SpecialConsiderationsScreen(
              onSignIn: () => _navKey.currentState?.pushNamed('/account'),
              onSubscribe: () => _navKey.currentState?.pushNamed('/subscribe'),
            ),
          );
        }
        if (settings.name == '/subscribe') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const SubscriptionScreen(),
          );
        }
        if (settings.name == '/ce-halo') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const CeAccessScreen(),
          );
        }
        if (settings.name == '/account') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const AccountScreen(),
          );
        }
        if (settings.name == '/drug-library') {
          return MaterialPageRoute(
              builder: (_) => const DrugsCategoriesScreen());
        }
        if (settings.name == '/vasopressors-infusions') {
          return MaterialPageRoute(builder: (_) => const VasopressorsScreen());
        }
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: Text(settings.name ?? 'Coming soon')),
            body: Center(
              child: Text(
                '${settings.name}\n\nComing soon',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        );
      },
    );
  }
}

final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
