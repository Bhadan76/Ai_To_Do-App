import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../../shared/models/task_model.dart';
import 'custom_card.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({required this.task, this.onTap, this.onToggle, super.key});

  final TaskModel task;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggle;

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
                    '${task.dueDate}, ${task.dueTime}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.more_vert_rounded,
              color: AppColors.secondaryText,
              size: AppSizes.iconMd,
            ),
          ],
        ),
      ),
    );
  }
}
