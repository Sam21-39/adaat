import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/themes/colors.dart';
import '../../../core/widgets/habit_card.dart';
import '../../../core/widgets/common_widgets.dart';
import '../controllers/home_controller.dart';
import '../../statistics/views/stats_view.dart';
import '../../profile/views/profile_view.dart';

/// Main navigation view with bottom tabs
class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;

  final _pages = const [HomeView(), StatsView(), ProfileView()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.createHabit),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Home tab with today's habits
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: controller.loadHabits,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Row(
                      children: [
                        Text(controller.greetingEmoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.greeting,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                today,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),

                    const SizedBox(height: 24),

                    // Progress card
                    Obx(() => _buildProgressCard(context)),
                  ],
                ),
              ),
            ),

            // Habits list header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Today\'s Habits', style: theme.textTheme.titleMedium),
                    Obx(
                      () => Text(
                        '${controller.todaysCheckIns.length}/${controller.habits.length}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Habits list
            Obx(() {
              if (controller.isLoading.value) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }

              if (controller.habits.isEmpty) {
                return SliverFillRemaining(child: _buildEmptyState(context));
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final habit = controller.habits[index];
                    final isCompleted = controller.isCompletedToday(habit.id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child:
                          HabitCard(
                                habit: habit,
                                isCompleted: isCompleted,
                                onTap: () => controller.toggleCheckIn(habit),
                                onLongPress: () =>
                                    Get.toNamed(AppRoutes.habitDetail, arguments: habit.id),
                              )
                              .animate(delay: Duration(milliseconds: 50 * index))
                              .fadeIn(duration: 300.ms)
                              .slideX(begin: 0.1),
                    );
                  }, childCount: controller.habits.length),
                ),
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final progress = controller.todayProgress.value;
    final percentage = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today\'s Progress',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getMotivationalQuote(progress),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ProgressCircle(
            progress: progress,
            size: 80,
            strokeWidth: 8,
            color: Colors.white,
            child: Text(
              '${controller.todaysCheckIns.length}/${controller.habits.length}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌱', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('No habits yet', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your first habit!',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'Create Habit',
              icon: Icons.add,
              width: 180,
              onPressed: () => Get.toNamed(AppRoutes.createHabit),
            ),
          ],
        ),
      ),
    );
  }

  String _getMotivationalQuote(double progress) {
    if (progress >= 1.0) return 'Perfect day! You did it! 🏆';
    if (progress >= 0.75) return 'Almost there! Keep going! 💪';
    if (progress >= 0.5) return 'Halfway done, you got this! 🔥';
    if (progress >= 0.25) return 'Good start! Keep building! 🌟';
    return 'Let\'s make today count! ✨';
  }
}
