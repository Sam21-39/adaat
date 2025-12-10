import 'package:get/get.dart';
import 'app_routes.dart';

// Views
import '../../modules/auth/views/splash_view.dart';
import '../../modules/auth/views/onboarding_view.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/home/views/main_view.dart';
import '../../modules/habits/views/create_habit_view.dart';
import '../../modules/habits/views/habit_detail_view.dart';

// Bindings
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/home/bindings/home_binding.dart';
import '../../modules/habits/bindings/habit_binding.dart';
import '../../modules/statistics/bindings/stats_binding.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingView()),
    GetPage(name: AppRoutes.login, page: () => const LoginView(), binding: AuthBinding()),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainView(),
      bindings: [HomeBinding(), StatsBinding()],
    ),
    GetPage(
      name: AppRoutes.createHabit,
      page: () => const CreateHabitView(),
      binding: HabitBinding(),
      transition: Transition.downToUp,
      fullscreenDialog: true,
    ),
    GetPage(
      name: AppRoutes.habitDetail,
      page: () => const HabitDetailView(),
      binding: HabitBinding(),
    ),
  ];
}
