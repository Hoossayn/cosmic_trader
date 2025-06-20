import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LeverageSelector extends StatelessWidget {
  final double selectedLeverage;
  final Function(double) onLeverageChanged;

  const LeverageSelector({
    super.key,
    required this.selectedLeverage,
    required this.onLeverageChanged,
  });

  static const List<double> leverageOptions = [2, 5, 10, 20, 50, 100];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Leverage', style: AppTheme.heading3),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: leverageOptions.length,
          itemBuilder: (context, index) {
            final leverage = leverageOptions[index];
            final isSelected = selectedLeverage == leverage;

            return GestureDetector(
              onTap: () => onLeverageChanged(leverage),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.starYellow.withOpacity(0.1)
                      : AppTheme.spaceDeep,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.starYellow
                        : AppTheme.cosmicBlue.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${leverage.toStringAsFixed(0)}x',
                    style: AppTheme.bodyMedium.copyWith(
                      color: isSelected ? AppTheme.starYellow : AppTheme.white,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
