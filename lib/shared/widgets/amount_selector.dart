import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

class AmountSelector extends StatelessWidget {
  final double selectedAmount;
  final Function(double) onAmountChanged;

  const AmountSelector({
    super.key,
    required this.selectedAmount,
    required this.onAmountChanged,
  });

  final List<double> _predefinedAmounts = const [10, 25, 50, 100, 250, 500];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Predefined amount grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _predefinedAmounts.length,
          itemBuilder: (context, index) {
            final amount = _predefinedAmounts[index];
            final isSelected = selectedAmount == amount;

            return _AmountOption(
              amount: amount,
              isSelected: isSelected,
              onTap: () => onAmountChanged(amount),
            );
          },
        ),

        const SizedBox(height: 20),

        // Custom amount input (optional)
        _buildCustomAmountInput(),
      ],
    );
  }

  Widget _buildCustomAmountInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.spaceDeep,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cosmicBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.edit, color: AppTheme.gray400, size: 20),
          const SizedBox(width: 12),
          Text(
            'Custom amount: ',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
          ),
          Text(
            '\$${selectedAmount.toStringAsFixed(0)}',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.energyGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountOption extends StatelessWidget {
  final double amount;
  final bool isSelected;
  final VoidCallback onTap;

  const _AmountOption({
    required this.amount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child:
          AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.energyGreen.withOpacity(0.15)
                      : AppTheme.spaceDeep,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.energyGreen
                        : AppTheme.cosmicBlue.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.energyGreen.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '\$${amount.toStringAsFixed(0)}',
                        style: AppTheme.bodyLarge.copyWith(
                          color: isSelected
                              ? AppTheme.energyGreen
                              : AppTheme.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 20,
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppTheme.energyGreen,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ).animate().scaleX(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                        ),
                    ],
                  ),
                ),
              )
              .animate(target: isSelected ? 1 : 0)
              .scale(
                duration: const Duration(milliseconds: 150),
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
              ),
    );
  }
}
