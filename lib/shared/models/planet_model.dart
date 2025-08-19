import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Identifiers for the starter set of planets. Keep stable for data linkage.
class PlanetIds {
  static const String barrenRock = 'barren_rock';
  static const String oceanOasis = 'ocean_oasis';
  static const String forestFrontier = 'forest_frontier';
  static const String volcanicForge = 'volcanic_forge';
  static const String crystalCaverns = 'crystal_caverns';
  static const String stormCitadel = 'storm_citadel';
  static const String nebulaNexus = 'nebula_nexus';
  static const String quantumQuasar = 'quantum_quasar';
  static const String galacticGarden = 'galactic_garden';
  static const String cosmicCrown = 'cosmic_crown';
}

/// Theme configuration for a planet. This feeds into visual painters.
class PlanetThemeConfig {
  final Color baseColor;
  final List<Color> palette;
  final bool hasRings;
  final int moonCount;

  const PlanetThemeConfig({
    required this.baseColor,
    required this.palette,
    this.hasRings = false,
    this.moonCount = 0,
  });
}

class Planet {
  final String id;
  final String name;
  final int levelRequired;
  final String description;
  final PlanetThemeConfig theme;
  final List<String> associatedNFTIds; // NFT ids tied to this planet

  const Planet({
    required this.id,
    required this.name,
    required this.levelRequired,
    required this.description,
    required this.theme,
    required this.associatedNFTIds,
  });
}

class PlanetData {
  static List<Planet> getAllPlanets() {
    return [
      Planet(
        id: PlanetIds.barrenRock,
        name: 'Barren Rock',
        levelRequired: 1,
        description:
            'A humble rocky world with craters and dust—your trading journey begins here.',
        theme: PlanetThemeConfig(
          baseColor: AppTheme.gray600,
          palette: [AppTheme.gray600, Colors.brown.shade600, Colors.black87],
          hasRings: false,
          moonCount: 0,
        ),
        associatedNFTIds: const ['space_cat'],
      ),
      Planet(
        id: PlanetIds.oceanOasis,
        name: 'Ocean Oasis',
        levelRequired: 2,
        description:
            'Water-dominated world with glowing seas and shimmering coastlines.',
        theme: PlanetThemeConfig(
          baseColor: AppTheme.cosmicBlue,
          palette: [AppTheme.cosmicBlue, AppTheme.energyGreen, Colors.white70],
          hasRings: false,
          moonCount: 1,
        ),
        associatedNFTIds: const [
          // Placeholder for future ocean-themed NFTs
        ],
      ),
      Planet(
        id: PlanetIds.forestFrontier,
        name: 'Forest Frontier',
        levelRequired: 3,
        description:
            'Lush jungles and ancient trees—growth and momentum take root.',
        theme: PlanetThemeConfig(
          baseColor: AppTheme.energyGreen,
          palette: [
            AppTheme.energyGreen,
            AppTheme.starYellow,
            AppTheme.gray600,
          ],
          hasRings: false,
          moonCount: 1,
        ),
        associatedNFTIds: const ['crystal_tree'],
      ),
      Planet(
        id: PlanetIds.volcanicForge,
        name: 'Volcanic Forge',
        levelRequired: 4,
        description:
            'Lava flows and eruptions—forge strength through adversity.',
        theme: PlanetThemeConfig(
          baseColor: AppTheme.warningOrange,
          palette: [AppTheme.warningOrange, AppTheme.dangerRed, Colors.black87],
          hasRings: false,
          moonCount: 2,
        ),
        associatedNFTIds: const ['trading_station'],
      ),
      Planet(
        id: PlanetIds.crystalCaverns,
        name: 'Crystal Caverns',
        levelRequired: 5,
        description:
            'Gem-encrusted caves and prisms—unearth dazzling opportunities.',
        theme: PlanetThemeConfig(
          baseColor: AppTheme.cosmicBlue,
          palette: [AppTheme.cosmicBlue, Colors.purpleAccent, Colors.white70],
          hasRings: true,
          moonCount: 1,
        ),
        associatedNFTIds: const ['crystal_palace'],
      ),
      Planet(
        id: PlanetIds.stormCitadel,
        name: 'Storm Citadel',
        levelRequired: 6,
        description: 'Towering storm clouds and lightning—command the chaos.',
        theme: PlanetThemeConfig(
          baseColor: AppTheme.gray600,
          palette: [AppTheme.gray600, AppTheme.cosmicBlue, Colors.white70],
          hasRings: true,
          moonCount: 2,
        ),
        associatedNFTIds: const ['cosmic_rings'],
      ),
      Planet(
        id: PlanetIds.nebulaNexus,
        name: 'Nebula Nexus',
        levelRequired: 7,
        description:
            'Swirling pastel gases—where stars are born and legends rise.',
        theme: PlanetThemeConfig(
          baseColor: AppTheme.cosmicBlue,
          palette: [
            AppTheme.cosmicBlue,
            AppTheme.starYellow,
            AppTheme.energyGreen,
          ],
          hasRings: true,
          moonCount: 3,
        ),
        associatedNFTIds: const ['stardust_trail'],
      ),
      Planet(
        id: PlanetIds.quantumQuasar,
        name: 'Quantum Quasar',
        levelRequired: 8,
        description:
            'High-energy beams and anomalies—master the pulse of markets.',
        theme: PlanetThemeConfig(
          baseColor: Colors.white,
          palette: [Colors.white, AppTheme.cosmicBlue, Colors.lightBlueAccent],
          hasRings: false,
          moonCount: 1,
        ),
        associatedNFTIds: const ['golden_meteor'],
      ),
      Planet(
        id: PlanetIds.galacticGarden,
        name: 'Galactic Garden',
        levelRequired: 9,
        description:
            'Floating gardens and alien flora—harmony through consistency.',
        theme: PlanetThemeConfig(
          baseColor: AppTheme.energyGreen,
          palette: [
            AppTheme.energyGreen,
            AppTheme.starYellow,
            Colors.pinkAccent,
          ],
          hasRings: true,
          moonCount: 2,
        ),
        associatedNFTIds: const ['aurora_effect'],
      ),
      Planet(
        id: PlanetIds.cosmicCrown,
        name: 'Cosmic Crown',
        levelRequired: 10,
        description:
            'Golden spires and aurora crowns—the throne of top traders.',
        theme: PlanetThemeConfig(
          baseColor: AppTheme.starYellow,
          palette: [AppTheme.starYellow, AppTheme.cosmicBlue, Colors.white],
          hasRings: true,
          moonCount: 3,
        ),
        associatedNFTIds: const ['cosmic_dragon'],
      ),
    ];
  }

  static Planet? getById(String id) {
    try {
      return getAllPlanets().firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
