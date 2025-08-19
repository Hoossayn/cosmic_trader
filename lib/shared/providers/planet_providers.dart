import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/planet_model.dart';
import '../models/nft_model.dart';
import '../models/quest_model.dart';

// Placeholder user level provider. Replace with real user profile state.
final userLevelProvider = StateProvider<int>((ref) => 2);

// All planets
final allPlanetsProvider = Provider<List<Planet>>((ref) {
  return PlanetData.getAllPlanets();
});

// Active planet based on current user level
final activePlanetProvider = Provider<Planet>((ref) {
  final level = ref.watch(userLevelProvider);
  final planets = PlanetData.getAllPlanets();
  final unlocked = planets.where((p) => p.levelRequired <= level).toList()
    ..sort((a, b) => a.levelRequired.compareTo(b.levelRequired));
  return unlocked.isNotEmpty ? unlocked.last : planets.first;
});

// NFTs filtered for the active planet
final planetNFTsProvider = Provider<List<NFT>>((ref) {
  final planet = ref.watch(activePlanetProvider);
  final all = NFTData.getAllNFTs();
  return all.where((n) => n.planetId == planet.id).toList();
});

// XP and progression
final userXPProvider = StateProvider<int>((ref) => 0);

// Next planet unlock info
final nextUnlockProvider = Provider<Planet?>((ref) {
  final level = ref.watch(userLevelProvider);
  final planets = PlanetData.getAllPlanets()
    ..sort((a, b) => a.levelRequired.compareTo(b.levelRequired));
  for (final p in planets) {
    if (p.levelRequired > level) return p;
  }
  return null;
});

// Quests for the active planet
final activePlanetQuestsProvider = Provider<List<Quest>>((ref) {
  final planet = ref.watch(activePlanetProvider);
  return QuestData.forPlanet(planet.id);
});

// Planet preview selection (allows viewing locked planets)
final selectedPlanetPreviewIdProvider = StateProvider<String?>((ref) => null);

// Which planet is currently displayed (preview > active)
final displayPlanetProvider = Provider<Planet>((ref) {
  final previewId = ref.watch(selectedPlanetPreviewIdProvider);
  if (previewId != null) {
    final p = PlanetData.getById(previewId);
    if (p != null) return p;
  }
  return ref.watch(activePlanetProvider);
});

// NFTs filtered for the display planet (preview-aware)
final displayPlanetNFTsProvider = Provider<List<NFT>>((ref) {
  final planet = ref.watch(displayPlanetProvider);
  final all = NFTData.getAllNFTs();
  return all.where((n) => n.planetId == planet.id).toList();
});

// Helper: unlocked planet ids set for current level
final unlockedPlanetIdsProvider = Provider<Set<String>>((ref) {
  final level = ref.watch(userLevelProvider);
  final planets = PlanetData.getAllPlanets();
  return planets
      .where((p) => p.levelRequired <= level)
      .map((p) => p.id)
      .toSet();
});
