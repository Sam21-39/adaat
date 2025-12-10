import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/user_model.dart';

/// Authentication controller for login/signup
class AuthController extends GetxController {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  final isLoading = false.obs;
  final showOtpField = false.obs;
  final phoneError = ''.obs;
  final otpError = ''.obs;

  String? _verificationId;
  UserModel? currentUser;

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  /// Validate phone number
  bool _validatePhone() {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      phoneError.value = 'Please enter your phone number';
      return false;
    }
    if (phone.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
      phoneError.value = 'Please enter a valid 10-digit phone number';
      return false;
    }
    phoneError.value = '';
    return true;
  }

  /// Send OTP to phone
  Future<void> sendOtp() async {
    if (!_validatePhone()) return;

    isLoading.value = true;
    try {
      // TODO: Implement Firebase Phone Auth
      // For now, simulate OTP send
      await Future.delayed(const Duration(seconds: 1));
      _verificationId = 'test-verification-id';
      showOtpField.value = true;
      Get.snackbar(
        'OTP Sent',
        'Please check your phone for the verification code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(200),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send OTP. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(200),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify OTP
  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.isEmpty) {
      otpError.value = 'Please enter the OTP';
      return;
    }
    if (otp.length != 6) {
      otpError.value = 'Please enter a valid 6-digit OTP';
      return;
    }
    otpError.value = '';

    isLoading.value = true;
    try {
      // TODO: Implement Firebase OTP verification
      // For now, simulate verification
      await Future.delayed(const Duration(seconds: 1));

      // Create local user
      currentUser = UserModel(
        id: const Uuid().v4(),
        phone: '+91${phoneController.text.trim()}',
        displayName: 'User',
      );

      _navigateToMain();
    } catch (e) {
      otpError.value = 'Invalid OTP. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    try {
      // TODO: Implement Google Sign-In
      // For now, simulate sign in
      await Future.delayed(const Duration(seconds: 1));

      currentUser = UserModel(
        id: const Uuid().v4(),
        email: 'user@gmail.com',
        displayName: 'Google User',
      );

      _navigateToMain();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign in with Google. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(200),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Continue as guest
  void continueAsGuest() {
    currentUser = UserModel(id: const Uuid().v4(), displayName: 'Guest');
    _navigateToMain();
  }

  /// Navigate to main screen
  void _navigateToMain() {
    Get.offAllNamed(AppRoutes.main);
  }
}
