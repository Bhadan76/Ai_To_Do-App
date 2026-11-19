import '../../core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppHelpers {
  AppHelpers._();

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return AppColors.workColor;
      case 'personal':
        return AppColors.personalColor;
      case 'health':
        return AppColors.healthColor;
      case 'study':
        return AppColors.studyColor;
      default:
        return AppColors.primary;
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Icons.work_outline_rounded;
      case 'personal':
        return Icons.person_outline_rounded;
      case 'health':
        return Icons.favorite_border_rounded;
      case 'study':
        return Icons.book_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high priority':
        return AppColors.errorRed;
      case 'normal':
        return AppColors.primary;
      case 'low':
        return AppColors.successGreen;
      default:
        return AppColors.primary;
    }
  }
}
