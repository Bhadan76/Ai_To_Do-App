import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final double? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? borderRadius;
  final bool showBorder;
  final bool showShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSizes.cardPadding,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.showBorder = true,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg =
        backgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.white);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding ?? 0),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppSizes.cardRadius,
          ),
          border: showBorder
              ? Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.borderColor,
                  width: 1,
                )
              : null,
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(
                      alpha: isDark ? 0.0 : 0.06,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}
