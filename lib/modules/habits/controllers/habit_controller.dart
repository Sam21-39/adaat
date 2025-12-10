import 'package:get/get.dart';
import '../../../data/models/habit_model.dart';
import '../../../data/repositories/habit_repository.dart';
import '../../../core/utils/constants.dart';
import '../../home/controllers/home_controller.dart';

/// Controller for habit creation and editing
class HabitController extends GetxController {
  final HabitRepository _repository = HabitRepository();

  // Form fields
  final name = ''.obs;
  final emoji = '💪'.obs;
  final category = HabitCategory.health.obs;
  final frequency = HabitFrequency.daily.obs;
  final customDays = <int>[].obs;
  final targetCount = Rxn<int>();
  final reminderTime = Rxn<String>();
  final reminderEnabled = true.obs;
  final notes = ''.obs;

  final isLoading = false.obs;
  final isEditing = false.obs;

  String? editingHabitId;

  /// Habit templates
  static final List<HabitTemplate> templates = [
    HabitTemplate(
      name: 'Morning Workout',
      emoji: '🏋️',
      category: HabitCategory.health,
      reminderTime: '06:00',
    ),
    HabitTemplate(
      name: 'Drink 8 Glasses Water',
      emoji: '💧',
      category: HabitCategory.health,
      targetCount: 8,
    ),
    HabitTemplate(
      name: 'Read 30 Minutes',
      emoji: '📖',
      category: HabitCategory.learning,
      reminderTime: '21:00',
    ),
    HabitTemplate(
      name: 'Meditate',
      emoji: '🧘',
      category: HabitCategory.wellness,
      reminderTime: '07:00',
    ),
    HabitTemplate(
      name: 'Study 2 Hours',
      emoji: '📚',
      category: HabitCategory.learning,
      targetCount: 2,
    ),
    HabitTemplate(name: 'Save ₹100', emoji: '💰', category: HabitCategory.money),
    HabitTemplate(
      name: 'No Phone After 10 PM',
      emoji: '📵',
      category: HabitCategory.productivity,
      reminderTime: '22:00',
    ),
    HabitTemplate(
      name: 'Daily Gratitude',
      emoji: '🙏',
      category: HabitCategory.spiritual,
      reminderTime: '21:30',
    ),
    HabitTemplate(name: 'Practice Art', emoji: '🎨', category: HabitCategory.creative),
    HabitTemplate(
      name: 'Early Wake Up (6 AM)',
      emoji: '⏰',
      category: HabitCategory.productivity,
      reminderTime: '05:45',
    ),
  ];

  /// Apply template
  void applyTemplate(HabitTemplate template) {
    name.value = template.name;
    emoji.value = template.emoji;
    category.value = template.category;
    if (template.targetCount != null) {
      targetCount.value = template.targetCount;
    }
    if (template.reminderTime != null) {
      reminderTime.value = template.reminderTime;
      reminderEnabled.value = true;
    }
  }

  /// Load habit for editing
  Future<void> loadHabit(String habitId) async {
    isEditing.value = true;
    editingHabitId = habitId;

    final habit = await _repository.getHabitById(habitId);
    if (habit == null) return;

    name.value = habit.name;
    emoji.value = habit.emoji;
    category.value = habit.category;
    frequency.value = habit.frequency;
    customDays.value = habit.customDays ?? [];
    targetCount.value = habit.targetCount;
    reminderTime.value = habit.reminderTime;
    reminderEnabled.value = habit.reminderEnabled;
    notes.value = habit.notes ?? '';
  }

  /// Validate form
  bool validate() {
    if (name.value.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a habit name');
      return false;
    }
    if (frequency.value == HabitFrequency.custom && customDays.isEmpty) {
      Get.snackbar('Error', 'Please select at least one day');
      return false;
    }
    return true;
  }

  /// Save habit
  Future<void> saveHabit() async {
    if (!validate()) return;

    isLoading.value = true;
    try {
      final habit = HabitModel(
        id: editingHabitId,
        name: name.value.trim(),
        emoji: emoji.value,
        category: category.value,
        frequency: frequency.value,
        customDays: frequency.value == HabitFrequency.custom ? customDays : null,
        targetCount: targetCount.value,
        reminderTime: reminderEnabled.value ? reminderTime.value : null,
        reminderEnabled: reminderEnabled.value && reminderTime.value != null,
        notes: notes.value.trim().isEmpty ? null : notes.value.trim(),
      );

      if (isEditing.value) {
        await _repository.updateHabit(habit);
        Get.snackbar('Success', 'Habit updated successfully!');
      } else {
        await _repository.createHabit(habit);
        Get.snackbar('Success', 'Habit created successfully!');
      }

      // Refresh home
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadHabits();
      }

      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save habit: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle custom day
  void toggleDay(int day) {
    if (customDays.contains(day)) {
      customDays.remove(day);
    } else {
      customDays.add(day);
    }
  }

  /// Reset form
  void reset() {
    name.value = '';
    emoji.value = '💪';
    category.value = HabitCategory.health;
    frequency.value = HabitFrequency.daily;
    customDays.clear();
    targetCount.value = null;
    reminderTime.value = null;
    reminderEnabled.value = true;
    notes.value = '';
    isEditing.value = false;
    editingHabitId = null;
  }

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}

/// Habit template data class
class HabitTemplate {
  final String name;
  final String emoji;
  final HabitCategory category;
  final int? targetCount;
  final String? reminderTime;

  const HabitTemplate({
    required this.name,
    required this.emoji,
    required this.category,
    this.targetCount,
    this.reminderTime,
  });
}
