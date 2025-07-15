// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../core/theme/app_theme.dart';
// import '../providers/api_providers.dart';
//
// class PositionsSummaryCard extends ConsumerWidget {
//   final bool showDetailed;
//
//   const PositionsSummaryCard({super.key, this.showDetailed = false});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final positionsAsync = ref.watch(realTimePositionsProvider);
//     final totalPnl = ref.watch(realTimeUnrealizedPnlProvider);
//     final totalMargin = ref.watch(realTimeMarginUsedProvider);
//
//     return positionsAsync.when(
//       data: (positions) => _buildSummaryCard(
//         context,
//         positions.length,
//         totalPnl,
//         totalMargin,
//         positions,
//       ),
//       loading: () => _buildLoadingSummaryCard(),
//       error: (_, __) => _buildErrorSummaryCard(),
//     );
//   }
//
//   Widget _buildSummaryCard(
//     BuildContext context,
//     int positionCount,
//     double totalPnl,
//     double totalMargin,
//     List positions,
//   ) {
//     final isProfitable = totalPnl >= 0;
//     final roiPercentage = totalMargin > 0
//         ? (totalPnl / totalMargin) * 100
//         : 0.0;
//
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppTheme.spaceDeep,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isProfitable
//               ? AppTheme.energyGreen.withOpacity(0.3)
//               : AppTheme.dangerRed.withOpacity(0.3),
//         ),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Total P&L',
//                     style: AppTheme.bodySmall.copyWith(color: AppTheme.gray400),
//                   ),
//                   Text(
//                     '${isProfitable ? '+' : ''}\$${totalPnl.toStringAsFixed(2)}',
//                     style: AppTheme.heading3.copyWith(
//                       color: isProfitable
//                           ? AppTheme.energyGreen
//                           : AppTheme.dangerRed,
//                     ),
//                   ),
//                 ],
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     'ROI',
//                     style: AppTheme.bodySmall.copyWith(color: AppTheme.gray400),
//                   ),
//                   Text(
//                     '${isProfitable ? '+' : ''}${roiPercentage.toStringAsFixed(2)}%',
//                     style: AppTheme.bodyLarge.copyWith(
//                       color: isProfitable
//                           ? AppTheme.energyGreen
//                           : AppTheme.dangerRed,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//
//           if (showDetailed) ...[
//             const SizedBox(height: 16),
//             const Divider(color: AppTheme.gray600, thickness: 0.5),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildMetric('Positions', positionCount.toString()),
//                 _buildMetric(
//                   'Margin Used',
//                   '\$${totalMargin.toStringAsFixed(2)}',
//                 ),
//                 _buildMetric(
//                   'Avg P&L',
//                   positionCount > 0
//                       ? '\$${(totalPnl / positionCount).toStringAsFixed(2)}'
//                       : '\$0.00',
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMetric(String label, String value) {
//     return Column(
//       children: [
//         Text(
//           label,
//           style: AppTheme.bodySmall.copyWith(color: AppTheme.gray400),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLoadingSummaryCard() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppTheme.spaceDeep,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppTheme.gray600),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Total P&L',
//                 style: AppTheme.bodySmall.copyWith(color: AppTheme.gray400),
//               ),
//               const SizedBox(height: 4),
//               Container(
//                 width: 80,
//                 height: 16,
//                 decoration: BoxDecoration(
//                   color: AppTheme.gray600,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(
//             width: 16,
//             height: 16,
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//               color: AppTheme.cosmicBlue,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildErrorSummaryCard() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppTheme.spaceDeep,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppTheme.dangerRed.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.error_outline, color: AppTheme.dangerRed, size: 20),
//           const SizedBox(width: 8),
//           Text(
//             'Failed to load P&L data',
//             style: AppTheme.bodyMedium.copyWith(color: AppTheme.dangerRed),
//           ),
//         ],
//       ),
//     );
//   }
// }
