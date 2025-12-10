import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/themes/colors.dart';
import '../../../core/widgets/common_widgets.dart';

/// Onboarding screen with swipeable slides
class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    const OnboardingSlide(
      emoji: '🚀',
      title: 'Build habits\nthat stick',
      subtitle: 'Start your journey towards a better you.\nOne habit at a time.',
      gradient: AppColors.primaryGradient,
    ),
    const OnboardingSlide(
      emoji: '📊',
      title: 'Track progress\nvisually',
      subtitle: 'See your streaks grow with beautiful\nheatmaps and charts.',
      gradient: AppColors.purpleGradient,
    ),
    const OnboardingSlide(
      emoji: '🎉',
      title: 'Share your\njourney',
      subtitle: 'Celebrate milestones and inspire others\nwith your achievements.',
      gradient: AppColors.successGradient,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => Get.offAllNamed(AppRoutes.login),
                child: Text(
                  'Skip',
                  style: theme.textTheme.labelLarge?.copyWith(color: AppColors.primaryOrange),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return _slides[index];
                },
              ),
            ),

            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 32 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primaryOrange
                        : AppColors.primaryOrange.withAlpha(75),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Action button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GradientButton(
                text: _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                icon: _currentPage == _slides.length - 1 ? Icons.arrow_forward : null,
                onPressed: () {
                  if (_currentPage == _slides.length - 1) {
                    Get.offAllNamed(AppRoutes.login);
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// Single onboarding slide
class OnboardingSlide extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Gradient gradient;

  const OnboardingSlide({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji with gradient background
          Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryOrange.withAlpha(75),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 72))),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut),

          const SizedBox(height: 48),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.2),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodySmall?.color,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }
}
