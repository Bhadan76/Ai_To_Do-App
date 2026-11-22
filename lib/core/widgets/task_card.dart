import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../utils/helpers.dart';
import '../../features/categories/presentation/controllers/category_controller.dart';
import '../../features/tasks/domain/models/task.dart';
import 'custom_card.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({required this.task, this.onTap, this.onToggle, super.key});

  final TaskEntity task;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggle;

  String get categoryName {
    final id = task.categoryId;
    if (id == null || id.isEmpty) return '';
    if (Get.isRegistered<CategoryController>()) {
      return AppHelpers.firstWhereOrNull(
            Get.find<CategoryController>().categories,
            (c) => c.id == id,
          )?.name ??
          '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: 0,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: Checkbox(
                value: task.isCompleted,
                shape: const CircleBorder(),
                activeColor: AppColors.primary,
                onChanged: onToggle == null
                    ? null
                    : (value) => onToggle!(value ?? false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: task.isCompleted
                          ? AppColors.secondaryText
                          : (isDark ? AppColors.white : AppColors.darkNavy),
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppHelpers.formatDateTime(task.dueDate),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  if (categoryName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      categoryName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppHelpers.getCategoryColor(categoryName),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.secondaryText,
              size: AppSizes.iconMd,
            ),
          ],
        ),
      ),
    );
  }
}
