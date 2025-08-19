class Quest {
  final String id;
  final String planetId; // Planet association
  final String title;
  final String description;
  final int targetCount; // e.g., number of trades
  final int rewardXP;

  const Quest({
    required this.id,
    required this.planetId,
    required this.title,
    required this.description,
    required this.targetCount,
    required this.rewardXP,
  });
}

class QuestData {
  static List<Quest> forPlanet(String planetId) {
    switch (planetId) {
      case 'barren_rock':
        return const [
          Quest(
            id: 'q_start_1',
            planetId: 'barren_rock',
            title: 'First Steps',
            description: 'Place 3 mock trades to awaken the rock.',
            targetCount: 3,
            rewardXP: 50,
          ),
          Quest(
            id: 'q_start_2',
            planetId: 'barren_rock',
            title: 'Dust Settles',
            description: 'Win 1 mock trade to stabilize the surface.',
            targetCount: 1,
            rewardXP: 75,
          ),
        ];
      case 'ocean_oasis':
        return const [
          Quest(
            id: 'q_ocean_1',
            planetId: 'ocean_oasis',
            title: 'Make Waves',
            description: 'Complete 5 trades to light up the reefs.',
            targetCount: 5,
            rewardXP: 100,
          ),
        ];
      case 'forest_frontier':
        return const [
          Quest(
            id: 'q_forest_1',
            planetId: 'forest_frontier',
            title: 'Root Growth',
            description: 'Maintain a 3-day streak to grow canopies.',
            targetCount: 3,
            rewardXP: 120,
          ),
        ];
      case 'volcanic_forge':
        return const [
          Quest(
            id: 'q_volcano_1',
            planetId: 'volcanic_forge',
            title: 'Into the Fire',
            description: 'Recover from 1 loss with a win.',
            targetCount: 1,
            rewardXP: 150,
          ),
        ];
      case 'crystal_caverns':
        return const [
          Quest(
            id: 'q_crystal_1',
            planetId: 'crystal_caverns',
            title: 'Shine Brighter',
            description: 'Achieve 3 profitable trades in a row.',
            targetCount: 3,
            rewardXP: 180,
          ),
        ];
      case 'storm_citadel':
        return const [
          Quest(
            id: 'q_storm_1',
            planetId: 'storm_citadel',
            title: 'Ride the Lightning',
            description: 'Trade 7 times this week.',
            targetCount: 7,
            rewardXP: 220,
          ),
        ];
      case 'nebula_nexus':
        return const [
          Quest(
            id: 'q_nebula_1',
            planetId: 'nebula_nexus',
            title: 'Star Weaver',
            description: 'Perform 2 combo trades (back-to-back).',
            targetCount: 2,
            rewardXP: 260,
          ),
        ];
      case 'quantum_quasar':
        return const [
          Quest(
            id: 'q_quasar_1',
            planetId: 'quantum_quasar',
            title: 'Stabilize the Beam',
            description: 'Hit 10% total P&L in practice mode.',
            targetCount: 1,
            rewardXP: 300,
          ),
        ];
      case 'galactic_garden':
        return const [
          Quest(
            id: 'q_garden_1',
            planetId: 'galactic_garden',
            title: 'Bloom Keeper',
            description: 'Trade daily for 5 days.',
            targetCount: 5,
            rewardXP: 350,
          ),
        ];
      case 'cosmic_crown':
        return const [
          Quest(
            id: 'q_crown_1',
            planetId: 'cosmic_crown',
            title: 'Crown Bearer',
            description: 'Maintain top-10 leaderboard for a week.',
            targetCount: 7,
            rewardXP: 500,
          ),
        ];
      default:
        return const [];
    }
  }
}
