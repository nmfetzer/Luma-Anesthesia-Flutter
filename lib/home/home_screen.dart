import 'package:flutter/material.dart';
import 'home_background.dart';
import 'home_tile.dart';
import 'home_menu_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08192B),
      drawer: const HomeMenuDrawer(),
      body: Stack(
        children: [
          const HomeBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                if (w < 600) return _PhoneLayout(width: w);
                if (w < 1024) return _TabletLayout(width: w);
                return _DesktopLayout(width: w);
              },
            ),
          ),
        ],
      ),
    );
  }
}

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

const List<HomeTileData> _tiles = [
  HomeTileData(
    titlePlain: 'Drug',
    titleAccent: 'Library',
    subtitle: 'Adult & pediatric dosing, contraindications, sources',
    style: HomeTileStyle.featured,
    route: '/drug-library',
  ),
  HomeTileData(
    eyebrow: 'Continuing Education',
    titlePlain: 'CE',
    titleAccent: 'Halo',
    subtitle: 'Courses · 20 AANA-Approved MAC Ed CEs each',
    style: HomeTileStyle.darkHero,
    route: '/ce-halo',
  ),
  HomeTileData(titlePlain: 'Luma', titleAccent: 'Academy', route: '/luma-academy'),
  HomeTileData(titlePlain: 'Vasopressors, Infusions, &', titleAccent: 'Transfusions', route: '/vasopressors-infusions'),
  HomeTileData(titlePlain: 'Special', titleAccent: 'Considerations', route: '/special-considerations'),
  HomeTileData(titlePlain: 'Surgical Case', titleAccent: 'Prep', route: '/surgical-prep'),
  HomeTileData(titlePlain: '', titleAccent: 'Diagnostics', route: '/diagnostics'),
  HomeTileData(titlePlain: 'Regional &', titleAccent: 'Procedures', route: '/regional-procedures'),
  HomeTileData(titlePlain: 'Practice', titleAccent: 'Guidelines', style: HomeTileStyle.parchment, route: '/practice-guidelines'),
  HomeTileData(
    titlePlain: '',
    titleAccent: 'Crisis',
    subtitle: 'Malignant Hyperthermia · ACLS · PALS & more',
    style: HomeTileStyle.crisis,
    route: '/crisis-guidelines',
  ),
];

HomeTileData _tile(String key) => _tiles.firstWhere((t) => t.route.contains(key));

class _TopBar extends StatelessWidget {
  final bool compact;
  const _TopBar({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 12 : 20, compact ? 8 : 12, compact ? 12 : 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _MenuPill(compact: compact),
          _Wordmark(compact: compact),
          const _AccountAvatar(),
        ],
      ),
    );
  }
}

class _MenuPill extends StatelessWidget {
  final bool compact;
  const _MenuPill({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Scaffold.of(context).openDrawer(),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14, vertical: compact ? 6 : 7),
        decoration: BoxDecoration(
          color: const Color(0xFF0F2A3D).withValues(alpha: 0.55),
          border: Border.all(color: const Color(0xFFE6CF9C).withValues(alpha: 0.35), width: 0.5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu, size: compact ? 12 : 14, color: const Color(0xFFF7F1E6)),
            if (!compact) ...[
              const SizedBox(width: 6),
              const Text('MENU', style: TextStyle(fontFamily: 'Inter', fontSize: 10, letterSpacing: 1.4, color: Color(0xFFF7F1E6), fontWeight: FontWeight.w500)),
            ],
          ],
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  final bool compact;
  const _Wordmark({this.compact = false});

  @override
  Widget build(BuildContext context) {
    final size = compact ? 15.0 : 17.0;
    return RichText(
      text: TextSpan(
        style: TextStyle(fontFamily: 'Fraunces', fontSize: size, color: const Color(0xFFF7F1E6)),
        children: const [
          TextSpan(text: 'Luma '),
          TextSpan(text: 'Anesthesia', style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFFE6CF9C), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F2A3D), Color(0xFF08192B)]),
          border: Border.all(color: const Color(0xFFE6CF9C), width: 1.5),
          boxShadow: [
            BoxShadow(color: const Color(0xFFD4A95A).withValues(alpha: 0.25), blurRadius: 6, spreadRadius: 0.5),
            const BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Image.asset('assets/branding/luma_icon.png', fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.medical_services, size: 20, color: Color(0xFFE6CF9C)),
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  final String name;
  const _Greeting({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontFamily: 'Fraunces', fontSize: 22, color: Color(0xFFF7F1E6), height: 1.1),
              children: [
                const TextSpan(text: 'Welcome back, '),
                TextSpan(text: name, style: const TextStyle(fontStyle: FontStyle.italic, color: Color(0xFFE6CF9C))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const _SearchPill(),
        ],
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 460),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F1E6),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, 6))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.search, size: 14, color: Color(0x8C0F2A3D)),
          SizedBox(width: 8),
          Text('Search drugs, guidelines, cases, procedures…', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontStyle: FontStyle.italic, color: Color(0x8C0F2A3D))),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: const Color(0xFFE6CF9C).withValues(alpha: 0.18), width: 0.5)),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 14, runSpacing: 8,
        children: [
          _footerBadge('AANA-Approved CE'),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontFamily: 'Fraunces', fontSize: 13, color: Color(0xD9F7F1E6), letterSpacing: 0.5),
              children: const [
                TextSpan(text: 'LUMA · '),
                TextSpan(text: 'Knowledge Illuminated', style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFFE6CF9C))),
              ],
            ),
          ),
          _footerBadge('Reviewed by Clinicians'),
        ],
      ),
    );
  }

  Widget _footerBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2A3D).withValues(alpha: 0.5),
        border: Border.all(color: const Color(0xFFE6CF9C).withValues(alpha: 0.25), width: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFFE6CF9C), shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(text.toUpperCase(), style: const TextStyle(fontFamily: 'Inter', fontSize: 9, letterSpacing: 1.2, color: Color(0xB8F7F1E6), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _PhoneLayout extends StatelessWidget {
  final double width;
  const _PhoneLayout({required this.width});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _TopBar(compact: true),
        const _Greeting(name: 'Nicole'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            child: Column(
              children: [
                SizedBox(height: 160, child: HomeTile(data: _tile('drug-library'))),
                const SizedBox(height: 8),
                SizedBox(height: 130, child: HomeTile(data: _tile('ce-halo'))),
                const SizedBox(height: 8),
                _tileRow(_tile('luma-academy'), _tile('vasopressors-infusions')),
                const SizedBox(height: 8),
                _tileRow(_tile('special-considerations'), _tile('surgical-prep')),
                const SizedBox(height: 8),
                _tileRow(_tile('diagnostics'), _tile('regional-procedures')),
                const SizedBox(height: 8),
                SizedBox(height: 68, child: HomeTile(data: _tile('practice-guidelines'))),
                const SizedBox(height: 8),
                SizedBox(height: 68, child: HomeTile(data: _tile('crisis-guidelines'))),
              ],
            ),
          ),
        ),
        const _Footer(),
      ],
    );
  }

  Widget _tileRow(HomeTileData a, HomeTileData b) {
    return SizedBox(
      height: 88,
      child: Row(
        children: [
          Expanded(child: HomeTile(data: a)),
          const SizedBox(width: 8),
          Expanded(child: HomeTile(data: b)),
        ],
      ),
    );
  }
}

class _TabletLayout extends StatelessWidget {
  final double width;
  const _TabletLayout({required this.width});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _TopBar(),
        const _Greeting(name: 'Nicole'),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Column(
              children: [
                Expanded(flex: 3, child: Row(children: [Expanded(child: HomeTile(data: _tile('drug-library'))), const SizedBox(width: 10), Expanded(child: HomeTile(data: _tile('ce-halo')))])),
                const SizedBox(height: 10),
                Expanded(flex: 1, child: Row(children: [Expanded(child: HomeTile(data: _tile('luma-academy'))), const SizedBox(width: 10), Expanded(child: HomeTile(data: _tile('vasopressors-infusions')))])),
                const SizedBox(height: 10),
                Expanded(flex: 1, child: Row(children: [Expanded(child: HomeTile(data: _tile('special-considerations'))), const SizedBox(width: 10), Expanded(child: HomeTile(data: _tile('surgical-prep')))])),
                const SizedBox(height: 10),
                Expanded(flex: 1, child: Row(children: [Expanded(child: HomeTile(data: _tile('diagnostics'))), const SizedBox(width: 10), Expanded(child: HomeTile(data: _tile('regional-procedures'))), const SizedBox(width: 10), Expanded(child: HomeTile(data: _tile('practice-guidelines')))])),
                const SizedBox(height: 10),
                Expanded(flex: 1, child: HomeTile(data: _tile('crisis-guidelines'))),
              ],
            ),
          ),
        ),
        const _Footer(),
      ],
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final double width;
  const _DesktopLayout({required this.width});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1440),
        child: Column(
          children: [
            const _TopBar(),
            const _Greeting(name: 'Nicole'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                child: Column(
                  children: [
                    Expanded(flex: 2, child: Row(children: [Expanded(flex: 5, child: HomeTile(data: _tile('drug-library'))), const SizedBox(width: 10), Expanded(flex: 7, child: HomeTile(data: _tile('ce-halo')))])),
                    const SizedBox(height: 10),
                    Expanded(flex: 1, child: Row(children: [Expanded(child: HomeTile(data: _tile('luma-academy'))), const SizedBox(width: 10), Expanded(child: HomeTile(data: _tile('vasopressors-infusions'))), const SizedBox(width: 10), Expanded(child: HomeTile(data: _tile('special-considerations')))])),
                    const SizedBox(height: 10),
                    Expanded(flex: 1, child: Row(children: [Expanded(child: HomeTile(data: _tile('surgical-prep'))), const SizedBox(width: 10), Expanded(child: HomeTile(data: _tile('diagnostics'))), const SizedBox(width: 10), Expanded(child: HomeTile(data: _tile('regional-procedures'))), const SizedBox(width: 10), Expanded(child: HomeTile(data: _tile('practice-guidelines')))])),
                    const SizedBox(height: 10),
                    Expanded(flex: 1, child: HomeTile(data: _tile('crisis-guidelines'))),
                  ],
                ),
              ),
            ),
            const _Footer(),
          ],
        ),
      ),
    );
  }
}
