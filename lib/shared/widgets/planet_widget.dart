import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_theme.dart';
import 'package:open_simplex_2/open_simplex_2.dart';
import '../models/nft_model.dart';
import '../models/planet_model.dart';

class PlanetWidget extends StatefulWidget {
  final double size;
  final int healthLevel; // 0-100
  final bool showOrbitalElements;
  final List<NFT>? ownedNFTs;
  final PlanetThemeConfig? planetTheme; // Optional theme override

  const PlanetWidget({
    super.key,
    required this.size,
    required this.healthLevel,
    this.showOrbitalElements = true,
    this.ownedNFTs,
    this.planetTheme,
  });

  @override
  State<PlanetWidget> createState() => _PlanetWidgetState();
}

class _PlanetWidgetState extends State<PlanetWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _orbitController;
  late AnimationController _cloudsController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _orbitController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _cloudsController = AnimationController(
      duration: const Duration(seconds: 14),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _orbitController.dispose();
    _cloudsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planetDiameter = widget.size * 0.68;
    final ringTiltRadians = -0.35;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _StarFieldPainter(twinkle: _pulseController.value),
          ),

          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: widget.size + (_pulseController.value * 18),
                height: widget.size + (_pulseController.value * 18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.transparent,
                      _getHealthColor().withOpacity(
                        0.09 * _pulseController.value,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),

          if (widget.planetTheme?.hasRings ?? true)
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _RingPainter(
                ringColor: _ringColorForHealth(),
                planetDiameter: planetDiameter,
                thickness: 18,
                innerScale: 1.15,
                outerScale: 1.65,
                tiltRadians: ringTiltRadians,
                drawFrontSegment: false,
              ),
            ),

          SizedBox(
            width: planetDiameter,
            height: planetDiameter,
            child: ClipOval(
              child: CustomPaint(
                painter: _PlanetSpherePainter(
                  baseColor: widget.planetTheme?.baseColor ?? _getHealthColor(),
                  lightDirection: const Offset(-0.6, -0.5),
                  noiseSeed: 7777, // stable seed to keep terrain consistent
                  healthLevel: widget.healthLevel,
                  overridePalette: widget.planetTheme?.palette,
                ),
                child: AnimatedBuilder(
                  animation: _cloudsController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _CloudBandsPainter(
                        progress: _cloudsController.value,
                        color: widget.healthLevel >= 75
                            ? Colors.white
                            : widget.healthLevel >= 40
                            ? Colors.white.withOpacity(0.7)
                            : Colors.brown,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          if (widget.planetTheme?.hasRings ?? true)
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _RingPainter(
                ringColor: widget.healthLevel >= 60
                    ? _ringColorForHealth()
                    : AppTheme.warningOrange.withOpacity(0.45),
                planetDiameter: planetDiameter,
                thickness: widget.healthLevel >= 60 ? 18 : 10,
                innerScale: 1.15,
                outerScale: 1.65,
                tiltRadians: ringTiltRadians,
                drawFrontSegment: true,
              ),
            ),

          if (widget.showOrbitalElements)
            ..._buildMoons(widget.planetTheme?.moonCount ?? 2),
          if (widget.showOrbitalElements) ..._buildOrbitalElements(),
          if (widget.ownedNFTs != null) ..._buildNFTDecorations(),

          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.spaceDark.withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getHealthColor().withOpacity(0.5)),
              ),
              child: Text(
                '${widget.healthLevel}%',
                style: AppTheme.bodySmall.copyWith(
                  color: _getHealthColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOrbitalElements() {
    return [
      // Orbital rings
      for (int i = 0; i < 3; i++)
        AnimatedBuilder(
          animation: _orbitController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _orbitController.value * 2 * math.pi * (i + 1) * 0.3,
              child: Container(
                width: widget.size + (i * 40),
                height: widget.size + (i * 40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.cosmicBlue.withOpacity(0.2 - (i * 0.05)),
                    width: 1,
                  ),
                ),
              ),
            );
          },
        ),

      // Orbiting objects
      for (int i = 0; i < 6; i++)
        AnimatedBuilder(
          animation: _orbitController,
          builder: (context, child) {
            final angle =
                (_orbitController.value * 2 * math.pi) + (i * math.pi / 3);
            final radius = widget.size * 0.45 + (i % 2) * 20;
            final x = math.cos(angle) * radius;
            final y = math.sin(angle) * radius;

            return Transform.translate(
              offset: Offset(x, y),
              child: Container(
                width: 8 + (i % 3) * 2,
                height: 8 + (i % 3) * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i % 2 == 0
                      ? AppTheme.starYellow.withOpacity(0.8)
                      : AppTheme.energyGreen.withOpacity(0.6),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (i % 2 == 0
                                  ? AppTheme.starYellow
                                  : AppTheme.energyGreen)
                              .withOpacity(0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
    ];
  }

  List<Widget> _buildMoons(int count) {
    final moons = <Widget>[];
    for (int i = 0; i < count; i++) {
      moons.add(
        AnimatedBuilder(
          animation: _orbitController,
          builder: (context, child) {
            final baseAngle =
                (_orbitController.value * 2 * math.pi) + (i * math.pi * 0.7);
            final radius = widget.size * (0.45 + i * 0.1);
            final x = math.cos(baseAngle) * radius;
            final y = math.sin(baseAngle) * radius * 0.6;
            return Transform.translate(
              offset: Offset(x, y),
              child: Container(
                width: 10 + i * 3,
                height: 10 + i * 3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Colors.white70, Colors.white24],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
    return moons;
  }

  // Removed old surface widgets in favor of custom painters above.

  List<Widget> _buildNFTDecorations() {
    if (widget.ownedNFTs == null || widget.ownedNFTs!.isEmpty) {
      return [];
    }

    final decorations = <Widget>[];
    final ownedNFTs = widget.ownedNFTs!;

    // Add decoration NFTs
    final decorationNFTs = ownedNFTs
        .where((nft) => nft.category == NFTCategory.decoration && nft.isOwned)
        .toList();

    for (int i = 0; i < decorationNFTs.length && i < 3; i++) {
      final nft = decorationNFTs[i];
      final angle = (i * 2 * math.pi / 3) + (_orbitController.value * 0.5);
      final radius = widget.size * 0.4;
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;

      decorations.add(
        AnimatedBuilder(
          animation: _orbitController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(x, y),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.spaceDeep.withOpacity(0.8),
                  border: Border.all(
                    color: _getNFTGlowColor(nft.rarity),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getNFTGlowColor(nft.rarity).withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(nft.emoji, style: const TextStyle(fontSize: 16)),
                ),
              ),
            );
          },
        ),
      );
    }

    // Add companion NFTs
    final companionNFTs = ownedNFTs
        .where((nft) => nft.category == NFTCategory.companion && nft.isOwned)
        .toList();

    for (int i = 0; i < companionNFTs.length && i < 2; i++) {
      final nft = companionNFTs[i];
      final angle = (i * math.pi) + (_orbitController.value * 2 * math.pi);
      final radius = widget.size * 0.5 + 20;
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;

      decorations.add(
        AnimatedBuilder(
          animation: _orbitController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(x, y),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.spaceDeep.withOpacity(0.9),
                  border: Border.all(
                    color: _getNFTGlowColor(nft.rarity),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getNFTGlowColor(nft.rarity).withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(nft.emoji, style: const TextStyle(fontSize: 14)),
                ),
              ),
            );
          },
        ),
      );
    }

    // Add effect NFTs as background effects
    final effectNFTs = ownedNFTs
        .where((nft) => nft.category == NFTCategory.effect && nft.isOwned)
        .toList();

    for (final nft in effectNFTs) {
      if (nft.id == 'aurora_effect') {
        decorations.add(
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: widget.size + 40,
                height: widget.size + 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.energyGreen.withOpacity(
                        0.1 * _pulseController.value,
                      ),
                      AppTheme.cosmicBlue.withOpacity(
                        0.1 * _pulseController.value,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
        );
      } else if (nft.id == 'stardust_trail') {
        // Add sparkling stardust effect
        for (int i = 0; i < 8; i++) {
          final angle =
              (i * math.pi / 4) + (_orbitController.value * 2 * math.pi);
          final radius = widget.size * 0.6;
          final x = math.cos(angle) * radius;
          final y = math.sin(angle) * radius;

          decorations.add(
            AnimatedBuilder(
              animation: _orbitController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(x, y),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.starYellow.withOpacity(0.8),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.starYellow.withOpacity(0.6),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
      }
    }

    return decorations;
  }

  Color _getNFTGlowColor(NFTRarity rarity) {
    switch (rarity) {
      case NFTRarity.common:
        return AppTheme.gray400;
      case NFTRarity.rare:
        return AppTheme.energyGreen;
      case NFTRarity.epic:
        return AppTheme.cosmicBlue;
      case NFTRarity.legendary:
        return AppTheme.starYellow;
      case NFTRarity.mythic:
        return AppTheme.warningOrange;
    }
  }

  Color _getHealthColor() {
    if (widget.healthLevel >= 80) {
      return AppTheme.energyGreen;
    } else if (widget.healthLevel >= 60) {
      return AppTheme.starYellow;
    } else if (widget.healthLevel >= 40) {
      return AppTheme.warningOrange;
    } else {
      return AppTheme.dangerRed;
    }
  }

  Color _ringColorForHealth() {
    final base = _getHealthColor();
    return base.withOpacity(0.7);
  }
}

class _StarFieldPainter extends CustomPainter {
  final double twinkle;
  _StarFieldPainter({required this.twinkle});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(42);
    final paint = Paint()..color = Colors.white.withOpacity(0.6);
    for (int i = 0; i < 120; i++) {
      final dx = rand.nextDouble() * size.width;
      final dy = rand.nextDouble() * size.height;
      final r = (rand.nextDouble() * 1.2 + 0.3) * (0.7 + twinkle * 0.6);
      canvas.drawCircle(
        Offset(dx, dy),
        r,
        paint..color = Colors.white.withOpacity(0.25 + rand.nextDouble() * 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter oldDelegate) =>
      oldDelegate.twinkle != twinkle;
}

class _PlanetSpherePainter extends CustomPainter {
  final Color baseColor;
  final Offset lightDirection;
  final int noiseSeed;
  final int healthLevel;
  final List<Color>? overridePalette;

  _PlanetSpherePainter({
    required this.baseColor,
    required this.lightDirection,
    required this.noiseSeed,
    required this.healthLevel,
    this.overridePalette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final landNoise = OpenSimplex2F(noiseSeed);
    final oceanNoise = OpenSimplex2F(noiseSeed + 1337);
    final stormNoise = OpenSimplex2F(noiseSeed + 4242);

    final healthyBlend = [
      baseColor,
      AppTheme.cosmicBlue.withOpacity(0.45),
      AppTheme.energyGreen.withOpacity(0.6),
    ];
    final midBlend = [
      baseColor.withOpacity(0.8),
      AppTheme.warningOrange.withOpacity(0.4),
      AppTheme.starYellow.withOpacity(0.5),
    ];
    final unhealthyBlend = [
      AppTheme.dangerRed.withOpacity(0.8),
      Colors.brown.withOpacity(0.6),
      Colors.black.withOpacity(0.8),
    ];

    List<Color> palette =
        overridePalette ??
        (() {
          if (healthLevel >= 80) return healthyBlend;
          if (healthLevel >= 50) return midBlend;
          return unhealthyBlend;
        })();

    final sphereGradient = RadialGradient(
      center: Alignment(lightDirection.dx, lightDirection.dy),
      radius: 1.12,
      colors: [
        palette[0].withOpacity(0.95),
        palette[1],
        palette[2],
        Colors.black.withOpacity(0.92),
      ],
      stops: const [0.0, 0.42, 0.72, 1.0],
    );

    final paint = Paint()
      ..shader = sphereGradient.createShader(Offset.zero & size)
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius, paint);

    final rand = math.Random(noiseSeed);
    // removed unused paint (kept previously for future use)
    final detailPaint = Paint()..isAntiAlias = true;

    double fbm(
      OpenSimplex2F n,
      double x,
      double y, {
      int octaves = 5,
      double lac = 2.0,
      double gain = 0.5,
      double freq = 1,
    }) {
      double amp = 0.5;
      double sum = 0;
      double fx = x * freq;
      double fy = y * freq;
      for (int i = 0; i < octaves; i++) {
        sum += amp * ((n.noise2(fx, fy) + 1) * 0.5);
        fx *= lac;
        fy *= lac;
        amp *= gain;
      }
      return sum.clamp(0.0, 1.0);
    }

    // Fractal terrain with separate land/ocean, coasts, storms, and city lights
    final samples = 1800;
    final L2 = Offset(-lightDirection.dx, -lightDirection.dy);
    final Llen = math.max(0.0001, math.sqrt(L2.dx * L2.dx + L2.dy * L2.dy));
    final L = Offset(L2.dx / Llen, L2.dy / Llen);

    for (int i = 0; i < samples; i++) {
      final angle = rand.nextDouble() * 2 * math.pi;
      final dist = rand.nextDouble() * radius;
      final pos = center + Offset(math.cos(angle), math.sin(angle)) * dist;

      final dx = (pos.dx - center.dx) / radius;
      final dy = (pos.dy - center.dy) / radius;
      final inside = dx * dx + dy * dy <= 1.0;
      if (!inside) continue;

      final dot = (dx * L.dx + dy * L.dy);
      final isNight = dot < -0.05;

      final sx = dx * 3.0;
      final sy = dy * 3.0;
      final landVal = fbm(
        landNoise,
        sx,
        sy,
        octaves: 5,
        lac: 2.0,
        gain: 0.5,
        freq: 1.15,
      );
      final oceanVal = fbm(
        oceanNoise,
        sx + 10.0,
        sy - 7.0,
        octaves: 4,
        lac: 2.1,
        gain: 0.55,
        freq: 0.95,
      );
      final terrain = landVal - 0.6 * oceanVal;

      final threshold = healthLevel >= 85
          ? 0.46
          : healthLevel >= 70
          ? 0.5
          : healthLevel >= 50
          ? 0.53
          : 0.58;
      final band = 0.085;
      final d = (terrain - threshold);
      final coast = (1.0 - (d.abs() / band)).clamp(0.0, 1.0);
      final isLand = terrain > threshold;

      Color landColor;
      Color oceanColor;
      if (healthLevel >= 80) {
        landColor = Color.lerp(
          palette[0],
          palette[1],
          landVal,
        )!.withOpacity(0.28);
        oceanColor = Color.lerp(
          AppTheme.cosmicBlue.withOpacity(0.7),
          AppTheme.energyGreen.withOpacity(0.25),
          oceanVal,
        )!.withOpacity(0.18);
      } else if (healthLevel >= 50) {
        landColor = Color.lerp(
          palette[0],
          palette[1],
          landVal,
        )!.withOpacity(0.32);
        oceanColor = Color.lerp(
          AppTheme.cosmicBlue.withOpacity(0.5),
          AppTheme.warningOrange.withOpacity(0.25),
          oceanVal,
        )!.withOpacity(0.16);
      } else {
        landColor = Color.lerp(
          palette[0],
          palette[1],
          landVal,
        )!.withOpacity(0.35);
        oceanColor = Color.lerp(
          Colors.brown.withOpacity(0.6),
          AppTheme.dangerRed.withOpacity(0.4),
          oceanVal,
        )!.withOpacity(0.18);
      }

      Color base = isLand ? landColor : oceanColor;
      if (coast > 0) {
        base = Color.lerp(
          base,
          Colors.white.withOpacity(isLand ? 0.35 : 0.2),
          coast * (isLand ? 0.6 : 0.4),
        )!;
      }

      final rr = isLand ? (1.6 + landVal * 2.0) : (1.2 + (1 - oceanVal) * 1.4);
      detailPaint.shader = RadialGradient(
        colors: [base, Colors.transparent],
      ).createShader(Rect.fromCircle(center: pos, radius: rr));
      canvas.drawCircle(pos, rr, detailPaint);

      // City lights on night side for very healthy planets
      if (healthLevel >= 85 && isNight && isLand && rand.nextDouble() < 0.045) {
        final lightPaint = Paint()
          ..shader =
              RadialGradient(
                colors: [
                  AppTheme.starYellow.withOpacity(0.9),
                  Colors.transparent,
                ],
              ).createShader(
                Rect.fromCircle(
                  center: pos,
                  radius: 1.8 + rand.nextDouble() * 1.4,
                ),
              );
        canvas.drawCircle(pos, 1.8 + rand.nextDouble() * 1.4, lightPaint);
      }

      // Storm hotspots
      if (healthLevel >= 60 && !isNight) {
        final sv = fbm(
          stormNoise,
          sx * 1.8,
          sy * 1.8,
          octaves: 3,
          lac: 2.2,
          gain: 0.55,
          freq: 1.3,
        );
        if (sv > 0.78 && rand.nextDouble() < 0.08) {
          final stormR = 2.5 + (sv - 0.78) * 8.0;
          final stormPaint = Paint()
            ..shader = RadialGradient(
              colors: [
                Colors.white.withOpacity(0.22),
                Colors.white.withOpacity(0.0),
              ],
            ).createShader(Rect.fromCircle(center: pos, radius: stormR));
          canvas.drawCircle(pos, stormR, stormPaint);
        }
      }
    }

    if (healthLevel < 45) {
      final crackPaint = Paint()
        ..color = Colors.black.withOpacity(0.35)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      for (int i = 0; i < 12; i++) {
        final startAngle = rand.nextDouble() * 2 * math.pi;
        final length = radius * (0.2 + rand.nextDouble() * 0.45);
        final start =
            center +
            Offset(math.cos(startAngle), math.sin(startAngle)) * (radius * 0.6);
        final end =
            start +
            Offset(math.cos(startAngle + 0.2), math.sin(startAngle + 0.2)) *
                length;
        final path = Path()
          ..moveTo(start.dx, start.dy)
          ..quadraticBezierTo(
            (start.dx + end.dx) / 2 + rand.nextDouble() * 10 - 5,
            (start.dy + end.dy) / 2 + rand.nextDouble() * 10 - 5,
            end.dx,
            end.dy,
          );
        canvas.drawPath(path, crackPaint);
      }
    }

    final specCenter =
        center +
        Offset(
          radius * lightDirection.dx * 0.6,
          radius * lightDirection.dy * 0.6,
        );
    final specPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [Colors.white.withOpacity(0.35), Colors.transparent],
          ).createShader(
            Rect.fromCircle(center: specCenter, radius: radius * 0.22),
          );
    canvas.drawCircle(specCenter, radius * 0.22, specPaint);
  }

  @override
  bool shouldRepaint(covariant _PlanetSpherePainter oldDelegate) {
    return oldDelegate.baseColor != baseColor ||
        oldDelegate.lightDirection != lightDirection ||
        oldDelegate.noiseSeed != noiseSeed ||
        oldDelegate.healthLevel != healthLevel;
  }
}

class _CloudBandsPainter extends CustomPainter {
  final double progress;
  final Color color;
  _CloudBandsPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final bands = [
      color.withOpacity(0.10),
      color.withOpacity(0.06),
      color.withOpacity(0.08),
    ];

    for (int i = 0; i < bands.length; i++) {
      final yOffset = (i - 1) * 10.0 + math.sin(progress * 2 * math.pi + i) * 4;
      paint.color = bands[i];
      final rect = Rect.fromCircle(
        center: center.translate(0, yOffset),
        radius: radius,
      );
      canvas.drawArc(rect, progress * 2 * math.pi, math.pi * 1.4, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CloudBandsPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _RingPainter extends CustomPainter {
  final Color ringColor;
  final double planetDiameter;
  final double thickness;
  final double innerScale;
  final double outerScale;
  final double tiltRadians;
  final bool drawFrontSegment;

  _RingPainter({
    required this.ringColor,
    required this.planetDiameter,
    required this.thickness,
    required this.innerScale,
    required this.outerScale,
    required this.tiltRadians,
    required this.drawFrontSegment,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final innerR = (planetDiameter / 2) * innerScale;
    final outerR = (planetDiameter / 2) * outerScale;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tiltRadians);
    canvas.scale(1, 0.55);

    final ringPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          ringColor.withOpacity(0.0),
          ringColor.withOpacity(0.7),
          ringColor.withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: outerR))
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    if (drawFrontSegment) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: (innerR + outerR) / 2),
        math.pi * 0.03,
        math.pi - 0.06,
        false,
        ringPaint,
      );
    } else {
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: (innerR + outerR) / 2),
        -math.pi + 0.03,
        math.pi - 0.06,
        false,
        ringPaint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.ringColor != ringColor ||
        oldDelegate.planetDiameter != planetDiameter ||
        oldDelegate.drawFrontSegment != drawFrontSegment ||
        oldDelegate.tiltRadians != tiltRadians;
  }
}
