import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/themes/colors.dart';
import '../../../core/utils/constants.dart';
import '../../../core/widgets/common_widgets.dart';
import '../controllers/habit_controller.dart';

/// Create/Edit habit screen
class CreateHabitView extends GetView<HabitController> {
  const CreateHabitView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.isEditing.value ? 'Edit Habit' : 'Create Habit')),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.isLoading.value ? null : controller.saveHabit,
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Templates section
            Obx(() {
              if (controller.isEditing.value) return const SizedBox();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Templates', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: HabitController.templates.length,
                      itemBuilder: (context, index) {
                        final template = HabitController.templates[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _buildTemplateCard(context, template, index),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                ],
              );
            }),

            // Habit name with emoji
            Text('Habit Name', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                // Emoji picker button
                Obx(
                  () => GestureDetector(
                    onTap: () => _showEmojiPicker(context),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Center(
                        child: Text(controller.emoji.value, style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    onChanged: (v) => controller.name.value = v,
                    decoration: const InputDecoration(hintText: 'e.g., Morning Workout'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Category selection
            Text('Category', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: HabitCategory.values.map((cat) {
                return Obx(
                  () => CategoryChip(
                    emoji: cat.emoji,
                    label: cat.label,
                    color: Color(cat.color),
                    isSelected: controller.category.value == cat,
                    onTap: () => controller.category.value = cat,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Frequency
            Text('Frequency', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Obx(
              () => Column(
                children: [
                  ...HabitFrequency.values.map((freq) {
                    final isSelected = controller.frequency.value == freq;
                    return ListTile(
                      title: Text(freq.label),
                      leading: Radio<bool>(
                        value: true,
                        groupValue: isSelected,
                        onChanged: (_) => controller.frequency.value = freq,
                      ),
                      onTap: () => controller.frequency.value = freq,
                      contentPadding: EdgeInsets.zero,
                    );
                  }),
                  // Custom days picker
                  if (controller.frequency.value == HabitFrequency.custom) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(7, (i) {
                        final isSelected = controller.customDays.contains(i);
                        return GestureDetector(
                          onTap: () => controller.toggleDay(i),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryOrange : theme.cardTheme.color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppColors.primaryOrange : theme.dividerColor,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                AppConstants.daysShort[i],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : null,
                                  fontWeight: isSelected ? FontWeight.bold : null,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Target count (optional)
            Row(
              children: [
                Expanded(child: Text('Target Count (optional)', style: theme.textTheme.titleSmall)),
                SizedBox(
                  width: 100,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final count = int.tryParse(v);
                      controller.targetCount.value = count;
                    },
                    decoration: const InputDecoration(
                      hintText: 'e.g., 8',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Reminder
            Row(
              children: [
                Expanded(child: Text('Daily Reminder', style: theme.textTheme.titleSmall)),
                Obx(
                  () => Switch(
                    value: controller.reminderEnabled.value,
                    onChanged: (v) => controller.reminderEnabled.value = v,
                    activeTrackColor: AppColors.primaryOrange.withAlpha(150),
                    inactiveTrackColor: theme.dividerColor,
                  ),
                ),
              ],
            ),
            Obx(() {
              if (!controller.reminderEnabled.value) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: GestureDetector(
                  onTap: () => _showTimePicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            controller.reminderTime.value ?? 'Select time',
                            style: controller.reminderTime.value == null
                                ? theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.textTheme.bodySmall?.color,
                                  )
                                : theme.textTheme.bodyMedium,
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // Notes (optional)
            Text('Notes (optional)', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              onChanged: (v) => controller.notes.value = v,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Why is this habit important to you?'),
            ),

            const SizedBox(height: 32),

            // Save button
            Obx(
              () => GradientButton(
                text: controller.isEditing.value ? 'Update Habit' : 'Create Habit',
                isLoading: controller.isLoading.value,
                onPressed: controller.saveHabit,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, HabitTemplate template, int index) {
    final theme = Theme.of(context);
    final color = Color(template.category.color);

    return GestureDetector(
          onTap: () => controller.applyTemplate(template),
          child: Container(
            width: 160,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withAlpha(100)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(template.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 8),
                Text(
                  template.name,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 50 * index))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.2);
  }

  void _showEmojiPicker(BuildContext context) {
    final emojis = [
      '💪',
      '🏃',
      '🧘',
      '📚',
      '💰',
      '🎯',
      '🧠',
      '❤️',
      '🌟',
      '🔥',
      '✨',
      '🎨',
      '🎵',
      '🏋️',
      '🚴',
      '🏊',
      '🥗',
      '💧',
      '😴',
      '📵',
      '🙏',
      '📝',
      '⏰',
      '🌅',
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose Emoji', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: emojis
                  .map(
                    (e) => GestureDetector(
                      onTap: () {
                        controller.emoji.value = e;
                        Get.back();
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: Center(child: Text(e, style: const TextStyle(fontSize: 24))),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final currentTime = controller.reminderTime.value;
    TimeOfDay initialTime = const TimeOfDay(hour: 8, minute: 0);

    if (currentTime != null) {
      final parts = currentTime.split(':');
      if (parts.length == 2) {
        initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }

    final picked = await showTimePicker(context: context, initialTime: initialTime);

    if (picked != null) {
      controller.reminderTime.value =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }
}
