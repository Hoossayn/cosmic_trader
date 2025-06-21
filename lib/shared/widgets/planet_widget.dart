import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../core/theme/app_theme.dart';
import '../models/nft_model.dart';

class PlanetWidget extends StatefulWidget {
  final double size;
  final int healthLevel; // 0-100
  final bool showOrbitalElements;
  final List<NFT>? ownedNFTs;

  const PlanetWidget({
    super.key,
    required this.size,
    required this.healthLevel,
    this.showOrbitalElements = true,
    this.ownedNFTs,
  });

  @override
  State<PlanetWidget> createState() => _PlanetWidgetState();
}

class _PlanetWidgetState extends State<PlanetWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _orbitController;

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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow effect
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: widget.size + (_pulseController.value * 20),
                height: widget.size + (_pulseController.value * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.transparent,
                      _getHealthColor().withOpacity(
                        0.1 * _pulseController.value,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),

          // Orbital elements
          if (widget.showOrbitalElements) ..._buildOrbitalElements(),

          // NFT decorations
          if (widget.ownedNFTs != null) ..._buildNFTDecorations(),

          // Main planet
          Container(
            width: widget.size * 0.7,
            height: widget.size * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.3),
                radius: 1.2,
                colors: [
                  _getHealthColor().withOpacity(0.9),
                  _getHealthColor(),
                  _getHealthColor().withOpacity(0.8),
                  AppTheme.spaceDark,
                ],
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: _getHealthColor().withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: AppTheme.spaceDark.withOpacity(0.8),
                  blurRadius: 10,
                  offset: const Offset(5, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Planet surface details
                ..._buildPlanetFeatures(),

                // Health indicator overlay
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.spaceDark.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getHealthColor().withOpacity(0.5),
                      ),
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

  List<Widget> _buildPlanetFeatures() {
    final features = <Widget>[];

    // Add continents/landmasses based on health
    if (widget.healthLevel > 20) {
      features.add(
        Positioned(
          top: widget.size * 0.15,
          left: widget.size * 0.2,
          child: Container(
            width: widget.size * 0.25,
            height: widget.size * 0.2,
            decoration: BoxDecoration(
              color: AppTheme.energyGreen.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      );
    }

    if (widget.healthLevel > 40) {
      features.add(
        Positioned(
          bottom: widget.size * 0.2,
          right: widget.size * 0.15,
          child: Container(
            width: widget.size * 0.3,
            height: widget.size * 0.25,
            decoration: BoxDecoration(
              color: AppTheme.energyGreen.withOpacity(0.4),
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      );
    }

    if (widget.healthLevel > 60) {
      features.add(
        Positioned(
          top: widget.size * 0.4,
          right: widget.size * 0.25,
          child: Container(
            width: widget.size * 0.15,
            height: widget.size * 0.15,
            decoration: BoxDecoration(
              color: AppTheme.starYellow.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    // Add atmosphere effect
    if (widget.healthLevel > 80) {
      features.add(
        Container(
          width: widget.size * 0.7,
          height: widget.size * 0.7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.transparent,
                AppTheme.energyGreen.withOpacity(0.1),
                AppTheme.energyGreen.withOpacity(0.05),
              ],
            ),
          ),
        ),
      );
    }

    return features;
  }

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
}
