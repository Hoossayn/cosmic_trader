import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

class XPProgressBar extends StatefulWidget {
  final int currentXP;
  final int totalXP;
  final double width;
  final double height;

  const XPProgressBar({
    super.key,
    required this.currentXP,
    required this.totalXP,
    this.width = 200,
    this.height = 8,
  });

  @override
  State<XPProgressBar> createState() => _XPProgressBarState();
}

class _XPProgressBarState extends State<XPProgressBar>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation =
        Tween<double>(
          begin: 0.0,
          end: widget.currentXP / widget.totalXP,
        ).animate(
          CurvedAnimation(
            parent: _progressController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Start animation after a small delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _progressController.forward();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // XP Progress label
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'XP Progress',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.gray400,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${widget.currentXP} / ${widget.totalXP}',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.energyGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Progress bar
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppTheme.spaceDeep,
            borderRadius: BorderRadius.circular(widget.height / 2),
            border: Border.all(
              color: AppTheme.cosmicBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // Background
                  Container(
                    width: widget.width,
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: AppTheme.spaceDeep,
                      borderRadius: BorderRadius.circular(widget.height / 2),
                    ),
                  ),

                  // Progress fill
                  Container(
                    width: widget.width * _progressAnimation.value,
                    height: widget.height,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.energyGreen, AppTheme.starYellow],
                      ),
                      borderRadius: BorderRadius.circular(widget.height / 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.energyGreen.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                  // Glowing effect
                  if (_progressAnimation.value > 0)
                    Positioned(
                      right: 0,
                      child:
                          Container(
                                width: 16,
                                height: widget.height,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppTheme.starYellow.withOpacity(0.8),
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    widget.height / 2,
                                  ),
                                ),
                              )
                              .animate(
                                onPlay: (controller) => controller.repeat(),
                              )
                              .shimmer(
                                duration: const Duration(milliseconds: 1500),
                                color: AppTheme.starYellow.withOpacity(0.5),
                              ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
