import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

class DirectionSelector extends StatelessWidget {
  final String selectedDirection;
  final Function(String) onDirectionChanged;

  const DirectionSelector({
    super.key,
    required this.selectedDirection,
    required this.onDirectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DirectionOption(
            direction: 'LONG',
            label: 'Long',
            subtitle: 'Price goes up',
            icon: Icons.trending_up,
            color: AppTheme.energyGreen,
            isSelected: selectedDirection == 'LONG',
            onTap: () => onDirectionChanged('LONG'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _DirectionOption(
            direction: 'SHORT',
            label: 'Short',
            subtitle: 'Price goes down',
            icon: Icons.trending_down,
            color: AppTheme.dangerRed,
            isSelected: selectedDirection == 'SHORT',
            onTap: () => onDirectionChanged('SHORT'),
          ),
        ),
      ],
    );
  }
}

class _DirectionOption extends StatelessWidget {
  final String direction;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _DirectionOption({
    required this.direction,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppTheme.spaceDeep,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppTheme.cosmicBlue.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            // Icon
            Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.2)
                        : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 32),
                )
                .animate(target: isSelected ? 1 : 0)
                .scale(
                  duration: const Duration(milliseconds: 200),
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                ),

            const SizedBox(height: 12),

            // Label
            Text(
              label,
              style: AppTheme.heading3.copyWith(
                color: isSelected ? color : AppTheme.white,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            // Subtitle
            Text(
              subtitle,
              style: AppTheme.bodySmall.copyWith(
                color: isSelected ? color.withOpacity(0.8) : AppTheme.gray400,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 40 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
