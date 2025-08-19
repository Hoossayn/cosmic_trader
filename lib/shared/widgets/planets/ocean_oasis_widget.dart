import 'package:flutter/material.dart';
import 'dart:math' as math;

void _drawOrbitalEcosystem(Canvas canvas, Offset center, double radius, double health, double t) {
    // Asteroid belt with realistic chunks
    final asteroidPaint = Paint()..isAntiAlias = true;
    for (int i = 0; i < 25; i++) {
      final angle = (i * 0.251 + t * 2 * math.pi * 0.3);
      final dist = radius * (1.6 + (i % 4) * 0.08);
      final x = center.dx + math.cos(angle) * dist;
      final y = center.dy + math.sin(angle) * dist * 0.75;
      
      // Asteroid tumble animation
      final tumble = t * 4 * math.pi + i * 1.7;
      final size = radius * (0.02 + (i % 3) * 0.015);
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(tumble);
      
      // Draw irregular asteroid shape
      asteroidPaint.color = const Color(0xFF5D4037).withOpacity(0.8);
      final asteroidPath = Path();
      for (int j = 0; j < 6; j++) {
        final asteroidAngle = j * math.pi / 3;
        final variation = size * (0.7 + math.sin(j * 2.1 + i) * 0.4);
        final point = Offset(
          math.cos(asteroidAngle) * variation,
          math.sin(asteroidAngle) * variation,
        );
        if (j == 0) asteroidPath.moveTo(point.dx, point.dy);
        else asteroidPath.lineTo(point.dx, point.dy);
      }
      asteroidPath.close();
      canvas.drawPath(asteroidPath, asteroidPaint);
      
      // Asteroid glow based on health (healthy planets have energy asteroids)
      if (health > 0.7) {
        final glowPaint = Paint()
          ..color = const Color(0xFF76FF03).withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawPath(asteroidPath, glowPaint);
      }
      canvas.restore();
    }
    
    // Energy creatures/space whales for healthy planets
    if (health > 0.6) {
      final creaturePaint = Paint()..isAntiAlias = true;
      for (int i = 0; i < 3; i++) {
        final creatureAngle = t * 2 * math.pi * 0.2 + i * 2.1;
        final creatureDist = radius * (1.8 + i * 0.2);
        final creaturePos = Offset(
          center.dx + math.cos(creatureAngle) * creatureDist,
          center.dy + math.sin(creatureAngle) * creatureDist * 0.6,
        );
        
        // Space whale body with bioluminescence
        final whaleSize = radius * (0.08 + i * 0.02);
        final biolumColor = i % 2 == 0 ? const Color(0xFF00E5FF) : const Color(0xFF76FF03);
        
        // Body glow
        creaturePaint.color = biolumColor.withOpacity(0.4 * health);
        creaturePaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawOval(
          Rect.fromCenter(center: creaturePos, width: whaleSize * 2, height: whaleSize),
          creaturePaint,
        );
        
        // Body
        creaturePaint.color = const Color(0xFF37474F).withOpacity(0.9);
        creaturePaint.maskFilter = null;
        canvas.drawOval(
          Rect.fromCenter(center: creaturePos, width: whaleSize * 1.5, height: whaleSize * 0.7),
          creaturePaint,
        );
        
        // Bioluminescent spots
        creaturePaint.color = biolumColor.withOpacity(0.8);
        for (int spot = 0; spot < 4; spot++) {
          final spotAngle = spot * math.pi / 2 + t * 4 * math.pi;
          final spotPos = creaturePos + Offset(
            math.cos(spotAngle) * whaleSize * 0.3,
            math.sin(spotAngle) * whaleSize * 0.2,
          );
          canvas.drawCircle(spotPos, whaleSize * 0.1, creaturePaint);
        }
      }
    }
    
    // Energy streams connecting asteroids (only for very healthy planets)
    if (health > 0.8) {
      final streamPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF00E5FF).withOpacity(0.6),
            const Color(0xFF76FF03).withOpacity(0.4),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, radius * 4, radius * 4))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      // Draw energy streams between some asteroids
      for (int i = 0; i < 6; i++) {
        final streamPhase = (t + i * 0.3) % 1.0;
        if (streamPhase < 0.5) {
          final angle1 = i * 1.047 + t * 2 * math.pi * 0.3;
          final angle2 = (i + 3) * 1.047 + t * 2 * math.pi * 0.3;
          final pos1 = center + Offset(
            math.cos(angle1) * radius * 1.65,
            math.sin(angle1) * radius * 1.65 * 0.75,
          );
          final pos2 = center + Offset(
            math.cos(angle2) * radius * 1.65,
            math.sin(angle2) * radius * 1.65 * 0.75,
          );
          canvas.drawLine(pos1, pos2, streamPaint);
        }
      }
    }
  }

  void _drawSpectacularRings(Canvas canvas, Offset center, double radius, double health, double t) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.3 + t * 0.4);
    canvas.scale(1.0, 0.45);
    
    // Ring particles and structures (back)
    _drawRingDetails(canvas, Offset.zero, radius * 1.5, health, t, false);
    canvas.restore();
  }

  void _drawRingDetails(Canvas canvas, Offset center, double ringRadius, double health, double t, bool isFront) {
    // Major ring bands
    for (int band = 0; band < 4; band++) {
      final bandRadius = ringRadius - band * ringRadius * 0.12;
      final bandWidth = ringRadius * (0.08 - band * 0.015);
      
      // Health affects ring colors and intensity
      Color ring1, ring2;
      double intensity;
      
      if (health < 0.3) {
        ring1 = const Color(0xFF8D6E63); // Dusty brown
        ring2 = const Color(0xFF5D4037); // Dark brown
        intensity = 0.2;
      } else if (health < 0.6) {
        ring1 = const Color(0xFF66BB6A); // Sickly green
        ring2 = const Color(0xFF4CAF50); // Medium green
        intensity = 0.4;
      } else if (health < 0.8) {
        ring1 = const Color(0xFF00BCD4); // Standard cyan
        ring2 = const Color(0xFF4CAF50); // Standard green
        intensity = 0.6;
      } else {
        ring1 = const Color(0xFF00E5FF); // Brilliant cyan
        ring2 = const Color(0xFF76FF03); // Brilliant green
        intensity = 0.9;
      }
      
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = bandWidth
        ..shader = SweepGradient(
          colors: [
            Colors.transparent,
            ring1.withOpacity(intensity * (0.4 - band * 0.08)),
            ring2.withOpacity(intensity * (0.3 - band * 0.06)),
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: bandRadius));
      
      // Clip to front or back
      final clipPath = Path()..addOval(Rect.fromCircle(center: center, radius: bandRadius));
      final clipRect = Path()..addRect(
        isFront 
          ? Rect.fromLTWH(-bandRadius * 2, -bandRadius * 2, bandRadius * 4, bandRadius)
          : Rect.fromLTWH(-bandRadius * 2, 0, bandRadius * 4, bandRadius * 2)
      );
      final finalClip = Path.combine(PathOperation.intersect, clipPath, clipRect);
      
      canvas.saveLayer(null, Paint());
      canvas.clipPath(finalClip);
      canvas.drawCircle(center, bandRadius, ringPaint);
      canvas.restore();
    }
    
    // Ring particles and debris
    final particlePaint = Paint()..isAntiAlias = true;
    for (int i = 0; i < 150; i++) {
      final particleAngle = i * 0.041 + t * 2 * math.pi * (0.6 + (i % 7) * 0.1);
      final particleDist = ringRadius * (0.7 + (i % 20) * 0.04);
      final particlePos = Offset(
        center.dx + math.cos(particleAngle) * particleDist,
        center.dy + math.sin(particleAngle) * particleDist,
      );
      
      // Check if particle should be visible (front/back)
      final shouldShow = isFront ? particlePos.dy < center.dy : particlePos.dy >= center.dy;
      if (!shouldShow) continue;
      
      final particleSize = ringRadius * (0.008 + (i % 3) * 0.004);
      final sparkle = (math.sin(t * 2 * math.pi * 3 + i * 0.7) + 1) * 0.5;
      
      // Particle color based on health and position
      Color particleColor;
      if (health < 0.3) {
        particleColor = const Color(0xFF8D6E63);
      } else if (health < 0.6) {
        particleColor = i % 3 == 0 ? const Color(0xFF66BB6A) : const Color(0xFF8BC34A);
      } else if (health < 0.8) {
        particleColor = i % 2 == 0 ? const Color(0xFF00BCD4) : const Color(0xFF4CAF50);
      } else {
        particleColor = i % 3 == 0 ? const Color(0xFF00E5FF) : 
                      i % 3 == 1 ? const Color(0xFF76FF03) : const Color(0xFFFFEB3B);
      }
      
      particlePaint.color = particleColor.withOpacity(0.6 + 0.4 * sparkle * health);
      canvas.drawCircle(particlePos, particleSize, particlePaint);
      
      // Add sparkle effect for healthy rings
      if (health > 0.7 && sparkle > 0.8) {
        particlePaint.color = Colors.white.withOpacity(0.9);
        canvas.drawCircle(particlePos, particleSize * 0.5, particlePaint);
      }
    }
  }

  void _drawHealthBasedContinents(Canvas canvas, Offset center, double radius, double health, double t) {
    // Continental colors change dramatically with health
    List<Color> landColors;
    if (health < 0.3) {
      // Dead planet - grays and browns
      landColors = [
        const Color(0xFF424242), // Dark gray
        const Color(0xFF616161), // Medium gray
        const Color(0xFF3E2723), // Dark brown
        const Color(0xFF5D4037), // Medium brown
      ];
    } else if (health < 0.6) {
      // Struggling planet - dying vegetation
      landColors = [
        const Color(0xFF33691E), // Dark dying green
        const Color(0xFF689F38), // Medium green
        const Color(0xFF8D6E63), // Brown patches
        const Color(0xFFDCE775), // Sickly yellow
      ];
    } else if (health < 0.8) {
      // Healthy planet - normal vegetation
      landColors = [
        const Color(0xFF2E7D32), // Dark forest green
        const Color(0xFF558B2F), // Medium green
        const Color(0xFF8BC34A), // Light green
        const Color(0xFFDCE775), // Healthy yellow
      ];
    } else {
      // Paradise planet - lush and vibrant
      landColors = [
        const Color(0xFF1B5E20), // Rich dark green
        const Color(0xFF4CAF50), // Vibrant green
        const Color(0xFF8BC34A), // Bright green
        const Color(0xFFCDDC39), // Golden green
      ];
    }

    // Continental coverage changes with health
    final continentCount = health < 0.3 ? 2 : health < 0.6 ? 3 : health < 0.8 ? 4 : 6;
    final continentOpacity = health < 0.3 ? 0.4 : health < 0.6 ? 0.6 : health < 0.8 ? 0.7 : 0.9;

    final continents = [
      {'center': Offset(center.dx + radius * 0.15, center.dy - radius * 0.25), 'size': radius * 0.4},
      {'center': Offset(center.dx - radius * 0.3, center.dy - radius * 0.1), 'size': radius * 0.35},
      {'center': Offset(center.dx - radius * 0.45, center.dy + radius * 0.2), 'size': radius * 0.28},
      {'center': Offset(center.dx + radius * 0.35, center.dy + radius * 0.3), 'size': radius * 0.25},
      {'center': Offset(center.dx + radius * 0.1, center.dy + radius * 0.4), 'size': radius * 0.2},
      {'center': Offset(center.dx - radius * 0.1, center.dy - radius * 0.4), 'size': radius * 0.18},
    ];

    for (int c = 0; c < continentCount && c < continents.length; c++) {
      final continent = continents[c];
      final continentCenter = continent['center'] as Offset;
      final continentSize = continent['size'] as double;
      
      if ((continentCenter - center).distance < radius * 0.9) {
        final landPaint = Paint()
          ..color = landColors[c % landColors.length].withOpacity(continentOpacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        
        // Create organic continent shape
        final path = Path();
        final points = <Offset>[];
        for (int i = 0; i < 12; i++) {
          final angle = i * math.pi / 6;
          final variation = continentSize * (0.6 + math.sin(angle * 3 + t + c) * 0.4);
          final point = Offset(
            continentCenter.dx + math.cos(angle) * variation,
            continentCenter.dy + math.sin(angle) * variation,
          );
          points.add(point);
        }
        
        if (points.isNotEmpty) {
          path.moveTo(points[0].dx, points[0].dy);
          for (int i = 1; i < points.length; i++) {
            path.lineTo(points[i].dx, points[i].dy);
          }
          path.close();
          
          canvas.save();
          canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius * 0.98)));
          canvas.drawPath(path, landPaint);
          canvas.restore();
        }
      }
    }
  }

  void _drawHealthBasedClouds(Canvas canvas, Offset center, double radius, double health, double t) {
    // Cloud characteristics change drastically with health
    Color cloudColor;
    double cloudOpacity;
    double cloudCoverage;
    int cloudLayers;
    
    if (health < 0.3) {
      // Toxic/polluted clouds
      cloudColor = const Color(0xFF8D6E63); // Brown smog
      cloudOpacity = 0.7;
      cloudCoverage = 0.8; // Heavy pollution coverage
      cloudLayers = 1;
    } else if (health < 0.6) {
      // Sickly atmosphere
      cloudColor = const Color(0xFF9E9E9E); // Gray clouds
      cloudOpacity = 0.5;
      cloudCoverage = 0.6;
      cloudLayers = 2;
    } else if (health < 0.8) {
      // Normal weather patterns
      cloudColor = Colors.white;
      cloudOpacity = 0.4;
      cloudCoverage = 0.4;
      cloudLayers = 3;
    } else {
      // Paradise weather - light, wispy clouds
      cloudColor = const Color(0xFFF8BBD9); // Slight pink tint
      cloudOpacity = 0.3;
      cloudCoverage = 0.2;
      cloudLayers = 4;
    }
    
    final cloudPaint = Paint()..isAntiAlias = true;
    
    // Draw cloud layers
    for (int layer = 0; layer < cloudLayers; layer++) {
      final layerOpacity = cloudOpacity * (1.0 - layer * 0.15);
      final layerOffset = t * (0.4 + layer * 0.15);
      final layerClouds = (25 * cloudCoverage).round() - layer * 3;
      
      cloudPaint.color = cloudColor.withOpacity(layerOpacity);
      cloudPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0 + layer * 1.5);
      
      for (int i = 0; i < layerClouds; i++) {
        final cloudAngle = (i * 0.25 + layerOffset * 2 * math.pi);
        final cloudDist = radius * (0.25 + (i % 8) * 0.08);
        final cloudPos = Offset(
          center.dx + math.cos(cloudAngle) * cloudDist,
          center.dy + math.sin(cloudAngle) * cloudDist,
        );
        
        if ((cloudPos - center).distance < radius * 0.95) {
          final cloudSize = radius * (0.06 + (i % 4) * 0.025);
          
          // For polluted planets, make clouds more irregular and dense
          if (health < 0.3) {
            final pollutionPath = Path();
            for (int j = 0; j < 8; j++) {
              final angle = j * math.pi / 4;
              final irregularity = cloudSize * (0.8 + math.sin(j + t * 3 + i) * 0.4);
              final point = cloudPos + Offset(
                math.cos(angle) * irregularity,
                math.sin(angle) * irregularity,
              );
              if (j == 0) pollutionPath.moveTo(point.dx, point.dy);
              else pollutionPath.lineTo(point.dx, point.dy);
            }
            pollutionPath.close();
            
            canvas.save();
            canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius * 0.98)));
            canvas.drawPath(pollutionPath, cloudPaint);
            canvas.restore();
          } else {
            canvas.save();
            canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius * 0.98)));
            canvas.drawCircle(cloudPos, cloudSize, cloudPaint);
            canvas.restore();
          }
        }
      }
    }
  }
  


class OceanOasisWidget extends StatefulWidget {
  final double size;
  final int healthLevel;

  const OceanOasisWidget({
    Key? key, 
    this.size = 200,
    this.healthLevel = 85,
  }) : super(key: key);

  @override
  State<OceanOasisWidget> createState() => _OceanOasisWidgetState();
}

class _OceanOasisWidgetState extends State<OceanOasisWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
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
          final wobble = math.sin(_controller.value * 2 * math.pi) * 0.02;
          final bob = math.sin(_controller.value * 2 * math.pi) * 1.5;
          return Transform.translate(
            offset: Offset(0, bob),
            child: Transform.rotate(
              angle: wobble,
              child: CustomPaint(
                painter: _OceanOasisPainter(
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

class _OceanOasisPainter extends CustomPainter {
  final double progress;
  final int healthLevel;

  _OceanOasisPainter({required this.progress, required this.healthLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.42;
    final health = (healthLevel.clamp(0, 100)) / 100.0;
    final t = progress;

    // Deep space atmospheric glow - blue-green ocean planet aura
    final auraRadius = radius * (1.3 + 0.08 * math.sin(t * 2 * math.pi));
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00BCD4).withOpacity(0.25 * (0.7 + 0.8 * health)), // Cyan ocean glow
          const Color(0xFF4CAF50).withOpacity(0.15 * (0.7 + 0.8 * health)), // Green life glow
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: auraRadius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22)
      ..isAntiAlias = true;
    canvas.drawCircle(center, auraRadius, auraPaint);

    // Advanced orbital ecosystem - asteroids, space whales, and energy streams
    _drawOrbitalEcosystem(canvas, center, radius, health, t);

    // Spectacular ring system with detailed structures (back half)
    _drawSpectacularRings(canvas, center, radius, health, t);

    // Ground contact shadow for realism
    final shadowRect = Rect.fromCenter(
      center: center.translate(0, radius * 1.0),
      width: radius * 1.8,
      height: radius * 0.35,
    );
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawOval(shadowRect, shadowPaint);

    // Main planet sphere - health dramatically affects appearance
    Color oceanDeep, oceanMid, oceanShallow;
    
    if (health < 0.3) {
      // Dying planet - brown, murky, polluted
      oceanDeep = const Color(0xFF3E2723);   // Dark brown
      oceanMid = const Color(0xFF5D4037);    // Medium brown  
      oceanShallow = const Color(0xFF8D6E63); // Light brown
    } else if (health < 0.6) {
      // Struggling planet - murky greens and browns
      oceanDeep = const Color(0xFF1B5E20);   // Dark murky green
      oceanMid = const Color(0xFF388E3C);    // Medium green
      oceanShallow = const Color(0xFF66BB6A); // Light green
    } else if (health < 0.8) {
      // Healthy planet - standard ocean blues
      oceanDeep = const Color(0xFF0D47A1);   // Deep ocean blue
      oceanMid = const Color(0xFF1976D2);    // Medium ocean blue
      oceanShallow = const Color(0xFF42A5F5); // Shallow water blue
    } else {
      // Pristine paradise planet - crystal clear blues with life
      oceanDeep = const Color(0xFF01579B);   // Deep crystal blue
      oceanMid = const Color(0xFF0288D1);    // Brilliant blue
      oceanShallow = const Color(0xFF29B6F6); // Pristine light blue
    }
    final highlight = const Color(0xFF81C784).withOpacity(0.3); // Green life highlight

    final spherePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.4, -0.4), // Light from top-right
        radius: 1.2,
        colors: [oceanShallow, oceanMid, oceanDeep],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..isAntiAlias = true;
    canvas.drawCircle(center, radius, spherePaint);

    // Health-based atmospheric glow changes
    Color atmosphereColor;
    double atmosphereIntensity;
    
    if (health < 0.3) {
      atmosphereColor = const Color(0xFF8D6E63); // Dusty brown
      atmosphereIntensity = 0.2;
    } else if (health < 0.6) {
      atmosphereColor = const Color(0xFF66BB6A); // Sickly green
      atmosphereIntensity = 0.3;
    } else if (health < 0.8) {
      atmosphereColor = const Color(0xFFE0F7FA); // Standard cyan
      atmosphereIntensity = 0.4;
    } else {
      atmosphereColor = const Color(0xFFB2DFDB); // Paradise teal
      atmosphereIntensity = 0.6;
    }

    final atmosphereHighlight = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.35, -0.35),
        radius: 0.7,
        colors: [
          atmosphereColor.withOpacity(atmosphereIntensity),
          Colors.transparent
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..isAntiAlias = true;
    canvas.drawCircle(center, radius, atmosphereHighlight);

    // Continental landmasses - health affects vegetation and land
    _drawHealthBasedContinents(canvas, center, radius, health, t);

    // Dynamic cloud formations - health affects weather patterns
    _drawHealthBasedClouds(canvas, center, radius, health, t);

    // Front spectacular rings
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.3 + t * 0.4);
    canvas.scale(1.0, 0.45);
    
    // Ring particles and structures (front)
    _drawRingDetails(canvas, Offset.zero, radius * 1.5, health, t, true);
    canvas.restore();

    // Realistic surface water reflection patterns
    _drawOceanReflections(canvas, center, radius, t);

    // City lights on night side (for high health planets)
    if (healthLevel >= 70) {
      _drawCityLights(canvas, center, radius, health, t);
    }

    // Orbiting space stations/satellites
    final satPaint = Paint()..isAntiAlias = true;
    for (int i = 0; i < 4; i++) {
      final orbitalAngle = t * 2 * math.pi * (0.3 + i * 0.12) + i * 1.8;
      final orbitalDist = radius * (1.65 + i * 0.15);
      final satPos = Offset(
        center.dx + math.cos(orbitalAngle) * orbitalDist,
        center.dy + math.sin(orbitalAngle) * orbitalDist * 0.6,
      );
      final satSize = radius * (0.055 + i * 0.012);
      
      // Station glow
      final stationGlow = Paint()
        ..color = const Color(0xFF00E5FF).withOpacity(0.3 + 0.4 * health)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(satPos, satSize * 1.6, stationGlow);
      
      // Station body
      satPaint.color = const Color(0xFFEEEEEE).withOpacity(0.95);
      canvas.drawCircle(satPos, satSize, satPaint);
      
      // Station details
      satPaint.color = const Color(0xFF00BCD4).withOpacity(0.8);
      canvas.drawCircle(satPos, satSize * 0.4, satPaint);
    }

    // Atmospheric terminator (day/night line)
    final terminatorPaint = Paint()
      ..shader = LinearGradient(
        begin: const Alignment(-0.3, -0.8),
        end: const Alignment(0.8, 0.3),
        colors: [
          Colors.black.withOpacity(0.6),
          Colors.black.withOpacity(0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, terminatorPaint);

    // Occasional aurora effects (appears periodically)
    if ((t % 1.0) < 0.4) {
      _drawAuroraEffects(canvas, center, radius, t);
    }
  }

  void _drawContinentalMasses(Canvas canvas, Offset center, double radius, double health, double t) {
    final landColors = [
      const Color(0xFF2E7D32), // Dark forest green
      const Color(0xFF558B2F), // Lighter green  
      const Color(0xFF8BC34A), // Fresh green
      const Color(0xFFDCE775), // Light green/yellow
    ];

    // Major continent shapes - more realistic than random dots
    final continents = [
      // Main continent (like Africa)
      {
        'center': Offset(center.dx + radius * 0.15, center.dy - radius * 0.25),
        'size': radius * 0.4,
        'color': landColors[0],
      },
      // Secondary continent (like Europe/Asia)  
      {
        'center': Offset(center.dx - radius * 0.3, center.dy - radius * 0.1),
        'size': radius * 0.35,
        'color': landColors[1],
      },
      // Americas equivalent
      {
        'center': Offset(center.dx - radius * 0.45, center.dy + radius * 0.2),
        'size': radius * 0.28,
        'color': landColors[2],
      },
    ];

    for (final continent in continents) {
      final continentCenter = continent['center'] as Offset;
      final continentSize = continent['size'] as double;
      final continentColor = continent['color'] as Color;
      
      // Check if continent is visible on planet surface
      final distanceFromCenter = (continentCenter - center).distance;
      if (distanceFromCenter < radius * 0.9) {
        final landPaint = Paint()
          ..color = continentColor.withOpacity(0.7 + 0.2 * health)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        
        // Create organic continent shape
        final path = Path();
        for (int i = 0; i < 12; i++) {
          final angle = i * math.pi / 6;
          final variation = continentSize * (0.7 + math.sin(angle * 3 + t) * 0.3);
          final point = Offset(
            continentCenter.dx + math.cos(angle) * variation,
            continentCenter.dy + math.sin(angle) * variation,
          );
          if (i == 0) {
            path.moveTo(point.dx, point.dy);
          } else {
            path.lineTo(point.dx, point.dy);
          }
        }
        path.close();
        
        canvas.save();
        canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius * 0.98)));
        canvas.drawPath(path, landPaint);
        canvas.restore();
      }
    }
  }

  void _drawCloudLayers(Canvas canvas, Offset center, double radius, double health, double t) {
    final cloudPaint = Paint()..isAntiAlias = true;
    
    // Multiple cloud layers for depth
    for (int layer = 0; layer < 3; layer++) {
      final layerOpacity = 0.3 - layer * 0.08;
      final layerOffset = t * (0.5 + layer * 0.2);
      
      cloudPaint.color = Colors.white.withOpacity(layerOpacity * (0.8 + 0.4 * health));
      cloudPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0 + layer * 2);
      
      // Create swirling cloud patterns
      for (int i = 0; i < 25 - layer * 5; i++) {
        final cloudAngle = (i * 0.3 + layerOffset * 2 * math.pi);
        final cloudDist = radius * (0.3 + (i % 8) * 0.08);
        final cloudPos = Offset(
          center.dx + math.cos(cloudAngle) * cloudDist,
          center.dy + math.sin(cloudAngle) * cloudDist,
        );
        
        if ((cloudPos - center).distance < radius * 0.95) {
          final cloudSize = radius * (0.08 + (i % 3) * 0.03);
          canvas.save();
          canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius * 0.98)));
          canvas.drawCircle(cloudPos, cloudSize, cloudPaint);
          canvas.restore();
        }
      }
    }
  }

  void _drawOceanReflections(Canvas canvas, Offset center, double radius, double t) {
    final reflectionPaint = Paint()
      ..color = const Color(0xFF81C784).withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    // Create wave-like reflection patterns
    for (int i = 0; i < 40; i++) {
      final waveAngle = i * 0.157 + t * 2 * math.pi * 0.3;
      final waveDist = radius * (0.2 + (i % 6) * 0.1);
      final waveIntensity = math.sin(t * 4 * math.pi + i * 0.5) * 0.5 + 0.5;
      
      final wavePos = Offset(
        center.dx + math.cos(waveAngle) * waveDist,
        center.dy + math.sin(waveAngle) * waveDist,
      );
      
      if ((wavePos - center).distance < radius * 0.8) {
        reflectionPaint.color = const Color(0xFF81C784).withOpacity(0.15 * waveIntensity);
        canvas.save();
        canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius * 0.98)));
        canvas.drawCircle(wavePos, radius * 0.03, reflectionPaint);
        canvas.restore();
      }
    }
  }

  void _drawCityLights(Canvas canvas, Offset center, double radius, double health, double t) {
    final lightPaint = Paint()..isAntiAlias = true;
    final rand = math.Random(12345); // Fixed seed for consistent positions
    
    // City lights on the night side
    for (int i = 0; i < 30; i++) {
      final lightAngle = rand.nextDouble() * 2 * math.pi;
      final lightDist = radius * (0.3 + rand.nextDouble() * 0.5);
      final lightPos = Offset(
        center.dx + math.cos(lightAngle) * lightDist,
        center.dy + math.sin(lightAngle) * lightDist,
      );
      
      // Only show lights on night side (right side of planet)
      if (lightPos.dx > center.dx && (lightPos - center).distance < radius * 0.9) {
        final brightness = 0.6 + math.sin(t * 2 * math.pi * (2 + i % 3)) * 0.4;
        final lightColor = i % 3 == 0 
            ? const Color(0xFFFFEB3B) 
            : i % 3 == 1 
                ? const Color(0xFF00E5FF)
                : const Color(0xFF76FF03);
        
        lightPaint.color = lightColor.withOpacity(0.8 * brightness * health);
        lightPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        
        canvas.save();
        canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius * 0.98)));
        canvas.drawCircle(lightPos, 1.5, lightPaint);
        canvas.restore();
      }
    }
  }

  void _drawAuroraEffects(Canvas canvas, Offset center, double radius, double t) {
    final phase = ((t % 0.4) / 0.4);
    final auroraIntensity = math.sin(phase * math.pi);
    
    // Northern aurora
    final auroraPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF00E5FF).withOpacity(0.4 * auroraIntensity),
          const Color(0xFF76FF03).withOpacity(0.6 * auroraIntensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(
        center.dx - radius * 1.2,
        center.dy - radius * 1.3,
        radius * 2.4,
        radius * 0.8,
      ))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15)
      ..style = PaintingStyle.fill;
    
    final auroraPath = Path();
    for (int i = 0; i < 20; i++) {
      final x = center.dx - radius * 1.2 + (i / 19) * radius * 2.4;
      final y = center.dy - radius * 1.1 + math.sin(i * 0.5 + t * 4 * math.pi) * radius * 0.2;
      if (i == 0) {
        auroraPath.moveTo(x, y);
      } else {
        auroraPath.lineTo(x, y);
      }
    }
    
    canvas.drawPath(auroraPath, auroraPaint);
  }

  @override
  bool shouldRepaint(covariant _OceanOasisPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.healthLevel != healthLevel;
  }
}