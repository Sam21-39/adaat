import 'package:get/get.dart';
import 'app_routes.dart';

// Auth
import '../../modules/auth/views/splash_view.dart';
import '../../modules/auth/views/onboarding_view.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/bindings/auth_binding.dart';

// Home
import '../../modules/home/views/main_view.dart';
import '../../modules/home/bindings/home_binding.dart';

// Habits
import '../../modules/habits/views/create_habit_view.dart';
import '../../modules/habits/views/habit_detail_view.dart';
import '../../modules/habits/bindings/habit_binding.dart';

// Statistics
import '../../modules/statistics/bindings/stats_binding.dart';

/// App pages configuration for GetX routing
class AppPages {
  static final routes = [
    // Splash screen
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),

    // Onboarding
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingView()),

    // Login
    GetPage(name: AppRoutes.login, page: () => const LoginView(), binding: AuthBinding()),

    // Main (with bottom nav)
    GetPage(
      name: AppRoutes.main,
      page: () => const MainView(),
      bindings: [HomeBinding(), StatsBinding()],
    ),

    // Create habit
    GetPage(
      name: AppRoutes.createHabit,
      page: () => const CreateHabitView(),
      binding: HabitBinding(),
      transition: Transition.downToUp,
    ),

    // Habit detail
    GetPage(
      name: AppRoutes.habitDetail,
      page: () => const HabitDetailView(),
      transition: Transition.rightToLeft,
    ),
  ];
}
