import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_item.dart';
import '../../utils/date_utils.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTabIndex = 4;

  Future<void> _showComingSoon(String title) async {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title is coming soon')));
  }

  Future<void> _showSectionAction(String title) async {
    await _showComingSoon(title);
  }

  Future<void> _showLogoutDialog() async {
    if (!mounted) return;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text('Do you want to log out from this device?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logged out successfully')));
    }
  }

  int _calculateDaysActive(List<TaskItem> tasks) {
    final activeDays = tasks
        .map((task) => DateUtilsHelper.normalize(task.scheduledDate))
        .toSet();
    return math.max(1, activeDays.length);
  }

  int _calculateStreak(List<TaskItem> tasks) {
    final completedDays = tasks
        .where((task) => task.isCompleted)
        .map((task) => DateUtilsHelper.normalize(task.scheduledDate))
        .toSet();

    if (completedDays.isEmpty) {
      return 0;
    }

    var streak = 0;
    var cursor = DateUtilsHelper.normalize(DateTime.now());

    while (completedDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return math.max(streak, 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer2<TaskViewModel, ThemeViewModel>(
      builder: (context, taskViewModel, themeViewModel, _) {
        final tasks = taskViewModel.allTasks;
        final totalTasks = taskViewModel.totalTasks;
        final completedTasks = taskViewModel.completedTasksCount;
        final pendingTasks = math.max(0, totalTasks - completedTasks);
        final daysActive = _calculateDaysActive(tasks);
        final streak = _calculateStreak(tasks);

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 420;
                final horizontalPadding = isCompact ? 16.0 : 20.0;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      12,
                      horizontalPadding,
                      24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HeaderRow(
                              onSettingsTap: () =>
                                  _showSectionAction('Settings'),
                            ),
                            const SizedBox(height: 16),
                            _ProfileCard(
                              isCompact: isCompact,
                              onTap: () =>
                                  _showSectionAction('Profile details'),
                            ),
                            const SizedBox(height: 14),
                            _StatsGrid(
                              isCompact: isCompact,
                              completedTasks: completedTasks,
                              pendingTasks: pendingTasks,
                              daysActive: daysActive,
                              streak: streak,
                            ),
                            const SizedBox(height: 16),
                            _PremiumBanner(
                              onManagePlan: () =>
                                  _showSectionAction('Manage plan'),
                            ),
                            const SizedBox(height: 18),
                            _SectionTitle(title: 'Account'),
                            const SizedBox(height: 10),
                            _SectionCard(
                              children: [
                                _ActionRow(
                                  icon: Icons.person_outline_rounded,
                                  label: 'Personal Information',
                                  onTap: () => _showSectionAction(
                                    'Personal Information',
                                  ),
                                ),
                                const Divider(height: 1),
                                _ActionRow(
                                  icon: Icons.lock_outline_rounded,
                                  label: 'Change Password',
                                  onTap: () =>
                                      _showSectionAction('Change Password'),
                                ),
                                const Divider(height: 1),
                                _ActionRow(
                                  icon: Icons.notifications_none_rounded,
                                  label: 'Notifications',
                                  onTap: () =>
                                      _showSectionAction('Notifications'),
                                ),
                                const Divider(height: 1),
                                _ActionRow(
                                  icon: Icons.dark_mode_outlined,
                                  label: 'Theme',
                                  trailing: themeViewModel.isDarkMode
                                      ? 'Dark'
                                      : 'Light',
                                  onTap: themeViewModel.toggleTheme,
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _SectionTitle(title: 'More'),
                            const SizedBox(height: 10),
                            _SectionCard(
                              children: [
                                _ActionRow(
                                  icon: Icons.help_outline_rounded,
                                  label: 'Help & Support',
                                  onTap: () =>
                                      _showSectionAction('Help & Support'),
                                ),
                                const Divider(height: 1),
                                _ActionRow(
                                  icon: Icons.shield_outlined,
                                  label: 'Privacy Policy',
                                  onTap: () =>
                                      _showSectionAction('Privacy Policy'),
                                ),
                                const Divider(height: 1),
                                _ActionRow(
                                  icon: Icons.description_outlined,
                                  label: 'Terms of Service',
                                  onTap: () =>
                                      _showSectionAction('Terms of Service'),
                                ),
                                const Divider(height: 1),
                                _ActionRow(
                                  icon: Icons.info_outline_rounded,
                                  label: 'About TodoApp',
                                  onTap: () =>
                                      _showSectionAction('About TodoApp'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _LogoutButton(onPressed: _showLogoutDialog),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: const Color(0xFF6C63FF).withValues(alpha: 0.12),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? const Color(0xFF6C63FF)
                      : Colors.grey.shade500,
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: _selectedTabIndex,
              onDestinationSelected: (index) {
                if (index == 4) {
                  setState(() => _selectedTabIndex = index);
                  return;
                }

                if (index == 0) {
                  Navigator.of(context).pop();
                  return;
                }

                setState(() => _selectedTabIndex = index);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Navigation screen not connected yet'),
                  ),
                );
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.checklist_outlined),
                  selectedIcon: Icon(Icons.checklist_rounded),
                  label: 'Tasks',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: 'Calendar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.center_focus_strong_outlined),
                  selectedIcon: Icon(Icons.center_focus_strong_rounded),
                  label: 'Focus',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.onSettingsTap});

  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Profile',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        IconButton(
          onPressed: onSettingsTap,
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.isCompact, required this.onTap});

  final bool isCompact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surface = colorScheme.surface;

    return Material(
      color: surface,
      elevation: 0,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(isCompact ? 14 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: isCompact ? 56 : 60,
                    height: isCompact ? 56 : 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF7C6DFF), Color(0xFF5A49E6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'VK',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.25,
                        ),
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Vineet Kumar',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'vineet.kumar@example.com',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: Color(0xFF6C63FF),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Premium',
                            style: TextStyle(
                              color: Color(0xFF6C63FF),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.isCompact,
    required this.completedTasks,
    required this.pendingTasks,
    required this.daysActive,
    required this.streak,
  });

  final bool isCompact;
  final int completedTasks;
  final int pendingTasks;
  final int daysActive;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatData(
        icon: Icons.check_circle_outline_rounded,
        iconColor: const Color(0xFF6C63FF),
        iconBackground: const Color(0xFFF0EDFF),
        count: completedTasks.toString(),
        label: 'Tasks Completed',
      ),
      _StatData(
        icon: Icons.schedule_rounded,
        iconColor: const Color(0xFF3B82F6),
        iconBackground: const Color(0xFFEFF6FF),
        count: pendingTasks.toString(),
        label: 'Tasks Pending',
      ),
      _StatData(
        icon: Icons.calendar_month_outlined,
        iconColor: const Color(0xFF10B981),
        iconBackground: const Color(0xFFE9FBF3),
        count: daysActive.toString(),
        label: 'Days Active',
      ),
      _StatData(
        icon: Icons.local_fire_department_outlined,
        iconColor: const Color(0xFFF59E0B),
        iconBackground: const Color(0xFFFFF4DD),
        count: streak.toString(),
        label: 'Day Streak',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final cardWidth = isCompact
            ? (availableWidth - 8) / 2
            : (availableWidth - 24) / 4;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: stats
              .map(
                (item) => SizedBox(
                  width: cardWidth,
                  child: _StatCard(data: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _StatData {
  const _StatData({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.count,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String count;
  final String label;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: data.iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: data.iconColor, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            data.count,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  const _PremiumBanner({required this.onManagePlan});

  final VoidCallback onManagePlan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFF6C63FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You're a Premium User",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF312E81),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Thanks for being awesome! Enjoy all premium features.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF4338CA).withValues(alpha: 0.82),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onManagePlan,
            child: const Text(
              'Manage Plan',
              style: TextStyle(
                color: Color(0xFF6C63FF),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Colors.grey.shade500,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 17, color: const Color(0xFF6C63FF)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
        label: const Text(
          'Log Out',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.red.withValues(alpha: 0.06),
          side: BorderSide(color: Colors.red.withValues(alpha: 0.15)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
