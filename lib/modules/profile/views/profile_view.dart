import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/themes/colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../settings/views/settings_view.dart';

/// Profile view with user info, stats summary, and settings
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.to(() => const SettingsView()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile header
            _buildProfileHeader(context),
            const SizedBox(height: 24),

            // Quick stats
            _buildQuickStats(context),
            const SizedBox(height: 24),

            // Menu items
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Center(child: Text('👤', style: TextStyle(fontSize: 40))),
          ),
          const SizedBox(height: 16),
          // Name
          const Text(
            'Guest User',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Building better habits 🚀',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          // Upgrade button
          OutlinedButton.icon(
            onPressed: () {
              Get.snackbar(
                'Coming Soon',
                'Premium features will be available soon!',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.star, size: 18),
            label: const Text('Upgrade to Premium'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildQuickStats(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _buildStatTile(
            context,
            icon: Icons.calendar_today,
            label: 'Days Active',
            value: '7',
            color: AppColors.primaryOrange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatTile(
            context,
            icon: Icons.local_fire_department,
            label: 'Best Streak',
            value: '21',
            color: AppColors.accentYellow,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatTile(
            context,
            icon: Icons.check_circle,
            label: 'Completions',
            value: '156',
            color: AppColors.accentGreen,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _buildStatTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final theme = Theme.of(context);

    final menuItems = [
      _MenuItem(
        icon: Icons.share,
        label: 'Share Progress',
        subtitle: 'Share your streak with friends',
        onTap: () => _showShareOptions(context),
      ),
      _MenuItem(
        icon: Icons.download,
        label: 'Export Data',
        subtitle: 'Download your habit history',
        onTap: () => Get.snackbar('Coming Soon', 'Data export will be available soon'),
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        label: 'Notifications',
        subtitle: 'Manage reminder settings',
        onTap: () => Get.to(() => const SettingsView()),
      ),
      _MenuItem(
        icon: Icons.help_outline,
        label: 'Help & Support',
        subtitle: 'FAQs and contact support',
        onTap: () => Get.snackbar('Help', 'Contact: hello@adaat.app'),
      ),
      _MenuItem(
        icon: Icons.info_outline,
        label: 'About Adaat',
        subtitle: 'Version 1.0.0',
        onTap: () => _showAboutDialog(context),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == menuItems.length - 1;

          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: AppColors.primaryOrange, size: 20),
                ),
                title: Text(item.label),
                subtitle: Text(item.subtitle, style: theme.textTheme.bodySmall),
                trailing: const Icon(Icons.chevron_right),
                onTap: item.onTap,
              ),
              if (!isLast) Divider(height: 1, indent: 72, color: theme.dividerColor),
            ],
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Share Your Progress', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(context, '📸', 'Instagram'),
                _buildShareOption(context, '💬', 'WhatsApp'),
                _buildShareOption(context, '🐦', 'Twitter'),
                _buildShareOption(context, '📋', 'Copy'),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(BuildContext context, String emoji, String label) {
    return GestureDetector(
      onTap: () {
        Get.back();
        Get.snackbar('Share', 'Sharing to $label...');
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: Text('✨', style: TextStyle(fontSize: 32))),
            ),
            const SizedBox(height: 16),
            const Text('Adaat', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('आदत', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            const Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            const Text(
              'Build habits that stick.\nMade with ❤️ in India',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(onPressed: () => Get.back(), child: const Text('Close')),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });
}
