// The four welcome slides. Each is wrapped in _SlideFrame so the content
// stays a comfortable reading width on phone, tablet, and desktop.

import 'package:flutter/material.dart';

import 'luma_theme.dart';

// ────────────────────────────────────────────────────────────────────────────
// Slide 1 — A quieter kind of reference (welcome + brand line + audience chips)
// ────────────────────────────────────────────────────────────────────────────

class WelcomeSlideOne extends StatelessWidget {
  const WelcomeSlideOne({super.key});

  @override
  Widget build(BuildContext context) {
    return _SlideFrame(
      alignment: CrossAxisAlignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'WELCOME TO LUMA',
            textAlign: TextAlign.center,
            style: LumaText.eyebrow(),
          ),
          const SizedBox(height: 12),
          _TitleWithItalic(
            plain: 'A quieter kind of ',
            italic: 'reference.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Built by clinicians, for the whole anesthesia team — attendings, residents, CRNAs, SRNAs, and AAs.',
            textAlign: TextAlign.center,
            style: LumaText.body(),
          ),
          const SizedBox(height: 20),
          const _BrandLine(),
          const SizedBox(height: 16),
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _AudienceChip('Anesthesiologists'),
              _AudienceChip('Residents'),
              _AudienceChip('CRNAs · SRNAs'),
              _AudienceChip('AAs'),
            ],
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Slide 2 — Comprehensive drug library
// ────────────────────────────────────────────────────────────────────────────

class WelcomeSlideTwo extends StatelessWidget {
  const WelcomeSlideTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return _SlideFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('ANESTHESIA MEDICATION REFERENCES', style: LumaText.eyebrow()),
          const SizedBox(height: 10),
          _TitleWithItalic(
            plain: 'Medication details. ',
            italic: 'Clinical context.',
          ),
          const SizedBox(height: 14),
          Text(
            'Explore adult and pediatric dosing, preparation, precautions, and supporting references. Always confirm the patient, formulation, and local protocol.',
            style: LumaText.body(),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Slide 3 — A complete anesthesia companion (6-tile feature grid)
// ────────────────────────────────────────────────────────────────────────────

class WelcomeSlideThree extends StatelessWidget {
  const WelcomeSlideThree({super.key});

  @override
  Widget build(BuildContext context) {
    return _SlideFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('YOUR CLINICAL REFERENCE', style: LumaText.eyebrow()),
          const SizedBox(height: 10),
          _TitleWithItalic(
            plain: 'Focused references for ',
            italic: 'anesthesia practice.',
          ),
          const SizedBox(height: 14),
          Text(
            "A calm home for the parts of the case you prepare for — and the ones you can't.",
            style: LumaText.body(),
          ),
          const SizedBox(height: 18),
          Text('Quick References', style: LumaText.featureTitle()),
          const SizedBox(height: 6),
          Text(
            'Tap Quick Ref for searchable, source-linked guidance. Start with Pre-Op Clearance Guidelines, including GLP-1 considerations.',
            style: LumaText.body(),
          ),
          const SizedBox(height: 18),
          const _FeatureGrid(),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Slide 4 — Earn credit while you learn (CE)
// ────────────────────────────────────────────────────────────────────────────

class WelcomeSlideFour extends StatelessWidget {
  const WelcomeSlideFour({super.key});

  @override
  Widget build(BuildContext context) {
    return _SlideFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('CE HALO · CONTINUING EDUCATION', style: LumaText.eyebrow()),
          const SizedBox(height: 10),
          _TitleWithItalic(
            plain: 'Continuing education, ',
            italic: 'in one place.',
          ),
          const SizedBox(height: 14),
          Text(
            'Explore course information and your learning access in CE HALO. Course availability, requirements, and credit details are shown within each course.',
            style: LumaText.body(),
          ),
          const SizedBox(height: 16),
          Text(
            'A clinical app subscription is not required for CE courses. Course purchases and access are separate from the reference subscription.',
            style: LumaText.note(),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ────────────────────────────────────────────────────────────────────────────

// Caps every slide's content to a comfortable reading width and centers it,
// so the layout looks equally deliberate on phone, tablet, and desktop.
class _SlideFrame extends StatelessWidget {
  final Widget child;
  final CrossAxisAlignment alignment;
  const _SlideFrame({
    required this.child,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
          child: child,
        ),
      ),
    );
  }
}

class _TitleWithItalic extends StatelessWidget {
  final String plain;
  final String italic;
  final TextAlign textAlign;
  const _TitleWithItalic({
    required this.plain,
    required this.italic,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final base = LumaText.title();
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: plain),
          TextSpan(
            text: italic,
            style: base.copyWith(
              fontStyle: FontStyle.italic,
              color: LumaColors.goldSoft,
            ),
          ),
        ],
      ),
      textAlign: textAlign,
    );
  }
}

class _BrandLine extends StatelessWidget {
  const _BrandLine();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        Text('LUMA · ', style: LumaText.brandLine()),
        Text(
          'Knowledge Illuminated',
          textAlign: TextAlign.center,
          style: LumaText.brandLineItalic(),
        ),
      ],
    );
  }
}

class _AudienceChip extends StatelessWidget {
  final String label;
  const _AudienceChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: LumaColors.navy.withOpacity(0.4),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: LumaColors.goldSoft.withOpacity(0.35),
          width: 0.5,
        ),
      ),
      child: Text(label.toUpperCase(), style: LumaText.chip()),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    const tiles = <_FeatureData>[
      _FeatureData(
        Icons.emergency_outlined,
        'Crisis Hub',
        'Organized clinical crisis references.',
      ),
      _FeatureData(
        Icons.medication_outlined,
        'Drug Library',
        'Dosing, precautions, and sources.',
      ),
      _FeatureData(
        Icons.water_drop_outlined,
        'Vasopressors & Infusions',
        'Preparation and clinical context.',
      ),
      _FeatureData(
        Icons.menu_book_outlined,
        'Quick References',
        'Searchable, source-linked guidance.',
      ),
      _FeatureData(
        Icons.school_outlined,
        'CE HALO',
        'Course information and learning access.',
      ),
      _FeatureData(
        Icons.favorite_outline,
        'Provider Support',
        'Always free. No account required.',
      ),
    ];

    // Responsive grid: 2 columns on narrow phones, 3 columns everywhere else.
    // Tiles size their height to content instead of stretching to a fixed
    // aspect ratio, so they look balanced on both phone and desktop.
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width < 380 ? 2 : 3;
        const gap = 10.0;
        final tileWidth = (width - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: tiles
              .map(
                (t) => SizedBox(
                  width: tileWidth,
                  child: _FeatureTile(data: t),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String sub;
  const _FeatureData(this.icon, this.title, this.sub);
}

class _FeatureTile extends StatelessWidget {
  final _FeatureData data;
  const _FeatureTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LumaColors.navy.withOpacity(0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: LumaColors.goldSoft.withOpacity(0.18),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, size: 22, color: LumaColors.goldSoft),
          const SizedBox(height: 8),
          Text(data.title, style: LumaText.featureTitle()),
          const SizedBox(height: 4),
          Text(data.sub, style: LumaText.featureSub()),
        ],
      ),
    );
  }
}
