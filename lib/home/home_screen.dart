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
    subtitle: 'Dosing, mixing & sources',
    style: HomeTileStyle.featured,
    route: '/drug-library',
  ),
  HomeTileData(
    titlePlain: '',
    titleAccent: 'Crisis Hub',
    subtitle: 'Clinical crisis references',
    style: HomeTileStyle.crisis,
    route: '/crisis-guidelines',
  ),
  HomeTileData(
    titlePlain: 'Vasopressors, Infusions &',
    titleAccent: 'Transfusions',
    subtitle: 'Preparation & clinical references',
    route: '/vasopressors-infusions',
  ),
  HomeTileData(
    titlePlain: 'Pathophysiology &',
    titleAccent: 'Anesthesia Considerations',
    subtitle: 'Conditions & perioperative planning',
    route: '/special-considerations',
  ),
  HomeTileData(
    eyebrow: 'Continuing Education',
    titlePlain: 'CE',
    titleAccent: 'Halo',
    subtitle: 'Courses & learning access',
    style: HomeTileStyle.darkHero,
    route: '/ce-halo',
  ),
  HomeTileData(
    titlePlain: 'Quick',
    titleAccent: 'References',
    subtitle: 'Free, source-linked guidance',
    style: HomeTileStyle.parchment,
    route: '/quick-references',
  ),
  HomeTileData(
    titlePlain: 'The First Days',
    titleAccent: 'in the OR',
    subtitle: 'Clinical onboarding for SRNAs & anesthesia residents · PDF',
    style: HomeTileStyle.parchment,
    route: '/first-days-in-or',
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
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                children: [
                  const _TopBar(),
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
                                '${tile.route == '/special-considerations' ? 'special considerations patho comorbidities conditions perioperative' : ''} '
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
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final singleColumn =
                                  constraints.maxWidth < 280 ||
                                  MediaQuery.textScalerOf(context).scale(15) >
                                      20;
                              Widget pair(int first, int second) => singleColumn
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        HomeTile(
                                          data: _tiles[first],
                                          wide: true,
                                        ),
                                        const SizedBox(height: 8),
                                        HomeTile(
                                          data: _tiles[second],
                                          wide: true,
                                        ),
                                      ],
                                    )
                                  : IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            child: HomeTile(
                                              data: _tiles[first],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: HomeTile(
                                              data: _tiles[second],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  pair(0, 1),
                                  const SizedBox(height: 8),
                                  HomeTile(data: _tiles[2], wide: true),
                                  const SizedBox(height: 8),
                                  HomeTile(data: _tiles[3], wide: true),
                                  const SizedBox(height: 8),
                                  pair(4, 5),
                                  const SizedBox(height: 8),
                                  HomeTile(data: _tiles[6], wide: true),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () =>
                                Navigator.of(context)
                                    .pushNamed('/provider-support'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFF7F1E6),
                              side: const BorderSide(color: Color(0xFF627581)),
                              padding: const EdgeInsets.all(12),
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: const Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              spacing: 12,
                              runSpacing: 6,
                              children: [
                                Text('Mental Health & Recovery Support'),
                                Text(
                                  'Always free',
                                  style: TextStyle(color: Color(0xFFE6CF9C)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const _ComingSoonPanel(),
                          const SizedBox(height: 20),
                          const Text(
                            'LUMA · Knowledge Illuminated',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Fraunces',
                              fontSize: 12,
                              color: Color(0xFFE6CF9C),
                            ),
                          ),
                        ],
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
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 4),
      childrenPadding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      iconColor: const Color(0xFFE6CF9C),
      collapsedIconColor: const Color(0xFFE6CF9C),
      title: const Text(
        'Coming soon',
        style: TextStyle(fontSize: 14, color: Color(0xFFCCD3DB)),
      ),
      children: [
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
