import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/route_names.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
          AppTextField(
            label: 'Full Name',
            hintText: 'Your name',
            controller: _name,
            prefixIcon: const Icon(Icons.person_outline_rounded),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Email Address',
            hintText: 'name@example.com',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Password',
            hintText: 'Create a password',
            controller: _password,
            obscureText: true,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
          ),
          const SizedBox(height: 24),
          AppPrimaryButton(
            label: 'Sign Up',
            onPressed: () => Get.offAllNamed(RouteNames.home),
          ),
        ],
      ),
    ),
  );
}
