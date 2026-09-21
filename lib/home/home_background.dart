import 'dart:math' as math;
import 'package:flutter/material.dart';

class HomeBackground extends StatefulWidget {
  const HomeBackground({super.key});

  @override
  State<HomeBackground> createState() => _HomeBackgroundState();
}

class _HomeBackgroundState extends State<HomeBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();

    final rng = math.Random(42);
    _stars = List.generate(60, (_) {
      return _Star(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: 0.8 + rng.nextDouble() * 1.4,
        period: 3.4 + rng.nextDouble() * 2.0,
        phase: rng.nextDouble() * math.pi * 2,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.6, -0.7),
            radius: 1.5,
            colors: [Color(0xFF133451), Color(0xFF0F2A3D), Color(0xFF08192B)],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _StarfieldPainter(stars: _stars, time: _controller.value * 10),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}

class _Star {
  final double x, y, size, period, phase;
  const _Star({required this.x, required this.y, required this.size, required this.period, required this.phase});
}

class _StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double time;
  _StarfieldPainter({required this.stars, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final phaseTime = (time / star.period * math.pi * 2) + star.phase;
      final t = (math.sin(phaseTime) + 1) / 2;
      final opacity = 0.2 + t * 0.65;
      final scale = 0.9 + t * 0.25;
      final paint = Paint()..color = const Color(0xFFF7F1E6).withValues(alpha: opacity);
      canvas.drawCircle(Offset(star.x * size.width, star.y * size.height), star.size * scale, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter old) => old.time != time;
}
