import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

class OrderTypeSelector extends StatelessWidget {
  final String selectedOrderType;
  final Function(String) onOrderTypeChanged;

  const OrderTypeSelector({
    super.key,
    required this.selectedOrderType,
    required this.onOrderTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _OrderTypeOption(
            orderType: 'MARKET',
            label: 'Market',
            subtitle: 'Execute instantly',
            icon: Icons.flash_on,
            color: AppTheme.energyGreen,
            isSelected: selectedOrderType == 'MARKET',
            onTap: () => onOrderTypeChanged('MARKET'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _OrderTypeOption(
            orderType: 'LIMIT',
            label: 'Limit',
            subtitle: 'Set your price',
            icon: Icons.schedule,
            color: AppTheme.starYellow,
            isSelected: selectedOrderType == 'LIMIT',
            onTap: () => onOrderTypeChanged('LIMIT'),
          ),
        ),
      ],
    );
  }
}

class _OrderTypeOption extends StatelessWidget {
  final String orderType;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrderTypeOption({
    required this.orderType,
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppTheme.spaceDeep,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppTheme.cosmicBlue.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Icon
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            
            // Label and subtitle
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.bodyMedium.copyWith(
                    color: isSelected ? color : AppTheme.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTheme.bodySmall.copyWith(
                    color: isSelected ? color.withOpacity(0.8) : AppTheme.gray400,
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate(target: isSelected ? 1 : 0)
      .scale(
        duration: const Duration(milliseconds: 150),
        begin: const Offset(1, 1),
        end: const Offset(1.05, 1.05),
      );
  }
}
