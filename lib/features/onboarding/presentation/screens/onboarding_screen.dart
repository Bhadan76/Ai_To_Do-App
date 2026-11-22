import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../app/routes/route_names.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static final List<_OnboardData> _pages = [
    _OnboardData(
      title: 'Stay Organized',
      subtitle: 'Keep track of your tasks\nand boost productivity.',
      illustrationIcon: Icons.laptop_mac_rounded,
      illustrationBg: AppColors.white,
      illustrationAccent: AppColors.primary,
    ),
    _OnboardData(
      title: 'Never Miss Anything',
      subtitle: 'Get reminders and stay on schedule.',
      illustrationIcon: Icons.notifications_active_rounded,
      illustrationBg: AppColors.white,
      illustrationAccent: AppColors.healthColor,
    ),
    _OnboardData(
      title: 'Achieve Your Goals',
      subtitle: 'Turn your plans into real achievements.',
      illustrationIcon: Icons.emoji_events_rounded,
      illustrationBg: AppColors.white,
      illustrationAccent: AppColors.studyColor,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offAllNamed(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.lavenderBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 20),
                child: TextButton(
                  onPressed: () => Get.offAllNamed(RouteNames.login),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Illustration
                        Container(
                          width: size.width * 0.7,
                          height: size.height * 0.35,
                          decoration: BoxDecoration(
                            color: page.illustrationBg,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Main illustration icon
                              Icon(
                                page.illustrationIcon,
                                size: 100,
                                color: page.illustrationAccent,
                              ),
                              // Decorative elements
                              Positioned(
                                top: 24,
                                right: 24,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: page.illustrationAccent.withValues(
                                      alpha: 0.15,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: page.illustrationAccent,
                                    size: 20,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 24,
                                left: 24,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: page.illustrationAccent.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 36,
                                left: 36,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.15,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkNavy,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          page.subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppColors.secondaryText,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots indicator
            _buildDotIndicator(),

            const SizedBox(height: 32),

            // Next/Get Started button
            _buildNextButton(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: _next,
        child: Container(
          width: double.infinity,
          height: AppSizes.buttonHeight,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primarySecondary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _currentPage == _pages.length - 1 ? 'Get Started →' : 'Next →',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: i == _currentPage ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: i == _currentPage
                ? AppColors.primary
                : AppColors.borderColor,
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}

class _OnboardData {
  final String title;
  final String subtitle;
  final IconData illustrationIcon;
  final Color illustrationBg;
  final Color illustrationAccent;

  const _OnboardData({
    required this.title,
    required this.subtitle,
    required this.illustrationIcon,
    required this.illustrationBg,
    required this.illustrationAccent,
  });
}
