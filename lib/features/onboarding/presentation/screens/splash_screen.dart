import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../app/routes/route_names.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../notifications/presentation/controllers/notification_controller.dart';
import '../widgets/app_name.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _scaleAnim = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    _timer = Timer(const Duration(seconds: 5), () async {
      if (mounted) {
        // Attempt to restore a previous session
        bool hasSession = false;
        try {
          final authController = Get.find<AuthController>();
          hasSession = await authController.restoreSession();
        } catch (_) {
          // AuthController not registered or restore failed
        }

        if (hasSession && mounted) {
          Get.offAllNamed(RouteNames.home);
          if (Get.isRegistered<NotificationController>()) {
            Get.find<NotificationController>().checkAndNavigatePendingTask();
          }
        } else if (mounted) {
          Get.offAllNamed(RouteNames.onboarding);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F6FF), Color(0xFFEAE4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) => FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(scale: _scaleAnim, child: child),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Logo container
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset(
                      'assets/app_icon/app_icon.png',
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // App name
                AppNameWidget(),
                const SizedBox(height: 8),
                Text(
                  'Plan • Organize • Achieve',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryText,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 48),
                // Calendar & Clock illustration (Custom painted)
                _buildCalendarClock(),
                const Spacer(flex: 2),
                // Tagline at bottom
                Text(
                  'Get more done,\none task at a time.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                // Loading dots
                _buildDotLoader(),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDotLoader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: i == 0 ? AppColors.primary : AppColors.borderColor,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildCalendarClock() {
    return SizedBox(
      width: 240,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Calendar
          Positioned(
            left: 20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primarySecondary],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: List.generate(21, (i) {
                        final bool isChecked = i == 5 || i == 10;
                        return Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: isChecked
                                ? AppColors.primary
                                : AppColors.borderColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: isChecked
                              ? const Icon(
                                  Icons.check,
                                  size: 10,
                                  color: AppColors.white,
                                )
                              : null,
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Clock
          Positioned(
            right: 10,
            bottom: 10,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.access_time_rounded,
                color: AppColors.primary,
                size: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
