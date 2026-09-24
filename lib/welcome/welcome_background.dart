// Ambient background shared across all four welcome slides.
// - Deep navy gradient sky
// - Procedural twinkling starfield (48 stars, staggered cycles)
// - Custom-painted North Star (cross rays + slow-rotating diagonal glints + warm bloom)
// - Distant drifting planet
// - Blurred gold silk ribbons flowing through the middle band
// - Halo behind the hero icon (fades out on slides 2-4)
//
// All rhythms sync through a single AnimationController — the North Star, halo,
// and moon-glow all breathe on the same 5-second beat.

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'luma_theme.dart';

class WelcomeBackground extends StatefulWidget {
  final double heroHaloOpacity; // 1.0 on slide 1, 0.0 on slides 2-4
  const WelcomeBackground({super.key, required this.heroHaloOpacity});

  @override
  State<WelcomeBackground> createState() => _WelcomeBackgroundState();
}

class _WelcomeBackgroundState extends State<WelcomeBackground>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;    // synced 5s beat for North Star + halo
  late final AnimationController _spin;     // 90s slow rotation for diagonal glints
  late final AnimationController _drift;    // 40s slow North Star drift
  late final AnimationController _silk;     // 24s silk ribbon drift
  late final AnimationController _planet;   // 55s planet orbit
  late final AnimationController _twinkle;  // 4s cycle for starfield master phase

  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    _pulse   = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);
    _spin    = AnimationController(vsync: this, duration: const Duration(seconds: 90))..repeat();
    _drift   = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat(reverse: true);
    _silk    = AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat(reverse: true);
    _planet  = AnimationController(vsync: this, duration: const Duration(seconds: 55))..repeat(reverse: true);
    _twinkle = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

    // Deterministic starfield seed so the layout is stable across rebuilds
    final rand = math.Random(20260920);
    _stars = List.generate(48, (i) {
      final size = i % 7 == 0 ? _StarSize.big : (i % 3 == 0 ? _StarSize.tiny : _StarSize.mid);
      return _Star(
        dx: rand.nextDouble(),
        dy: rand.nextDouble(),
        size: size,
        phase: rand.nextDouble(),
        cycle: 2.4 + rand.nextDouble() * 2.8,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    for (final controller in [_pulse, _spin, _drift, _silk, _planet, _twinkle]) {
      if (reducedMotion) {
        controller.stop();
      } else if (!controller.isAnimating) {
        controller.repeat(
            reverse: controller == _pulse ||
                controller == _drift ||
                controller == _silk ||
                controller == _planet);
      }
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    _spin.dispose();
    _drift.dispose();
    _silk.dispose();
    _planet.dispose();
    _twinkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.3,
            colors: [
              LumaColors.navyMid,
              LumaColors.navy,
              LumaColors.navyEdge,
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Silk ribbons (bottom layer, blurred)
            _AnimatedLayer(
              controller: _silk,
              builder: (t) => Transform.translate(
                offset: Offset(-size.width * 0.01 + t * size.width * 0.025, -size.height * 0.01 * t),
                child: Transform.rotate(
                  angle: 0.011 * t,
                  child: CustomPaint(
                    painter: _SilkPainter(),
                    size: Size(size.width * 1.2, size.height * 1.2),
                  ),
                ),
              ),
            ),

            // Twinkling starfield
            _AnimatedLayer(
              controller: _twinkle,
              builder: (t) => CustomPaint(
                painter: _StarfieldPainter(stars: _stars, masterPhase: t),
                size: size,
              ),
            ),

            // Drifting planet (lower-left)
            _AnimatedLayer(
              controller: _planet,
              builder: (t) {
                final eased = Curves.easeInOut.transform(t);
                return Positioned(
                  left: 42 + eased * 20,
                  bottom: 130 + eased * 12,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        center: Alignment(-0.4, -0.5),
                        colors: [Color(0xFF4A7FA8), Color(0xFF1E4A6B), Color(0xFF0A2035)],
                        stops: [0.0, 0.6, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A7FA8).withOpacity(0.28),
                          blurRadius: 22,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const _PlanetInnerShadow(),
                  ),
                );
              },
            ),

            // North Star (upper-right) — drift + pulse + spin combined
            AnimatedBuilder(
              animation: Listenable.merge([_drift, _pulse, _spin]),
              builder: (context, _) {
                final driftT = Curves.easeInOut.transform(_drift.value);
                final pulseT = Curves.easeInOut.transform(_pulse.value);
                return Positioned(
                  top: 40 - driftT * 8,
                  right: 60 + driftT * 10,
                  child: SizedBox(
                    width: 170,
                    height: 170,
                    child: CustomPaint(
                      painter: _NorthStarPainter(
                        pulse: pulseT,       // 0..1..0
                        spinTurns: _spin.value,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Halo behind the hero icon — only visible on slide 1
            AnimatedOpacity(
              opacity: widget.heroHaloOpacity,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) {
                  final t = Curves.easeInOut.transform(_pulse.value);
                  final scale = 1.0 + t * 0.04;
                  return Align(
                    alignment: const Alignment(0, -0.28),
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 380,
                        height: 380,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color(0x6BF0D48A), // gold hot, ~42% alpha
                              Color(0x33D4A95A),
                              Color(0x000F2A3D),
                            ],
                            stops: [0.0, 0.3, 0.62],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Star field
// ────────────────────────────────────────────────────────────────────────────

enum _StarSize { tiny, mid, big }

class _Star {
  final double dx;   // 0..1 position across screen
  final double dy;
  final _StarSize size;
  final double phase; // 0..1 phase offset
  final double cycle; // seconds
  const _Star({required this.dx, required this.dy, required this.size, required this.phase, required this.cycle});
}

class _StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double masterPhase; // 0..1 loop from twinkle controller
  _StarfieldPainter({required this.stars, required this.masterPhase});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      // Blend each star's own cycle with the shared phase so twinkle looks organic
      final t = (masterPhase + s.phase) % 1.0;
      final wave = 0.5 - 0.5 * math.cos(t * math.pi * 2);
      final opacity = 0.25 + wave * 0.75;
      final scale = 0.8 + wave * 0.35;

      final radius = switch (s.size) {
        _StarSize.tiny => 0.75 * scale,
        _StarSize.mid  => 1.0  * scale,
        _StarSize.big  => 1.5  * scale,
      };

      final color = s.size == _StarSize.big
          ? LumaColors.goldSoft.withOpacity(opacity)
          : LumaColors.cream.withOpacity(opacity);

      final glowPaint = Paint()
        ..color = color.withOpacity(opacity * 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      final corePaint = Paint()..color = color;

      final center = Offset(s.dx * size.width, s.dy * size.height);
      canvas.drawCircle(center, radius * 2.2, glowPaint);
      canvas.drawCircle(center, radius, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter old) => old.masterPhase != masterPhase;
}

// ────────────────────────────────────────────────────────────────────────────
// North Star painter — cross rays + slow-rotating diagonal glints + bloom
// ────────────────────────────────────────────────────────────────────────────

class _NorthStarPainter extends CustomPainter {
  final double pulse;      // 0..1..0 breath
  final double spinTurns;  // 0..1 continuous
  _NorthStarPainter({required this.pulse, required this.spinTurns});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final scaleFactor = 1.0 + pulse * 0.06;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scaleFactor);
    canvas.translate(-cx, -cy);

    // Outer bloom halo
    final bloomRect = Rect.fromCircle(center: Offset(cx, cy), radius: w * 0.48);
    canvas.drawRect(
      bloomRect,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(cx, cy),
          w * 0.48,
          [
            const Color(0x8CFFF0BE), // rgba(255,240,190,0.55)
            const Color(0x47F0D48A),
            const Color(0x1AD4A95A),
            const Color(0x00D4A95A),
          ],
          [0.0, 0.35, 0.65, 1.0],
        ),
    );

    // Slow-rotating diagonal rays layer
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(spinTurns * 2 * math.pi);
    canvas.translate(-cx, -cy);
    _drawRay(canvas, cx, cy, w, angleDeg: 45,  thickness: 3.2, length: w * 0.9, color: const Color(0xBFF0D48A));
    _drawRay(canvas, cx, cy, w, angleDeg: -45, thickness: 3.2, length: w * 0.9, color: const Color(0xBFF0D48A));
    canvas.restore();

    // Long vertical spike (top & bottom) — classic star of Bethlehem shape
    _drawSpike(canvas, cx, cy, w, angleDeg: 90,  length: w * 0.47);
    _drawSpike(canvas, cx, cy, w, angleDeg: 270, length: w * 0.47);
    _drawSpike(canvas, cx, cy, w, angleDeg: 0,   length: w * 0.40);
    _drawSpike(canvas, cx, cy, w, angleDeg: 180, length: w * 0.40);

    // Inner warm glow disc
    final glowRadius = w * 0.13;
    canvas.drawCircle(
      Offset(cx, cy),
      glowRadius,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(cx, cy),
          glowRadius,
          [
            const Color(0xFFFFFFFF),
            const Color(0xFFFFF7DD),
            const Color(0xFFF0D48A),
            const Color(0x00D4A95A),
          ],
          [0.0, 0.18, 0.42, 1.0],
        ),
    );

    // Bright core
    canvas.drawCircle(Offset(cx, cy), w * 0.030, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx, cy), w * 0.013, Paint()..color = const Color(0xFFFFF7DD));

    canvas.restore();
  }

  void _drawSpike(Canvas canvas, double cx, double cy, double w,
      {required double angleDeg, required double length}) {
    // A slim diamond spike that fades to transparent at the tip
    final rad = angleDeg * math.pi / 180;
    final tip = Offset(cx + math.cos(rad) * length, cy + math.sin(rad) * length);
    final perp = angleDeg * math.pi / 180 + math.pi / 2;
    final halfWidth = 1.6;
    final base1 = Offset(cx + math.cos(perp) * halfWidth, cy + math.sin(perp) * halfWidth);
    final base2 = Offset(cx - math.cos(perp) * halfWidth, cy - math.sin(perp) * halfWidth);
    final path = Path()
      ..moveTo(base1.dx, base1.dy)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(base2.dx, base2.dy)
      ..close();

    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(cx, cy),
        tip,
        [const Color(0xF2FFF8DC), const Color(0x00FFF8DC)],
      );
    canvas.drawPath(path, paint);
  }

  void _drawRay(Canvas canvas, double cx, double cy, double w,
      {required double angleDeg, required double thickness, required double length, required Color color}) {
    // A long slim rectangle centered on origin, then rotated
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angleDeg * math.pi / 180);
    final rect = Rect.fromLTWH(-length / 2, -thickness / 2, length, thickness);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(-length / 2, 0),
          Offset(length / 2, 0),
          [Colors.transparent, color, Colors.transparent],
          [0.0, 0.5, 1.0],
        ),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _NorthStarPainter old) =>
      old.pulse != pulse || old.spinTurns != spinTurns;
}

// ────────────────────────────────────────────────────────────────────────────
// Silk ribbons
// ────────────────────────────────────────────────────────────────────────────

class _SilkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    final ribbon1 = Path()
      ..moveTo(-40, size.height * 0.73)
      ..cubicTo(size.width * 0.22, size.height * 0.6, size.width * 0.47, size.height * 0.87, size.width * 0.75, size.height * 0.67)
      ..cubicTo(size.width * 1.08, size.height * 0.60, size.width * 1.08, size.height * 0.53, size.width * 1.15, size.height * 0.53);

    final ribbon2 = Path()
      ..moveTo(-40, size.height * 0.40)
      ..cubicTo(size.width * 0.28, size.height * 0.47, size.width * 0.53, size.height * 0.27, size.width * 0.75, size.height * 0.43)
      ..cubicTo(size.width * 1.08, size.height * 0.50, size.width * 1.08, size.height * 0.40, size.width * 1.15, size.height * 0.40);

    final paintTop = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(size.width, size.height * 0.4),
        [
          const Color(0x00F0D48A), const Color(0x8CF0D48A), const Color(0xC0FFEBB4),
          const Color(0x73D4A95A), const Color(0x00D4A95A),
        ],
        [0.0, 0.35, 0.5, 0.65, 1.0],
      )
      ..strokeWidth = 70
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawPath(ribbon1, paintTop);

    final paintMid = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(size.width, size.height * 0.2),
        [const Color(0x00E6CF9C), const Color(0x73E6CF9C), const Color(0x00E6CF9C)],
        [0.0, 0.5, 1.0],
      )
      ..strokeWidth = 46
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawPath(ribbon2, paintMid);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SilkPainter old) => false;
}

// ────────────────────────────────────────────────────────────────────────────
// Small helpers
// ────────────────────────────────────────────────────────────────────────────

class _AnimatedLayer extends StatelessWidget {
  final AnimationController controller;
  final Widget Function(double t) builder;
  const _AnimatedLayer({required this.controller, required this.builder});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => builder(controller.value),
    );
  }
}

class _PlanetInnerShadow extends StatelessWidget {
  const _PlanetInnerShadow();
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(0.7, 0.5),
          colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
          stops: const [0.6, 1.0],
        ),
      ),
    );
  }
}
