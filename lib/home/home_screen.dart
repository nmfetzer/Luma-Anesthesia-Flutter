import 'package:flutter/material.dart';

import '../launch/launch_scope.dart';
import 'home_background.dart';
import 'home_tile.dart';
import 'home_menu_drawer.dart';
import 'home_search.dart';

class HomeTileData {
  final String eyebrow;
  final String titlePlain;
  final String titleAccent;
  final String? subtitle;
  final HomeTileStyle style;
  final String route;
  const HomeTileData({
    required this.titlePlain,
    required this.titleAccent,
    required this.route,
    this.eyebrow = '',
    this.subtitle,
    this.style = HomeTileStyle.cream,
  });
}

const _tiles = [
  HomeTileData(
    titlePlain: 'Drug',
    titleAccent: 'Library',
    subtitle: 'Dosing, mixing, precautions & sources',
    style: HomeTileStyle.featured,
    route: '/drug-library',
  ),
  HomeTileData(
    titlePlain: '',
    titleAccent: 'Crisis Hub',
    subtitle: 'Clinical crisis references · Free provider support',
    style: HomeTileStyle.crisis,
    route: '/crisis-guidelines',
  ),
  HomeTileData(
    titlePlain: 'Vasopressors, Infusions, &',
    titleAccent: 'Transfusions',
    subtitle: 'Medication preparation & clinical references',
    route: '/vasopressors-infusions',
  ),
  HomeTileData(
    eyebrow: 'Continuing Education',
    titlePlain: 'CE',
    titleAccent: 'Halo',
    subtitle: 'Course information & learning access',
    style: HomeTileStyle.darkHero,
    route: '/ce-halo',
  ),
  HomeTileData(
    titlePlain: 'Quick',
    titleAccent: 'References',
    subtitle: 'Searchable, source-linked guidance',
    style: HomeTileStyle.parchment,
    route: '/quick-references',
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF08192B),
    drawer: const HomeMenuDrawer(),
    body: Stack(
      children: [
        const HomeBackground(),
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  const _TopBar(),
                  const Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 14),
                    child: Text(
                      'Welcome to Luma',
                      style: TextStyle(
                        fontFamily: 'Fraunces',
                        fontSize: 24,
                        color: Color(0xFFF7F1E6),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: HomeSearch(
                      sections: [
                        for (final tile in _tiles)
                          HomeSearchSection(
                            '${tile.titlePlain} ${tile.titleAccent}'.trim(),
                            tile.route,
                            keywords:
                                '${tile.subtitle ?? ''} '
                                '${tile.route == '/crisis-guidelines' ? 'malignant hyperthermia ACLS PALS BLS emergency' : ''} '
                                '${tile.route == '/quick-references' ? 'preop pre-op clearance GLP1 GLP-1 guidelines' : ''}',
                          ),
                        const HomeSearchSection(
                          'Mental Health & Recovery Support',
                          '/provider-support',
                          keywords:
                              'mental emergency suicide 988 AANA ASA rehab addiction '
                              'provider wellness Parkdale Marworth physician MD DO CRNA CAA '
                              'student resident fellow nurse anesthesiologist burnout',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final columns = constraints.maxWidth < 560
                                  ? 1
                                  : 2;
                              const gap = 12.0;
                              final width =
                                  (constraints.maxWidth - gap * (columns - 1)) /
                                  columns;
                              final scale =
                                  MediaQuery.textScalerOf(context).scale(16) /
                                  16;
                              return Wrap(
                                spacing: gap,
                                runSpacing: gap,
                                children: [
                                  for (final tile in _tiles)
                                    SizedBox(
                                      width: width,
                                      height: 152 * scale.clamp(1.0, 2.5),
                                      child: HomeTile(data: tile),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          const _ComingSoonPanel(),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      MediaQuery.sizeOf(context).width < 900 ? 76 : 18,
                    ),
                    child: const Text(
                      'LUMA · Knowledge Illuminated',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Fraunces',
                        fontSize: 14,
                        color: Color(0xFFE6CF9C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Row(
      children: [
        Builder(
          builder: (context) => IconButton(
            tooltip: 'Menu',
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu, color: Color(0xFFF7F1E6)),
          ),
        ),
        const Expanded(
          child: Text(
            'Luma Anesthesia',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 18,
              color: Color(0xFFE6CF9C),
            ),
          ),
        ),
        IconButton(
          key: const ValueKey('home-account-button'),
          tooltip: 'Account',
          onPressed: () => Navigator.of(context).pushNamed('/account'),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          padding: const EdgeInsets.all(4),
          icon: Image.asset(
            'assets/branding/luma_symbol_halo.png',
            width: 40,
            height: 40,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ),
      ],
    ),
  );
}

class _ComingSoonPanel extends StatelessWidget {
  const _ComingSoonPanel();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF102A3D),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFF596476)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Coming soon',
          style: TextStyle(
            fontFamily: 'Fraunces',
            fontSize: 24,
            color: Color(0xFFE6CF9C),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Planned for future updates. These features are not '
          'available or included in the current subscription.',
          style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFFF7F1E6)),
        ),
        const SizedBox(height: 14),
        for (final entry in LaunchScope.deferred.entries)
          if (entry.key != '/ekg')
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                '• ${entry.value}',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFFF7F1E6),
                ),
              ),
            ),
        const SizedBox(height: 12),
        const Text(
          'You’ll be notified in the app when new features and updates are available.',
          style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFFCCD3DB)),
        ),
      ],
    ),
  );
}
