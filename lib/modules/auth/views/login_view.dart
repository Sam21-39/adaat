import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/themes/colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../controllers/auth_controller.dart';

/// Login screen with phone OTP and Google Sign-In
class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Welcome header
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryOrange.withAlpha(75),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(child: Text('✨', style: TextStyle(fontSize: 40))),
                ),
              ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),

              const SizedBox(height: 24),

              Text(
                'Welcome to Adaat',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 8),

              Text(
                'Build habits that stick 🚀',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.textTheme.bodySmall?.color),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              const SizedBox(height: 48),

              // Phone number input
              Obx(
                () => TextField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '9876543210',
                    prefixText: '+91 ',
                    counterText: '',
                    errorText: controller.phoneError.value.isEmpty
                        ? null
                        : controller.phoneError.value,
                    prefixIcon: const Icon(Icons.phone_android),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

              const SizedBox(height: 16),

              // OTP input (shown after phone verification)
              Obx(() {
                if (!controller.showOtpField.value) return const SizedBox();
                return Column(
                  children: [
                    TextField(
                      controller: controller.otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: 'OTP',
                        hintText: '123456',
                        counterText: '',
                        errorText: controller.otpError.value.isEmpty
                            ? null
                            : controller.otpError.value,
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ).animate().fadeIn(duration: 300.ms);
              }),

              // Send OTP / Verify button
              Obx(
                () => GradientButton(
                  text: controller.showOtpField.value ? 'Verify OTP' : 'Send OTP',
                  isLoading: controller.isLoading.value,
                  onPressed: controller.showOtpField.value
                      ? controller.verifyOtp
                      : controller.sendOtp,
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: theme.dividerColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('or', style: theme.textTheme.bodySmall),
                  ),
                  Expanded(child: Divider(color: theme.dividerColor)),
                ],
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

              const SizedBox(height: 24),

              // Google Sign-In
              Obx(
                () => OutlinedButton.icon(
                  onPressed: controller.isLoading.value ? null : controller.signInWithGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Continue with Google'),
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms, duration: 400.ms),

              const SizedBox(height: 24),

              // Skip for now
              Center(
                child: TextButton(
                  onPressed: () => controller.continueAsGuest(),
                  child: Text(
                    'Continue as Guest',
                    style: theme.textTheme.labelLarge?.copyWith(color: AppColors.primaryOrange),
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms, duration: 400.ms),

              const SizedBox(height: 32),

              // Terms
              Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ).animate().fadeIn(delay: 900.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
