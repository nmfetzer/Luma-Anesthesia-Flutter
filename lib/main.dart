// -----------------------------------------------------------------------------
// Luma Anesthesia — app entry point.
// -----------------------------------------------------------------------------

import 'dart:async';

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
import 'special_considerations/special_considerations_screen.dart';
import 'launch/launch_scope.dart';
import 'launch/deferred_section_screen.dart';
import 'crisis/crisis_screen.dart';
import 'crisis/provider_support_screen.dart';
import 'theme/luma_theme.dart';
import 'vasopressors/vasopressors_screen.dart';
import 'welcome/welcome_gate.dart';
import 'screens/password_recovery_screen.dart';
import 'ce/ce_library_screen.dart';
import 'ce/ce_purchase_screen.dart';
import 'ce/web/ce_portal_frame.dart';
import 'quick_references/quick_reference_screen.dart';
import 'quick_references/quick_reference_shortcut.dart';
import 'offline/offline_library.dart';
import 'offline/offline_status_frame.dart';
import 'offline/offline_downloads_screen.dart';

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
    try {
      await OfflineLibrary.initialize(Supabase.instance.client);
    } catch (_) {
      /* Device storage failure must not block online reference use. */
    }
  }

  runApp(const LumaApp());
}

class LumaApp extends StatefulWidget {
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
  State<LumaApp> createState() => _LumaAppState();
}

class _LumaAppState extends State<LumaApp> {
  StreamSubscription<AuthState>? _recovery;
  bool _recoveryOpen = false;
  bool get allowSocialSignIn => widget.allowSocialSignIn;
  bool get showComingSoon => widget.showComingSoon;
  bool get cePortal => widget.cePortal;
  @override
  void initState() {
    super.initState();
    _recoveryOpen = kIsWeb && Uri.base.queryParameters['recovery'] == '1';
    try {
      _recovery = Supabase.instance.client.auth.onAuthStateChange.listen(
        (state) {
          if (state.event != AuthChangeEvent.passwordRecovery ||
              _recoveryOpen) {
            return;
          }
          _recoveryOpen = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;
            await _navKey.currentState?.push(
              MaterialPageRoute(builder: (_) => const PasswordRecoveryScreen()),
            );
            _recoveryOpen = false;
          });
        },
        onError: (Object error, StackTrace stack) {
          // The account/recovery form handles actionable errors. A background
          // token-refresh failure must not become an unhandled app exception.
        },
      );
    } catch (_) {
      /* Offline previews have no initialized Supabase client. */
    }
  }

  @override
  void dispose() {
    _recovery?.cancel();
    super.dispose();
  }

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
        child: OfflineStatusFrame(
          navigatorKey: _navKey,
          child: cePortal && kIsWeb
              ? CePortalFrame(child: child ?? const SizedBox.shrink())
              : child ?? const SizedBox.shrink(),
        ),
      ),
      home: kIsWeb && Uri.base.queryParameters['recovery'] == '1'
          ? const PasswordRecoveryScreen()
          : kIsWeb && Uri.base.queryParameters['auth_callback'] == '1'
          ? AccountScreen(allowSocialSignIn: allowSocialSignIn)
          : cePortal
          ? const CeLibraryScreen()
          : const WelcomeGate(child: HomeScreen()),
      onGenerateRoute: (settings) {
        final path = Uri.tryParse(settings.name ?? '')?.path ?? '';
        if (path == '/ce-purchase') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => CePurchaseScreen(
              productId: settings.arguments is String
                  ? settings.arguments as String
                  : Uri.tryParse(settings.name ?? '')
                        ?.queryParameters['product'],
            ),
          );
        }
        if (path == '/offline-downloads') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const OfflineDownloadsScreen(),
          );
        }
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
            builder: (_) =>
                cePortal ? const CeLibraryScreen() : const HomeScreen(),
          );
        }
        if (path == '/special-considerations') {
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
        if (settings.name == '/ce-halo' ||
            settings.name == '/ce-halo/courses') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const CeLibraryScreen(),
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
