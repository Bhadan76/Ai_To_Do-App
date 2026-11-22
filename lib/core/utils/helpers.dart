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
    switch (priority.toUpperCase()) {
      case 'URGENT':
      case 'HIGH':
        return AppColors.errorRed;
      case 'LOW':
        return AppColors.successGreen;
      case 'MEDIUM':
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }

  /// Parses a timezone-aware ISO 8601 string into a local-mode [DateTime].
  static DateTime? parseIso8601(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return null;
    // Only convert when the source is explicitly UTC/offset-aware. Naive
    // strings are already local and must not be shifted.
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  /// Serializes a [DateTime] to a timezone-aware ISO 8601 string that
  /// represents the actual instant in UTC (`2026-12-01T09:00:00.000Z`).
  ///
  /// The input [d] is treated as a local-mode [DateTime]; its epoch is
  /// converted to UTC before serialization. This matches the backend's
  /// Prisma `DateTime` storage (instants) and avoids the one-day shift
  /// caused by labelling local wall-clock values as UTC.
  static String toIso8601(DateTime d) {
    final utc = d.toUtc();
    return '${utc.year.toString().padLeft(4, '0')}-'
        '${utc.month.toString().padLeft(2, '0')}-'
        '${utc.day.toString().padLeft(2, '0')}T'
        '${utc.hour.toString().padLeft(2, '0')}:'
        '${utc.minute.toString().padLeft(2, '0')}:'
        '${utc.second.toString().padLeft(2, '0')}.'
        '${utc.millisecond.toString().padLeft(3, '0')}Z';
  }

  /// Formats a local-mode [DateTime] for display without an ISO round-trip.
  static String formatLocalDateTime(DateTime d) {
    final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour < 12 ? 'AM' : 'PM';
    final minute = d.minute.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$month/$day/${d.year}, $hour12:$minute $ampm';
  }

  /// True when the task's due date falls on [date]'s calendar day.
  static bool isDueOn(String? dueDate, DateTime date) {
    final due = parseIso8601(dueDate);
    if (due == null) return false;
    return due.year == date.year &&
        due.month == date.month &&
        due.day == date.day;
  }

  /// True when the task's due date is today.
  static bool isDueToday(String? dueDate) => isDueOn(dueDate, DateTime.now());

  /// Formats an ISO 8601 string for display: `MM/dd/yyyy, h:mm AM/PM`.
  static String formatDateTime(String? iso) {
    final d = parseIso8601(iso);
    if (d == null) return '';
    final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour < 12 ? 'AM' : 'PM';
    final minute = d.minute.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$month/$day/${d.year}, $hour12:$minute $ampm';
  }

  /// Returns the first element matching [test], or null when none matches.
  static T? firstWhereOrNull<T>(
    Iterable<T> elements,
    bool Function(T element) test,
  ) {
    for (final element in elements) {
      if (test(element)) return element;
    }
    return null;
  }
}
