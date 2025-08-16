import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'dart:math' as math;
import 'package:open_simplex_2/open_simplex_2.dart';

class BarrenRockWidget extends StatefulWidget {
  final double size;
  final int healthLevel;

  const BarrenRockWidget({
    super.key,
    required this.size,
    required this.healthLevel,
  });

  @override
  State<BarrenRockWidget> createState() => _BarrenRockWidgetState();
}

class _BarrenRockWidgetState extends State<BarrenRockWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final wobble = math.sin(_controller.value * 2 * math.pi) * 0.03;
          final bob = math.sin(_controller.value * 2 * math.pi) * 2.0;
          return Transform.translate(
            offset: Offset(0, bob),
            child: Transform.rotate(
              angle: wobble,
              child: CustomPaint(
                painter: _MoonRockPainter(
                  progress: _controller.value,
                  healthLevel: widget.healthLevel,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MoonRockPainter extends CustomPainter {
  final double progress;
  final int healthLevel;

  _MoonRockPainter({required this.progress, required this.healthLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.44;
    final health = (healthLevel.clamp(0, 100)) / 100.0;
    final t = progress;

    // Soft atmosphere glow based on health
    final auraRadius = radius * (1.25 + 0.05 * math.sin(t * 2 * math.pi));
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.energyGreen.withOpacity(0.18 * (0.6 + 0.8 * health)),
          AppTheme.cosmicBlue.withOpacity(0.10 * (0.6 + 0.8 * health)),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: auraRadius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
      ..isAntiAlias = true;
    canvas.drawCircle(center, auraRadius, auraPaint);

    // Twinkling orbital particles around the planet
    final twinkle = Paint()..isAntiAlias = true;
    for (int i = 0; i < 28; i++) {
      final angle = (i * 0.23 + t * 2 * math.pi * (0.6 + (i % 3) * 0.12));
      final dist = radius * (1.35 + (i % 5) * 0.05);
      final x = center.dx + math.cos(angle) * dist;
      final y = center.dy + math.sin(angle) * dist * 0.65; // tilt
      final flicker =
          (math.sin(t * 2 * math.pi * (2.0 + (i % 4)) + i) + 1) * 0.5;
      final sizeDot = 1.5 + (i % 3) * 0.6 + flicker * 0.6;
      final color = (i % 3 == 0)
          ? AppTheme.energyGreen
          : (i % 3 == 1)
          ? AppTheme.starYellow
          : AppTheme.cosmicBlue;
      twinkle.color = color.withOpacity(0.5 + 0.4 * flicker);
      canvas.drawCircle(Offset(x, y), sizeDot, twinkle);
    }

    // Saturn-like tilted ring (behind sphere)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.25 + t * 0.6); // slow rotation
    canvas.scale(1.0, 0.55); // tilt the ring
    final ringR = radius * 1.35;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.08
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          AppTheme.cosmicBlue.withOpacity(0.25 + 0.35 * health),
          AppTheme.energyGreen.withOpacity(0.15 + 0.35 * health),
          Colors.transparent,
        ],
        stops: const [0.0, 0.2, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: ringR));
    // Draw ring behind by clipping top half
    final clipPathBack = Path()
      ..addOval(Rect.fromCircle(center: Offset.zero, radius: ringR))
      ..addRect(
        Rect.fromLTWH(-ringR * 2, 0, ringR * 4, ringR * 2),
      ); // keep bottom
    canvas.saveLayer(null, Paint());
    canvas.clipPath(clipPathBack);
    canvas.drawCircle(Offset.zero, ringR, ringPaint);
    canvas.restore();
    canvas.restore();

    // Ground contact shadow
    final shadowRect = Rect.fromCenter(
      center: center.translate(0, radius * 0.95),
      width: radius * 1.6,
      height: radius * 0.4,
    );
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawOval(shadowRect, shadowPaint);

    // Base sphere shading (light from top-right) - vibrant cosmic colors
    final baseColor = AppTheme.cosmicBlue.withOpacity(0.85); // vibrant blue
    final midColor = AppTheme.nebulaPurple.withOpacity(0.78); // purple mid-tone
    final darkEdge = AppTheme.spaceDark.withOpacity(0.92); // deep space edge
    final highlightColor = AppTheme.energyGreen.withOpacity(
      0.15,
    ); // subtle green highlight

    final spherePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.55, -0.55),
        radius: 1.1,
        colors: [baseColor, midColor, darkEdge],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..isAntiAlias = true;
    canvas.drawCircle(center, radius, spherePaint);

    // Add subtle highlight overlay for more dimension
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.3, -0.3),
        radius: 0.8,
        colors: [highlightColor, Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..isAntiAlias = true;
    canvas.drawCircle(center, radius, highlightPaint);

    // Ring front half (in front of sphere)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.25 + t * 0.6);
    canvas.scale(1.0, 0.55);
    final ringPaintFront = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.08
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          AppTheme.energyGreen.withOpacity(0.15 + 0.25 * health),
          AppTheme.starYellow.withOpacity(0.12 + 0.25 * health),
          Colors.transparent,
        ],
        stops: const [0.0, 0.2, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: ringR));
    final clipPathFront = Path()
      ..addOval(Rect.fromCircle(center: Offset.zero, radius: ringR))
      ..addRect(
        Rect.fromLTWH(-ringR * 2, -ringR * 2, ringR * 4, ringR),
      ); // keep top
    canvas.saveLayer(null, Paint());
    canvas.clipPath(clipPathFront);
    canvas.drawCircle(Offset.zero, ringR, ringPaintFront);
    canvas.restore();
    canvas.restore();

    // Surface texture using simplex noise speckling - colorful cosmic surface
    final noise = OpenSimplex2F(9321);
    final texPaint = Paint()..isAntiAlias = true;
    for (int i = 0; i < 1200; i++) {
      final a = (i / 1200) * 2 * math.pi * (1 + progress * 0.02);
      final r = radius * math.sqrt(i / 1200);
      final x = center.dx + math.cos(a) * r;
      final y = center.dy + math.sin(a) * r;
      final nx = (x - center.dx) / radius;
      final ny = (y - center.dy) / radius;
      if (nx * nx + ny * ny > 1) continue;
      final n = (noise.noise2(nx * 5.5, ny * 5.5) + 1) * 0.5;

      // Create colorful surface variations based on position and noise
      final angle = math.atan2(ny, nx);
      final distance = math.sqrt(nx * nx + ny * ny);

      Color surfaceColor;
      if (distance < 0.3) {
        // Center area - more purple/blue
        surfaceColor = AppTheme.nebulaPurple;
      } else if (distance < 0.7) {
        // Mid area - cosmic blue
        surfaceColor = AppTheme.cosmicBlue;
      } else {
        // Edge area - energy green accents
        surfaceColor = AppTheme.energyGreen;
      }

      final opacity =
          (0.15 + n * 0.25) * (0.8 + 0.4 * math.sin(angle * 3 + progress * 2));
      texPaint.color = surfaceColor.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), 0.8 + n * 0.9, texPaint);
    }

    // Orbiting satellites (front-most), subtle glow
    final satPaint = Paint()..isAntiAlias = true;
    for (int i = 0; i < 3; i++) {
      final ang = t * 2 * math.pi * (0.4 + i * 0.15) + i * 2.1;
      final dist = radius * (1.55 + i * 0.18);
      final pos = Offset(
        center.dx + math.cos(ang) * dist,
        center.dy + math.sin(ang) * dist * 0.65,
      );
      final sz = radius * (0.06 + i * 0.015);
      final glow = Paint()
        ..color = AppTheme.energyGreen.withOpacity(0.25 + 0.35 * health)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(pos, sz * 1.4, glow);
      satPaint.color = Colors.white.withOpacity(0.9);
      canvas.drawCircle(pos, sz, satPaint);
    }

    // Craters: position list to look intentional like the reference
    void drawCrater(Offset p, double r) {
      // inner shadow
      final inner = Paint()
        ..shader = RadialGradient(
          colors: [Colors.black.withOpacity(0.45), Colors.transparent],
        ).createShader(Rect.fromCircle(center: p, radius: r * 1.15));
      canvas.drawCircle(p, r, inner);

      // rim highlight on the lit side
      final rim = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.22
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: -math.pi,
          endAngle: math.pi,
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.18),
            Colors.transparent,
          ],
          stops: const [0.0, 0.25, 1.0],
        ).createShader(Rect.fromCircle(center: p, radius: r * 1.05));
      canvas.drawArc(
        Rect.fromCircle(center: p, radius: r * 1.05),
        -0.6,
        1.6,
        false,
        rim,
      );
    }

    final craterPositions = <Offset>[
      center + Offset(radius * 0.35, -radius * 0.22),
      center + Offset(-radius * 0.22, -radius * 0.08),
      center + Offset(radius * 0.28, radius * 0.12),
      center + Offset(-radius * 0.05, radius * 0.32),
      center + Offset(-radius * 0.33, radius * 0.28),
    ];
    final craterSizes = [
      radius * 0.11,
      radius * 0.09,
      radius * 0.08,
      radius * 0.07,
      radius * 0.06,
    ];
    for (int i = 0; i < craterPositions.length; i++) {
      drawCrater(craterPositions[i], craterSizes[i]);
    }

    // Crack networks (darker hairlines)
    final crack = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
    final rnd = math.Random(3211);
    for (int i = 0; i < 9; i++) {
      final startAngle = rnd.nextDouble() * 2 * math.pi;
      final start =
          center +
          Offset(math.cos(startAngle), math.sin(startAngle)) *
              (radius * (0.15 + rnd.nextDouble() * 0.5));
      final segments = 4 + rnd.nextInt(4);
      var curr = start;
      for (int s = 0; s < segments; s++) {
        final dir = startAngle + (rnd.nextDouble() - 0.5) * 0.8;
        final step = radius * (0.08 + rnd.nextDouble() * 0.12);
        final next = curr + Offset(math.cos(dir) * step, math.sin(dir) * step);
        // keep inside sphere
        final nx = (next.dx - center.dx) / radius;
        final ny = (next.dy - center.dy) / radius;
        if (nx * nx + ny * ny < 0.98) {
          canvas.drawLine(curr, next, crack);
          curr = next;
        }
      }
    }

    // Occasional comet streak to add delight (appears once per cycle)
    if ((t % 1.0) < 0.25) {
      final phase = (t % 0.25) / 0.25;
      final cometPos = Offset(
        size.width * (1.2 - phase * 1.6),
        size.height * (0.15 + phase * 0.3),
      );
      final cometTrail = Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white.withOpacity(0.0),
                AppTheme.starYellow.withOpacity(0.9),
                Colors.white.withOpacity(0.0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(
              Rect.fromLTWH(
                cometPos.dx - radius * 0.8,
                cometPos.dy - 2,
                radius * 1.6,
                4,
              ),
            )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      final p1 = Offset(cometPos.dx - radius * 0.8, cometPos.dy);
      final p2 = Offset(cometPos.dx + radius * 0.8, cometPos.dy);
      canvas.drawLine(p1, p2, cometTrail);
      final cometHead = Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(cometPos, 3.5, cometHead);
    }

    // Moss/lichen around cracks and crater rims (healthy planets get more)
    if (healthLevel >= 55) {
      final moss = Paint()
        ..color = AppTheme.energyGreen.withOpacity(
          0.10 + (healthLevel / 100) * 0.15,
        );
      for (final p in craterPositions) {
        canvas.drawCircle(p.translate(-4, -2), radius * 0.045, moss);
      }
      final rand = math.Random(9876);
      for (int i = 0; i < 60; i++) {
        final a = rand.nextDouble() * 2 * math.pi;
        final r = radius * (0.2 + rand.nextDouble() * 0.65);
        final pos = center + Offset(math.cos(a) * r, math.sin(a) * r);
        final nx = (pos.dx - center.dx) / radius;
        final ny = (pos.dy - center.dy) / radius;
        if (nx * nx + ny * ny < 0.98) {
          canvas.drawCircle(pos, 1.6, moss);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MoonRockPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.healthLevel != healthLevel;
  }
}
