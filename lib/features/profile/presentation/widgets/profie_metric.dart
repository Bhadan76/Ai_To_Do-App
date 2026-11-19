import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class ProfileMetric extends StatelessWidget {
  final String value;
  final String label;
  const ProfileMetric({super.key, required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      Text(
        label,
        style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
      ),
    ],
  );
}