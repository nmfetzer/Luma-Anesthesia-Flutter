import 'package:flutter/material.dart';

import 'luma_theme.dart';
import 'welcome_background.dart';
import 'welcome_slides.dart';

/// Independent vertical reading areas inside a horizontal carousel.
/// Brand and actions occupy real layout space, never overlay the text.
class WelcomeCarousel extends StatefulWidget {
  const WelcomeCarousel({super.key, required this.onFinish});
  final VoidCallback onFinish;

  @override
  State<WelcomeCarousel> createState() => _WelcomeCarouselState();
}

class _WelcomeCarouselState extends State<WelcomeCarousel> {
  final _pages = PageController();
  int _index = 0;

  void jump(int index) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _pages.jumpToPage(index);
    } else {
      _pages.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: LumaColors.navyDeep,
    body: Stack(
      children: [
        WelcomeBackground(heroHaloOpacity: _index == 0 ? 1 : 0),
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                children: [
                  if (_index != 0)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/branding/luma_symbol_halo.png',
                            width: 32,
                            height: 40,
                            excludeFromSemantics: true,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Luma Anesthesia',
                              style: LumaText.wordmark().copyWith(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: PageView(
                      controller: _pages,
                      onPageChanged: (index) => setState(() => _index = index),
                      children: const [
                        _WelcomeReadingPage(
                          index: 0,
                          hero: true,
                          child: WelcomeSlideOne(),
                        ),
                        _WelcomeReadingPage(index: 1, child: WelcomeSlideTwo()),
                        _WelcomeReadingPage(
                          index: 2,
                          child: WelcomeSlideThree(),
                        ),
                        _WelcomeReadingPage(
                          index: 3,
                          child: WelcomeSlideFour(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var index = 0; index < 4; index++)
                              Semantics(
                                selected: index == _index,
                                child: IconButton(
                                  tooltip: 'Welcome page ${index + 1}',
                                  onPressed: () => jump(index),
                                  constraints: const BoxConstraints(
                                    minWidth: 44,
                                    minHeight: 44,
                                  ),
                                  icon: Container(
                                    width: 28,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: index == _index
                                          ? LumaColors.goldSoft
                                          : const Color(0xFF75838E),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            key: const ValueKey('welcome-next'),
                            onPressed: () => _index == 3
                                ? widget.onFinish()
                                : jump(_index + 1),
                            style: FilledButton.styleFrom(
                              backgroundColor: LumaColors.goldSoft,
                              foregroundColor: LumaColors.navyDeep,
                              minimumSize: const Size.fromHeight(48),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _index == 3 ? 'Get started' : 'Continue',
                              style: LumaText.cta(),
                            ),
                          ),
                        ),
                      ],
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

class _WelcomeReadingPage extends StatefulWidget {
  const _WelcomeReadingPage({
    required this.index,
    required this.child,
    this.hero = false,
  });
  final int index;
  final Widget child;
  final bool hero;

  @override
  State<_WelcomeReadingPage> createState() => _WelcomeReadingPageState();
}

class _WelcomeReadingPageState extends State<_WelcomeReadingPage> {
  final _scroll = ScrollController();
  final _more = ValueNotifier(false);

  void updateHint() {
    if (mounted && _scroll.hasClients) {
      _more.value = _scroll.position.extentAfter > 12;
    }
  }

  @override
  void initState() {
    super.initState();
    _scroll.addListener(updateHint);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _more.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      WidgetsBinding.instance.addPostFrameCallback((_) => updateHint());
      return Column(
        children: [
          Expanded(
            child: NotificationListener<ScrollMetricsNotification>(
              onNotification: (_) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => updateHint(),
                );
                return false;
              },
              child: Scrollbar(
                controller: _scroll,
                child: SingleChildScrollView(
                  key: ValueKey('welcome-scroll-${widget.index}'),
                  controller: _scroll,
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.hero) ...[
                        Image.asset(
                          'assets/branding/luma_symbol_halo.png',
                          width: 100,
                          height: constraints.maxHeight < 240 ? 56 : 90,
                          fit: BoxFit.contain,
                          excludeFromSemantics: true,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Luma',
                          key: const ValueKey('welcome-luma-wordmark'),
                          textAlign: TextAlign.center,
                          style: LumaText.title(
                            size: 32,
                            color: LumaColors.gold,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      widget.child,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Reserve a short hint line so showing it never changes scroll extent.
          ValueListenableBuilder<bool>(
            valueListenable: _more,
            builder: (context, more, _) => Visibility(
              visible: more,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  'Scroll to read more',
                  style: LumaText.body(
                    size: 12,
                    color: const Color(0xFFCCD6DE),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
