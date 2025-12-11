import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/colors.dart';

/// Settings view with theme, notifications, and app preferences
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _selectedLanguage = 'English';
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 7, minute: 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications section
            _buildSectionHeader(context, 'Notifications'),
            _buildSettingsCard(context, [
              _buildSwitchTile(
                context,
                icon: Icons.notifications,
                title: 'Push Notifications',
                subtitle: 'Receive reminders for your habits',
                value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
              ),
              _buildSwitchTile(
                context,
                icon: Icons.volume_up,
                title: 'Sound',
                subtitle: 'Play sound with notifications',
                value: _soundEnabled,
                onChanged: _notificationsEnabled ? (v) => setState(() => _soundEnabled = v) : null,
              ),
              _buildSwitchTile(
                context,
                icon: Icons.vibration,
                title: 'Vibration',
                subtitle: 'Vibrate with notifications',
                value: _vibrationEnabled,
                onChanged: _notificationsEnabled
                    ? (v) => setState(() => _vibrationEnabled = v)
                    : null,
              ),
              _buildTimeTile(
                context,
                icon: Icons.bedtime,
                title: 'Quiet Hours',
                subtitle: '${_formatTime(_quietHoursStart)} - ${_formatTime(_quietHoursEnd)}',
                onTap: () => _showQuietHoursDialog(context),
              ),
            ]),
            const SizedBox(height: 16),

            // Appearance section
            _buildSectionHeader(context, 'Appearance'),
            _buildSettingsCard(context, [
              _buildNavigationTile(
                context,
                icon: Icons.palette,
                title: 'Theme',
                subtitle: isDark ? 'Dark' : 'Light',
                onTap: () => _showThemeDialog(context),
              ),
              _buildNavigationTile(
                context,
                icon: Icons.language,
                title: 'Language',
                subtitle: _selectedLanguage,
                onTap: () => _showLanguageDialog(context),
              ),
            ]),
            const SizedBox(height: 16),

            // Data section
            _buildSectionHeader(context, 'Data & Privacy'),
            _buildSettingsCard(context, [
              _buildNavigationTile(
                context,
                icon: Icons.backup,
                title: 'Backup & Sync',
                subtitle: 'Sign in to backup your data',
                onTap: () => Get.snackbar('Coming Soon', 'Cloud sync will be available soon'),
              ),
              _buildNavigationTile(
                context,
                icon: Icons.download,
                title: 'Export Data',
                subtitle: 'Download your habit history',
                onTap: () => Get.snackbar('Coming Soon', 'Data export will be available soon'),
              ),
              _buildNavigationTile(
                context,
                icon: Icons.delete_outline,
                title: 'Clear Data',
                subtitle: 'Delete all habits and check-ins',
                titleColor: AppColors.accentRed,
                onTap: () => _showClearDataDialog(context),
              ),
            ]),
            const SizedBox(height: 16),

            // About section
            _buildSectionHeader(context, 'About'),
            _buildSettingsCard(context, [
              _buildNavigationTile(
                context,
                icon: Icons.star_rate,
                title: 'Rate App',
                subtitle: 'Love Adaat? Leave a review!',
                onTap: () => Get.snackbar('Thanks!', 'Opening store...'),
              ),
              _buildNavigationTile(
                context,
                icon: Icons.mail_outline,
                title: 'Contact Us',
                subtitle: 'hello@adaat.app',
                onTap: () => Get.snackbar('Email', 'Opening mail app...'),
              ),
              _buildNavigationTile(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () => Get.snackbar('Info', 'Opening privacy policy...'),
              ),
              _buildNavigationTile(
                context,
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'Read our terms',
                onTap: () => Get.snackbar('Info', 'Opening terms...'),
              ),
            ]),
            const SizedBox(height: 24),

            // Version
            Center(
              child: Text(
                'Adaat v1.0.0\nMade with ❤️ in India',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.primaryOrange,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          final isLast = index == children.length - 1;

          return Column(
            children: [
              child,
              if (!isLast) Divider(height: 1, indent: 56, color: theme.dividerColor),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    final theme = Theme.of(context);
    final enabled = onChanged != null;

    return ListTile(
      leading: Icon(icon, color: enabled ? AppColors.primaryOrange : theme.disabledColor),
      title: Text(title, style: TextStyle(color: enabled ? null : theme.disabledColor)),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(color: enabled ? null : theme.disabledColor),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primaryOrange.withAlpha(150),
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: titleColor ?? AppColors.primaryOrange),
      title: Text(title, style: TextStyle(color: titleColor)),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildTimeTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final enabled = _notificationsEnabled;

    return ListTile(
      leading: Icon(icon, color: enabled ? AppColors.primaryOrange : theme.disabledColor),
      title: Text(title, style: TextStyle(color: enabled ? null : theme.disabledColor)),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(color: enabled ? null : theme.disabledColor),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: enabled ? onTap : null,
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light'),
              onTap: () {
                Get.changeThemeMode(ThemeMode.light);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark'),
              onTap: () {
                Get.changeThemeMode(ThemeMode.dark);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('System'),
              onTap: () {
                Get.changeThemeMode(ThemeMode.system);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: _selectedLanguage == 'English'
                  ? const Icon(Icons.check, color: AppColors.primaryOrange)
                  : null,
              onTap: () {
                setState(() => _selectedLanguage = 'English');
                Get.back();
              },
            ),
            ListTile(
              title: const Text('हिंदी (Hindi)'),
              trailing: _selectedLanguage == 'Hindi'
                  ? const Icon(Icons.check, color: AppColors.primaryOrange)
                  : null,
              onTap: () {
                setState(() => _selectedLanguage = 'Hindi');
                Get.back();
                Get.snackbar('Coming Soon', 'Hindi language support coming soon!');
              },
            ),
            ListTile(
              title: const Text('Hinglish'),
              trailing: _selectedLanguage == 'Hinglish'
                  ? const Icon(Icons.check, color: AppColors.primaryOrange)
                  : null,
              onTap: () {
                setState(() => _selectedLanguage = 'Hinglish');
                Get.back();
                Get.snackbar('Coming Soon', 'Hinglish support coming soon!');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQuietHoursDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiet Hours'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No notifications during these hours:'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Start'),
                      TextButton(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _quietHoursStart,
                          );
                          if (time != null) {
                            setState(() => _quietHoursStart = time);
                          }
                        },
                        child: Text(_formatTime(_quietHoursStart)),
                      ),
                    ],
                  ),
                ),
                const Text('to'),
                Expanded(
                  child: Column(
                    children: [
                      const Text('End'),
                      TextButton(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _quietHoursEnd,
                          );
                          if (time != null) {
                            setState(() => _quietHoursEnd = time);
                          }
                        },
                        child: Text(_formatTime(_quietHoursEnd)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Saved', 'Quiet hours updated');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will delete all your habits, check-ins, and streaks. This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRed),
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Data Cleared',
                'All your data has been deleted',
                backgroundColor: AppColors.accentRed.withAlpha(200),
                colorText: Colors.white,
              );
            },
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }
}
