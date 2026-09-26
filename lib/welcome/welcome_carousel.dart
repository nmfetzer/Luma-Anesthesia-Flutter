// The full welcome carousel screen.
//
// Composition (bottom to top z):
// 1. WelcomeBackground — starfield, silk, planet, North Star, halo
// 2. Hero icon (AnimatedPositioned + AnimatedContainer) — morphs from centered
//    220px hero on slide 1 to a 44px corner mark on slides 2-4
// 3. Wordmark next to the corner mark on slides 2-4
// 4. PageView of the four slides
// 5. Footer — page dots + CTA button
//
// The "Get started" CTA on slide 4 calls the onFinish callback (wire to sign-in).

import 'package:flutter/material.dart';
import 'luma_theme.dart';
import 'welcome_background.dart';
import 'welcome_slides.dart';

class WelcomeCarousel extends StatefulWidget {
  final VoidCallback onFinish;
  const WelcomeCarousel({super.key, required this.onFinish});

  @override
  State<WelcomeCarousel> createState() => _WelcomeCarouselState();
}

class _WelcomeCarouselState extends State<WelcomeCarousel> {
  late final PageController _pageController;
  int _index = 0;
  static const _slideCount = 4;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_index >= _slideCount - 1) {
      widget.onFinish();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  void _jumpTo(int i) {
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHero = _index == 0;
    final safe = MediaQuery.paddingOf(context);
    final size = MediaQuery.sizeOf(context);

    // Icon-morph target values
    final heroSize = (size.height * 0.22).clamp(110.0, 190.0);
    final iconSize = isHero ? heroSize : 40.0;
    final iconLeft = isHero
        ? (size.width - iconSize) / 2
        : 22.0;
    final iconTop = isHero
        ? safe.top + size.height * 0.15
        : safe.top + 20.0;

    return Scaffold(
      backgroundColor: LumaColors.navyDeep,
      body: Stack(
        children: [
          // 1. Ambient background
          WelcomeBackground(heroHaloOpacity: isHero ? 1.0 : 0.0),

          // 2. Slide content (PageView)
          Positioned.fill(
            top: safe.top,
            bottom: 120,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _slideCount,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                // Push content below the hero icon area on slide 1
                final topPad = i == 0
                    ? size.height * 0.15 + heroSize + 70
                    : size.height * 0.28;
                return SingleChildScrollView(
                  padding: EdgeInsets.only(top: topPad),
                  child: switch (i) {
                    0 => const WelcomeSlideOne(),
                    1 => const WelcomeSlideTwo(),
                    2 => const WelcomeSlideThree(),
                    _ => const WelcomeSlideFour(),
                  },
                );
              },
            ),
          ),

          // 3. Hero icon — animated between center and corner
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubicEmphasized,
            left: iconLeft,
            top: iconTop,
            child: _FloatingIcon(
              size: iconSize,
              floating: isHero,
            ),
          ),

          // 4. Wordmark next to corner icon (slides 2-4)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubicEmphasized,
            left: isHero ? -200 : 74,
            top: safe.top + 30,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: isHero ? 0.0 : 1.0,
              child: Text('Luma Anesthesia', style: LumaText.wordmark()),
            ),
          ),

          // 5. Footer — dots + CTA
          Positioned(
            left: 28,
            right: 28,
            bottom: safe.bottom + 28,
            child: _Footer(
              index: _index,
              count: _slideCount,
              onDotTap: _jumpTo,
              ctaLabel: _index == _slideCount - 1 ? 'Get started' : 'Continue',
              onCta: _next,
              centered: true,
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Hero icon with subtle floating motion on slide 1
// ────────────────────────────────────────────────────────────────────────────

class _FloatingIcon extends StatefulWidget {
  final double size;
  final bool floating;
  const _FloatingIcon({required this.size, required this.floating});

  @override
  State<_FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<_FloatingIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_float.value);
        final dy = widget.floating && !MediaQuery.disableAnimationsOf(context)
            ? -6 * t
            : 0.0;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size + (widget.floating ? 54 : 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/branding/luma_symbol_halo.png',
              width: widget.size,
              height: widget.size,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
            if (widget.floating) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Luma',
                    key: const ValueKey('welcome-luma-wordmark'),
                    style: LumaText.title(size: 38, color: LumaColors.gold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Footer — page dots + CTA button
// ────────────────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  final int index;
  final int count;
  final ValueChanged<int> onDotTap;
  final String ctaLabel;
  final VoidCallback onCta;
  final bool centered;
  const _Footer({
    required this.index,
    required this.count,
    required this.onDotTap,
    required this.ctaLabel,
    required this.onCta,
    required this.centered,
  });

  @override
  Widget build(BuildContext context) {
    final dots = Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == index;
        return GestureDetector(
          onTap: () => onDotTap(i),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              width: active ? 32 : 22,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: active ? LumaColors.gold : LumaColors.cream.withOpacity(0.22),
              ),
            ),
          ),
        );
      }),
    );

    final cta = _CtaButton(label: ctaLabel, onPressed: onCta);

    if (centered) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          cta,
          const SizedBox(height: 16),
          dots,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [dots, cta],
    );
  }
}

class _CtaButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _CtaButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LumaColors.cream,
      shape: const StadiumBorder(),
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          child: Text(label, style: LumaText.cta()),
        ),
      ),
    );
  }
}
