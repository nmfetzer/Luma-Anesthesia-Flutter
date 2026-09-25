import 'package:flutter/material.dart';

class HomeMenuDrawer extends StatelessWidget {
  const HomeMenuDrawer({super.key});

  static const _navy = Color(0xFF0F2A3D);
  static const _cream = Color(0xFFF7F1E6);
  static const _gold = Color(0xFFE6CF9C);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _navy,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontFamily: 'Fraunces', fontSize: 20, color: _cream),
                  children: const [
                    TextSpan(text: 'Luma '),
                    TextSpan(text: 'Anesthesia', style: TextStyle(fontStyle: FontStyle.italic, color: _gold)),
                  ],
                ),
              ),
            ),
            const Divider(color: Color(0x33E6CF9C), height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _sectionLabel('MEDICATIONS'),
                  _link(context, 'Drug Library', '/drug-library'),
                  _link(context, 'Vasopressors, Infusions, & Transfusions', '/vasopressors-infusions'),
                  _sectionLabel('CLINICAL'),
                  _link(context, 'Pathophysiology & Anesthesia Considerations', '/special-considerations'),
                  _link(context, 'Surgical Case Prep', '/surgical-prep'),
                  _link(context, 'Diagnostics', '/diagnostics'),
                  _link(context, 'Regional & Procedures', '/regional-procedures'),
                  _link(context, 'Practice Guidelines', '/practice-guidelines'),
                  _link(context, 'Crisis Guidelines', '/crisis-guidelines', accent: const Color(0xFFB43C37)),
                  _sectionLabel('EDUCATION'),
                  _link(context, 'Meet Luma AI', '/luma-ai'),
                  _link(context, 'CE Halo', '/ce-halo'),
                  _sub(context, 'My Courses', '/ce-halo/courses'),
                  _sub(context, 'My Certificates', '/ce-halo/certificates'),
                  _link(context, 'Luma Academy', '/luma-academy'),
                  _sub(context, 'NBCRNA Prep', '/luma-academy/nbcrna'),
                  _sub(context, 'ABA Basic', '/luma-academy/aba-basic'),
                  _sub(context, 'ABA Advanced', '/luma-academy/aba-advanced'),
                  _sub(context, 'SEE Exam Prep', '/luma-academy/see'),
                  _sub(context, 'Anesthesia Flashcards', '/luma-academy/flashcards'),
                  _sectionLabel('ACCOUNT'),
                  _link(context, 'Luma Premium', '/subscribe'),
                  _link(context, 'My Account', '/account'),
                  _link(context, 'Settings', '/settings'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Text(text, style: const TextStyle(fontFamily: 'Inter', fontSize: 10, letterSpacing: 1.6, color: _gold, fontWeight: FontWeight.w500)),
    );
  }

  Widget _link(BuildContext context, String label, String route, {Color? accent}) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(label, style: TextStyle(fontFamily: 'Fraunces', fontSize: 15, color: accent ?? _cream)),
      ),
    );
  }

  Widget _sub(BuildContext context, String label, String route) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(38, 6, 20, 6),
        child: Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xCCF7F1E6))),
      ),
    );
  }
}
