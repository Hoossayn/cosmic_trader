import 'package:flutter/material.dart';
import 'dart:math' as math;

class NebulaPlanetWidget extends StatefulWidget {
  final double size;
  final int healthLevel;

  const NebulaPlanetWidget({
    Key? key,
    required this.size,
    required this.healthLevel,
  }) : super(key: key);

  @override
  State<NebulaPlanetWidget> createState() => _NebulaPlanetWidgetState();
}

class _NebulaPlanetWidgetState extends State<NebulaPlanetWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _swirlController;
  late AnimationController _pulseController;
  late AnimationController _stormController;
  late List<AnimationController> _moonControllers;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    _swirlController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _stormController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    final moonCount = _getMoonCount();
    _moonControllers = List.generate(
      moonCount,
          (index) => AnimationController(
        duration: Duration(seconds: 18 + (index * 6)),
        vsync: this,
      )..repeat(),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _swirlController.dispose();
    _pulseController.dispose();
    _stormController.dispose();
    for (final controller in _moonControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  int _getMoonCount() {
    if (widget.healthLevel >= 80) return 5;
    if (widget.healthLevel >= 60) return 4;
    if (widget.healthLevel >= 40) return 3;
    if (widget.healthLevel >= 20) return 2;
    return 1;
  }

  List<Color> _getPlanetColors() {
    if (widget.healthLevel >= 70) {
      return [const Color(0xFF00FF88), const Color(0xFF008844), const Color(0xFF004422)];
    } else if (widget.healthLevel >= 40) {
      return [const Color(0xFFFF8800), const Color(0xFF993300), const Color(0xFF441100)];
    } else {
      return [const Color(0xFFFF0033), const Color(0xFF660000), const Color(0xFF111111)];
    }
  }

  bool _shouldGlow() {
    return widget.healthLevel >= 40;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 1.6,
      height: widget.size * 1.6,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Star field background
          CustomPaint(
            size: Size(widget.size * 1.6, widget.size * 1.6),
            painter: _StarFieldPainter(twinkle: _pulseController.value),
          ),

          // Outer glow/aura
          if (_shouldGlow())
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: widget.size + (_pulseController.value * 40),
                  height: widget.size + (_pulseController.value * 40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        _getPlanetColors().first.withOpacity(0.1 * _pulseController.value),
                        _getPlanetColors().first.withOpacity(0.05 * _pulseController.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),

          // Mini moons
          ..._buildMoons(),

          // Main planet
          AnimatedBuilder(
            animation: Listenable.merge([
              _rotationController,
              _swirlController,
              _pulseController,
              _stormController,
            ]),
            builder: (context, child) {
              return Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: _shouldGlow()
                      ? [
                    BoxShadow(
                      color: _getPlanetColors().first.withOpacity(0.4),
                      blurRadius: 25 + (_pulseController.value * 15),
                      spreadRadius: 8 + (_pulseController.value * 8),
                    ),
                  ]
                      : null,
                ),
                child: ClipOval(
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: NebulaSpherePainter(
                      colors: _getPlanetColors(),
                      healthLevel: widget.healthLevel,
                      rotationProgress: _rotationController.value,
                      swirlProgress: _swirlController.value,
                      pulseProgress: _pulseController.value,
                      stormProgress: _stormController.value,
                      lightDirection: const Offset(-0.6, -0.5),
                    ),
                  ),
                ),
              );
            },
          ),

          // Atmospheric effects overlay
          AnimatedBuilder(
            animation: _swirlController,
            builder: (context, child) {
              return SizedBox(
                width: widget.size,
                height: widget.size,
                child: ClipOval(
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: AtmospherePainter(
                      colors: _getPlanetColors(),
                      healthLevel: widget.healthLevel,
                      progress: _swirlController.value,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMoons() {
    final moonCount = _getMoonCount();
    final planetColors = _getPlanetColors();

    return List.generate(moonCount, (index) {
      final moonColor = Color.lerp(
        planetColors[1],
        Colors.black,
        0.4,
      )!;

      return AnimatedBuilder(
        animation: _moonControllers[index],
        builder: (context, child) {
          final angle = (_moonControllers[index].value * 2 * math.pi) +
              (index * (2 * math.pi / moonCount));
          final radius = (widget.size * 0.8) + (index * 15);
          final moonSize = widget.size * (0.06 + index * 0.01) * (1.2 - index * 0.15);

          final x = math.cos(angle) * radius;
          final y = math.sin(angle) * radius * 0.7; // Flattened orbit

          return Transform.translate(
            offset: Offset(x, y),
            child: Container(
              width: moonSize,
              height: moonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.3),
                  colors: [
                    moonColor.withOpacity(0.9),
                    moonColor.withOpacity(0.6),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: moonColor.withOpacity(0.3),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

class _StarFieldPainter extends CustomPainter {
  final double twinkle;

  _StarFieldPainter({required this.twinkle});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(42);
    final paint = Paint();

    // Generate twinkling stars
    for (int i = 0; i < 150; i++) {
      final dx = rand.nextDouble() * size.width;
      final dy = rand.nextDouble() * size.height;
      final brightness = 0.3 + rand.nextDouble() * 0.7;
      final twinklePhase = math.sin(twinkle * 2 * math.pi + i * 0.1);
      final size_mult = (0.8 + twinklePhase * 0.4);
      final r = (rand.nextDouble() * 1.5 + 0.5) * size_mult;

      paint.color = Colors.white.withOpacity(brightness * (0.7 + twinkle * 0.3));
      canvas.drawCircle(Offset(dx, dy), r, paint);

      // Add glow for brighter stars
      if (brightness > 0.7) {
        paint.color = Colors.white.withOpacity(brightness * 0.2);
        canvas.drawCircle(Offset(dx, dy), r * 3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter oldDelegate) => oldDelegate.twinkle != twinkle;
}

class NebulaSpherePainter extends CustomPainter {
  final List<Color> colors;
  final int healthLevel;
  final double rotationProgress;
  final double swirlProgress;
  final double pulseProgress;
  final double stormProgress;
  final Offset lightDirection;

  NebulaSpherePainter({
    required this.colors,
    required this.healthLevel,
    required this.rotationProgress,
    required this.swirlProgress,
    required this.pulseProgress,
    required this.stormProgress,
    required this.lightDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Base sphere with lighting
    _drawBaseSphere(canvas, size, center, radius);

    // Surface terrain and features
    _drawSurfaceTerrain(canvas, size, center, radius);

    // Energy patterns based on health
    _drawEnergyPatterns(canvas, size, center, radius);

    // Storm systems
    if (healthLevel >= 40) {
      _drawStormSystems(canvas, size, center, radius);
    }

    // City lights for high health
    if (healthLevel >= 70) {
      _drawCityLights(canvas, size, center, radius);
    }

    // Cracks and damage for low health
    if (healthLevel < 40) {
      _drawDamageEffects(canvas, size, center, radius);
    }

    // Specular highlight
    _drawSpecularHighlight(canvas, size, center, radius);
  }

  void _drawBaseSphere(Canvas canvas, Size size, Offset center, double radius) {
    final gradient = RadialGradient(
      center: Alignment(lightDirection.dx, lightDirection.dy),
      radius: 1.2,
      colors: [
        colors[0].withOpacity(0.95),
        colors[1].withOpacity(0.8),
        colors[2].withOpacity(0.9),
        Colors.black.withOpacity(0.95),
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius, paint);
  }

  void _drawSurfaceTerrain(Canvas canvas, Size size, Offset center, double radius) {
    final rand = math.Random(7777);
    final paint = Paint()..isAntiAlias = true;

    // Generate detailed surface features using noise-like patterns
    for (int i = 0; i < 2000; i++) {
      final angle = rand.nextDouble() * 2 * math.pi;
      final dist = rand.nextDouble() * radius;
      final pos = center + Offset(math.cos(angle), math.sin(angle)) * dist;

      final dx = (pos.dx - center.dx) / radius;
      final dy = (pos.dy - center.dy) / radius;
      final inside = dx * dx + dy * dy <= 1.0;
      if (!inside) continue;

      // Simulate terrain elevation using multiple noise octaves
      final noise1 = _noise2D(dx * 8 + rotationProgress * 2, dy * 8);
      final noise2 = _noise2D(dx * 16 + rotationProgress * 3, dy * 16) * 0.5;
      final noise3 = _noise2D(dx * 32 + rotationProgress * 4, dy * 32) * 0.25;
      final elevation = (noise1 + noise2 + noise3) / 1.75;

      // Determine terrain type based on elevation and health
      final isLand = elevation > 0.3;
      final isCoastal = (elevation - 0.3).abs() < 0.15;

      Color terrainColor;
      double opacity;
      double featureSize;

      if (healthLevel >= 70) {
        if (isLand) {
          terrainColor = Color.lerp(colors[0], colors[1], elevation)!;
          opacity = 0.3 + elevation * 0.2;
          featureSize = 1.5 + elevation * 2;
        } else {
          terrainColor = Color.lerp(
              const Color(0xFF0066BB),
              colors[0],
              elevation + 0.5
          )!;
          opacity = 0.2 + (1 - elevation) * 0.15;
          featureSize = 1.2 + (1 - elevation) * 1.5;
        }
      } else if (healthLevel >= 40) {
        terrainColor = Color.lerp(colors[0], colors[1], elevation)!;
        opacity = 0.25 + elevation * 0.2;
        featureSize = 1.3 + elevation * 1.8;
      } else {
        terrainColor = Color.lerp(colors[1], colors[2], elevation)!;
        opacity = 0.3 + elevation * 0.25;
        featureSize = 1.8 + elevation * 1.2;
      }

      // Add coastal effects
      if (isCoastal && healthLevel >= 60) {
        terrainColor = Color.lerp(terrainColor, Colors.white, 0.3)!;
        opacity *= 1.4;
      }

      paint.shader = RadialGradient(
        colors: [terrainColor.withOpacity(opacity), Colors.transparent],
      ).createShader(Rect.fromCircle(center: pos, radius: featureSize));

      canvas.drawCircle(pos, featureSize, paint);
    }
  }

  void _drawEnergyPatterns(Canvas canvas, Size size, Offset center, double radius) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    // Swirling energy patterns
    final patternCount = healthLevel >= 70 ? 8 : (healthLevel >= 40 ? 5 : 3);

    for (int i = 0; i < patternCount; i++) {
      final baseRadius = radius * (0.2 + i * 0.1);
      final opacity = healthLevel >= 40 ? 0.4 : 0.6;
      final phase = swirlProgress * 2 * math.pi + i * 0.8;

      paint.color = colors[i % colors.length].withOpacity(opacity);
      paint.strokeWidth = healthLevel >= 70 ? 2.5 : 1.8;

      final path = Path();
      bool first = true;

      for (double angle = 0; angle < 4 * math.pi; angle += 0.15) {
        final spiralRadius = baseRadius +
            math.sin(angle * 2 + phase) * (radius * 0.05) +
            math.cos(angle * 3 + phase * 1.5) * (radius * 0.03);

        final adjustedAngle = angle + rotationProgress * 2 * math.pi;
        final x = center.dx + math.cos(adjustedAngle) * spiralRadius;
        final y = center.dy + math.sin(adjustedAngle) * spiralRadius;

        if (first) {
          path.moveTo(x, y);
          first = false;
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  void _drawStormSystems(Canvas canvas, Size size, Offset center, double radius) {
    final rand = math.Random(4242);
    final paint = Paint()..isAntiAlias = true;

    // Generate storm vortices
    for (int i = 0; i < 6; i++) {
      final stormAngle = (i * math.pi / 3) + stormProgress * math.pi;
      final stormDist = radius * (0.3 + rand.nextDouble() * 0.4);
      final stormPos = center + Offset(
        math.cos(stormAngle) * stormDist,
        math.sin(stormAngle) * stormDist,
      );

      final stormSize = radius * (0.08 + rand.nextDouble() * 0.06);
      final intensity = 0.5 + math.sin(stormProgress * 4 * math.pi + i) * 0.3;

      // Create swirling storm pattern
      for (int j = 0; j < 12; j++) {
        final spiralAngle = (j * math.pi / 6) + stormProgress * 4 * math.pi;
        final spiralRadius = stormSize * (j / 12.0) * intensity;
        final spiralPos = stormPos + Offset(
          math.cos(spiralAngle) * spiralRadius,
          math.sin(spiralAngle) * spiralRadius,
        );

        paint.shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.8 * intensity),
            Colors.white.withOpacity(0.2 * intensity),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: spiralPos, radius: stormSize * 0.3));

        canvas.drawCircle(spiralPos, stormSize * 0.3, paint);
      }
    }
  }

  void _drawCityLights(Canvas canvas, Size size, Offset center, double radius) {
    final rand = math.Random(1337);
    final paint = Paint()..isAntiAlias = true;

    // Simulate night side city lights
    for (int i = 0; i < 80; i++) {
      final angle = rand.nextDouble() * 2 * math.pi;
      final dist = rand.nextDouble() * radius * 0.8;
      final pos = center + Offset(math.cos(angle), math.sin(angle)) * dist;

      final dx = (pos.dx - center.dx) / radius;
      final dy = (pos.dy - center.dy) / radius;
      final inside = dx * dx + dy * dy <= 1.0;
      if (!inside) continue;

      // Check if on night side
      final dot = dx * lightDirection.dx + dy * lightDirection.dy;
      final isNight = dot < -0.1;

      if (isNight && rand.nextDouble() < 0.6) {
        final lightSize = 1.2 + rand.nextDouble() * 2.0;
        final brightness = 0.6 + rand.nextDouble() * 0.4;

        paint.shader = RadialGradient(
          colors: [
            const Color(0xFFFFDD44).withOpacity(brightness),
            const Color(0xFFFFAA00).withOpacity(brightness * 0.5),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: pos, radius: lightSize * 2));

        canvas.drawCircle(pos, lightSize * 2, paint);
      }
    }
  }

  void _drawDamageEffects(Canvas canvas, Size size, Offset center, double radius) {
    final rand = math.Random(6666);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    // Draw chaotic cracks and fissures
    for (int i = 0; i < 15; i++) {
      final startAngle = rand.nextDouble() * 2 * math.pi;
      final startDist = radius * (0.2 + rand.nextDouble() * 0.6);
      final start = center + Offset(
        math.cos(startAngle) * startDist,
        math.sin(startAngle) * startDist,
      );

      paint.color = Colors.black.withOpacity(0.7);
      paint.strokeWidth = 2.0 + rand.nextDouble() * 2.0;

      final path = Path();
      path.moveTo(start.dx, start.dy);

      // Create jagged crack pattern
      var currentPos = start;
      for (int j = 0; j < 8; j++) {
        final branchAngle = startAngle + (rand.nextDouble() - 0.5) * 1.5;
        final branchLength = radius * (0.05 + rand.nextDouble() * 0.1);
        currentPos += Offset(
          math.cos(branchAngle) * branchLength,
          math.sin(branchAngle) * branchLength,
        );
        path.lineTo(currentPos.dx, currentPos.dy);
      }

      canvas.drawPath(path, paint);
    }

    // Add dark volcanic spots
    for (int i = 0; i < 20; i++) {
      final angle = rand.nextDouble() * 2 * math.pi;
      final dist = rand.nextDouble() * radius * 0.9;
      final pos = center + Offset(math.cos(angle), math.sin(angle)) * dist;

      final spotSize = radius * (0.02 + rand.nextDouble() * 0.04);
      paint.style = PaintingStyle.fill;
      paint.shader = RadialGradient(
        colors: [
          Colors.black.withOpacity(0.9),
          colors[2].withOpacity(0.6),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: pos, radius: spotSize * 2));

      canvas.drawCircle(pos, spotSize * 2, paint);
    }
  }

  void _drawSpecularHighlight(Canvas canvas, Size size, Offset center, double radius) {
    final specCenter = center + Offset(
      radius * lightDirection.dx * 0.4,
      radius * lightDirection.dy * 0.4,
    );

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.4 + pulseProgress * 0.2),
          Colors.white.withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: specCenter, radius: radius * 0.25));

    canvas.drawCircle(specCenter, radius * 0.25, paint);
  }

  // Simple noise function for terrain generation
  double _noise2D(double x, double y) {
    final n = math.sin(x * 12.9898 + y * 78.233) * 43758.5453;
    return (n - n.floor()) * 2 - 1;
  }

  @override
  bool shouldRepaint(NebulaSpherePainter oldDelegate) {
    return oldDelegate.rotationProgress != rotationProgress ||
        oldDelegate.swirlProgress != swirlProgress ||
        oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.stormProgress != stormProgress ||
        oldDelegate.healthLevel != healthLevel;
  }
}

class AtmospherePainter extends CustomPainter {
  final List<Color> colors;
  final int healthLevel;
  final double progress;

  AtmospherePainter({
    required this.colors,
    required this.healthLevel,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    // Atmospheric bands and cloud layers
    final bandCount = healthLevel >= 70 ? 4 : (healthLevel >= 40 ? 3 : 2);

    for (int i = 0; i < bandCount; i++) {
      final bandRadius = radius * (0.7 + i * 0.1);
      final opacity = healthLevel >= 40 ? 0.15 : 0.25;
      final phase = progress * 2 * math.pi + i * 1.2;

      paint.strokeWidth = 4.0 + i * 2.0;
      paint.color = colors[i % colors.length].withOpacity(opacity);

      // Create wavy atmospheric bands
      final path = Path();
      bool first = true;

      for (double angle = 0; angle < 2 * math.pi; angle += 0.1) {
        final waveRadius = bandRadius +
            math.sin(angle * 6 + phase) * (radius * 0.02) +
            math.cos(angle * 4 + phase * 1.5) * (radius * 0.015);

        final x = center.dx + math.cos(angle) * waveRadius;
        final y = center.dy + math.sin(angle) * waveRadius;

        if (first) {
          path.moveTo(x, y);
          first = false;
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(AtmospherePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.healthLevel != healthLevel;
  }
}

// Demo widget remains the same
class PlanetDemo extends StatefulWidget {
  @override
  State<PlanetDemo> createState() => _PlanetDemoState();
}

class _PlanetDemoState extends State<PlanetDemo> {
  double _healthLevel = 75.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Nebula Planet Widget'),
        backgroundColor: Colors.grey[900],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NebulaPlanetWidget(
              size: 200,
              healthLevel: _healthLevel.round(),
            ),
            const SizedBox(height: 40),
            Text(
              'Health Level: ${_healthLevel.round()}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            Slider(
              value: _healthLevel,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: (value) {
                setState(() {
                  _healthLevel = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}