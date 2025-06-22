import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PracticeTutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const PracticeTutorialOverlay({super.key, required this.onComplete});

  @override
  State<PracticeTutorialOverlay> createState() =>
      _PracticeTutorialOverlayState();
}

class _PracticeTutorialOverlayState extends State<PracticeTutorialOverlay> {
  int currentStep = 0;

  final List<TutorialStep> steps = [
    TutorialStep(
      title: 'Welcome to Practice Mode! 🚀',
      description:
          'Trade with virtual \$10,000 in a risk-free environment. Perfect your strategies before trading with real money.',
      icon: Icons.school,
    ),
    TutorialStep(
      title: 'Real Market Data 📈',
      description:
          'Practice mode uses real market prices and conditions, giving you authentic trading experience without the risk.',
      icon: Icons.trending_up,
    ),
    TutorialStep(
      title: 'Track Your Performance 📊',
      description:
          'Monitor your win rate, P&L, and trading statistics to improve your skills and identify patterns.',
      icon: Icons.analytics,
    ),
    TutorialStep(
      title: 'Risk Management 🛡️',
      description:
          'Use stop losses and take profits to practice proper risk management. Learn to protect your capital.',
      icon: Icons.security,
    ),
    TutorialStep(
      title: 'Position Management ⚡',
      description:
          'Close positions partially (10%, 25%, 50%, 75%) to practice advanced trading techniques.',
      icon: Icons.tune,
    ),
    TutorialStep(
      title: 'Ready to Trade! 💪',
      description:
          'Start with small positions and gradually increase as you build confidence. Good luck, trader!',
      icon: Icons.rocket_launch,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Progress indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  steps.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index <= currentStep
                          ? AppTheme.energyGreen
                          : Colors.grey.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Tutorial card
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.spaceDeep,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.energyGreen.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.energyGreen.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        steps[currentStep].icon,
                        size: 48,
                        color: AppTheme.energyGreen,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      steps[currentStep].title,
                      style: TextStyle(
                        color: AppTheme.starYellow,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      steps[currentStep].description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Navigation buttons
                    Column(
                      children: [
                        // Step counter
                        Text(
                          '${currentStep + 1} of ${steps.length}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Buttons row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Previous button
                            if (currentStep > 0)
                              Flexible(
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      currentStep--;
                                    });
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.arrow_back, size: 16),
                                      const SizedBox(width: 4),
                                      const Text('Previous'),
                                    ],
                                  ),
                                ),
                              )
                            else
                              const SizedBox(width: 80),

                            // Next/Finish button
                            Flexible(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (currentStep < steps.length - 1) {
                                    setState(() {
                                      currentStep++;
                                    });
                                  } else {
                                    widget.onComplete();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.energyGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        currentStep < steps.length - 1
                                            ? 'Next'
                                            : 'Start Trading',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      currentStep < steps.length - 1
                                          ? Icons.arrow_forward
                                          : Icons.rocket_launch,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Skip button
              TextButton(
                onPressed: widget.onComplete,
                child: Text(
                  'Skip Tutorial',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;

  const TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}
