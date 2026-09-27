// -----------------------------------------------------------------------------
// Luma Anesthesia — app entry point.
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'billing/revenuecat_billing.dart';
import 'home/home_screen.dart';
import 'screens/drugs_categories_screen.dart';
import 'screens/account_screen.dart';
import 'screens/subscription_screen.dart';
import 'launch/launch_scope.dart';
import 'launch/deferred_section_screen.dart';
import 'crisis/crisis_screen.dart';
import 'crisis/provider_support_screen.dart';
import 'theme/luma_theme.dart';
import 'vasopressors/vasopressors_screen.dart';
import 'welcome/welcome_carousel.dart';
import 'ce/ce_screen.dart';
import 'quick_references/quick_reference_screen.dart';
import 'quick_references/quick_reference_shortcut.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  if (LumaConfig.supabaseConfigured) {
    await Supabase.initialize(
      url: LumaConfig.supabaseUrl,
      anonKey: LumaConfig.supabaseAnonKey,
    );
    LumaBilling.instance.start(Supabase.instance.client);
  }

  runApp(const LumaApp());
}

class LumaApp extends StatelessWidget {
  const LumaApp({
    super.key,
    this.allowSocialSignIn = true,
    this.showComingSoon = false,
    this.cePortal = false,
  });
  final bool allowSocialSignIn;
  final bool showComingSoon;
  final bool cePortal;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luma Anesthesia',
      debugShowCheckedModeBanner: false,
      theme: buildLumaTheme(),
      navigatorKey: _navKey,
      navigatorObservers: [_quickReferenceObserver],
      builder: (context, child) => QuickReferenceShortcut(
        observer: _quickReferenceObserver,
        navigatorKey: _navKey,
        child: child ?? const SizedBox.shrink(),
      ),
      home: kIsWeb && Uri.base.queryParameters['auth_callback'] == '1'
          ? AccountScreen(allowSocialSignIn: allowSocialSignIn)
          : cePortal
          ? const CeCourseScreen()
          : WelcomeCarousel(
              onFinish: () {
                final navigator = _navKey.currentState;
                navigator?.pushReplacementNamed('/home');
              },
            ),
      onGenerateRoute: (settings) {
        final path = Uri.tryParse(settings.name ?? '')?.path ?? '';
        if (LaunchScope.isDeferred(path)) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => DeferredSectionScreen(
              title: LaunchScope.titleFor(path),
              showComingSoon: showComingSoon,
            ),
          );
        }
        if (settings.name == '/provider-support') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const ProviderSupportScreen(),
          );
        }
        if (settings.name == '/quick-references') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => QuickReferencesScreen(
              initialQuery: settings.arguments is String
                  ? settings.arguments as String
                  : '',
            ),
          );
        }
        if (settings.name == '/crisis-guidelines' ||
            settings.name == '/crisis') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => CrisisHubScreen(
              initialQuery: settings.arguments is String
                  ? settings.arguments as String
                  : '',
            ),
          );
        }
        if (settings.name == '/home') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => cePortal
                ? const CeCourseScreen()
                : HomeScreen(showComingSoon: showComingSoon),
          );
        }
        if (settings.name == '/subscribe') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const SubscriptionScreen(),
          );
        }
        if (settings.name == '/ce-halo' ||
            settings.name == '/ce-halo/courses') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const CeCourseScreen(),
          );
        }
        if (settings.name == '/account') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => AccountScreen(allowSocialSignIn: allowSocialSignIn),
          );
        }
        if (settings.name == '/drug-library') {
          return MaterialPageRoute(
            builder: (_) => const DrugsCategoriesScreen(),
          );
        }
        if (settings.name == '/vasopressors-infusions') {
          return MaterialPageRoute(builder: (_) => const VasopressorsScreen());
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              const DeferredSectionScreen(title: 'Section unavailable'),
        );
      },
    );
  }
}

final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
final _quickReferenceObserver = QuickReferenceRouteObserver();
