import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.lg),
          children: [
            Text(
              'Create Account',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start organizing your day with TodoApp.',
              style: TextStyle(color: AppColors.secondaryText),
            ),
            const SizedBox(height: 28),

            // Full Name
            _buildLabel('Full Name'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: controller.nameController,
              hint: 'Your name',
              prefixIcon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 16),

            // Email
            _buildLabel('Email Address'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: controller.emailController,
              hint: 'name@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Password
            _buildLabel('Password'),
            const SizedBox(height: 8),
            Obx(
              () => _buildTextField(
                controller: controller.passwordController,
                hint: 'Create a password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: !controller.isPasswordVisible.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordVisible.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.secondaryText,
                    size: 20,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Min 12 characters with lowercase, uppercase & number',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.secondaryText,
              ),
            ),

            // Error message
            Obx(
              () => controller.errorMessage.value.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        controller.errorMessage.value,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.errorRed,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),

            // Sign Up button
            Obx(
              () => AppPrimaryButton(
                label: 'Sign Up',
                isLoading: controller.isLoading.value,
                onPressed: controller.register,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.darkNavy,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        style: GoogleFonts.inter(fontSize: 15, color: AppColors.darkNavy),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            color: AppColors.secondaryText.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: AppColors.secondaryText,
            size: 20,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
