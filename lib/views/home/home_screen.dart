import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/app_colors.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/task_card.dart';
import '../add_task_bottom_sheet.dart';
import '../task/add_edit_task_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  Future<void> _openAddTaskSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return AddTaskBottomSheet(
          onSave: (title, description, date) => sheetContext
              .read<TaskViewModel>()
              .addTask(title, description, date),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getWeekdayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _getDayAndMonthName(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _getFilterTitle(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return "All Tasks";
      case TaskFilter.yesterday:
        return "Overdue Tasks";
      case TaskFilter.today:
        return "Today's Tasks";
      case TaskFilter.future:
        return "Upcoming Tasks";
      case TaskFilter.completed:
        return "Completed Tasks";
      case TaskFilter.pending:
        return "Pending Tasks";
    }
  }

  AppBar? _buildAppBar(ThemeViewModel themeViewModel, ThemeData theme) {
    if (_currentIndex == 0) {
      // Home Screen AppBar
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: themeViewModel.toggleTheme,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                themeViewModel.isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                key: ValueKey<bool>(themeViewModel.isDarkMode),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6366F1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      );
    } else if (_currentIndex == 1) {
      // Tasks Screen AppBar
      return AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        ),
        title: Text(
          'All Tasks',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded), // filter icon
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded), // horizontal more menu
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      );
    }
    return null;
  }

  Widget? _buildFAB() {
    if (_currentIndex == 1) {
      return FloatingActionButton(
        onPressed: () => _openAddTaskSheet(context),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 28),
      );
    }
    return null;
  }

  Widget _buildBody(TaskViewModel taskViewModel, ThemeData theme) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeBody(taskViewModel, theme);
      case 1:
        return _buildTasksBody(taskViewModel, theme);
      default:
        return _buildPlaceholderBody();
    }
  }

  Widget _buildHomeBody(TaskViewModel taskViewModel, ThemeData theme) {
    final now = DateTime.now();
    final weekday = _getWeekdayName(now);
    final dayAndMonth = _getDayAndMonthName(now);

    return RefreshIndicator(
      onRefresh: taskViewModel.loadTasks,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Greeting & Date Badge Header
          LayoutBuilder(
            builder: (context, constraints) {
              final contentMaxWidth = (constraints.maxWidth - 120).clamp(
                0.0,
                constraints.maxWidth,
              );
              return Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: contentMaxWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                '${_getGreeting()}, Vineet',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          taskViewModel.todayTasksCount == 1
                              ? "You've got 1 task today"
                              : "You've got ${taskViewModel.todayTasksCount} tasks today",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Rounded Date Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.light
                          ? const Color(0xFFEEF2FF)
                          : const Color(0xFF1E1B4B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.brightness == Brightness.light
                            ? const Color(0xFFE0E7FF)
                            : const Color(0xFF312E81),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          weekday,
                          style: TextStyle(
                            color: theme.brightness == Brightness.light
                                ? const Color(0xFF6366F1)
                                : const Color(0xFFC7D2FE),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dayAndMonth,
                          style: TextStyle(
                            color: theme.brightness == Brightness.light
                                ? const Color(0xFF312E81)
                                : Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),

          // Today's Progress Card
          _buildProgressCard(context, taskViewModel),
          const SizedBox(height: 22),

          // Metrics Cards Row
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context: context,
                  label: 'Today',
                  count: '${taskViewModel.todayTasksCount}',
                  icon: Icons.light_mode_outlined,
                  iconColor: const Color(0xFF3B82F6),
                  iconBgColor: const Color(0xFFEFF6FF),
                  isActive: taskViewModel.selectedFilter == TaskFilter.today,
                  onTap: () => taskViewModel.setFilter(TaskFilter.today),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  context: context,
                  label: 'Upcoming',
                  count: '${taskViewModel.upcomingTasksCount}',
                  icon: Icons.calendar_month_outlined,
                  iconColor: const Color(0xFF6366F1),
                  iconBgColor: const Color(0xFFEEF2FF),
                  isActive: taskViewModel.selectedFilter == TaskFilter.future,
                  onTap: () => taskViewModel.setFilter(TaskFilter.future),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  context: context,
                  label: 'Completed',
                  count: '${taskViewModel.completedTasksCount}',
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: const Color(0xFF10B981),
                  iconBgColor: const Color(0xFFECFDF5),
                  isActive:
                      taskViewModel.selectedFilter == TaskFilter.completed,
                  onTap: () => taskViewModel.setFilter(TaskFilter.completed),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  context: context,
                  label: 'Overdue',
                  count: '${taskViewModel.overdueTasksCount}',
                  icon: Icons.error_outline_rounded,
                  iconColor: const Color(0xFFEF4444),
                  iconBgColor: const Color(0xFFFEF2F2),
                  isActive:
                      taskViewModel.selectedFilter == TaskFilter.yesterday,
                  onTap: () => taskViewModel.setFilter(TaskFilter.yesterday),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tasks Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getFilterTitle(taskViewModel.selectedFilter),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              TextButton(
                onPressed: () => taskViewModel.setFilter(TaskFilter.all),
                child: const Text(
                  'View all',
                  style: TextStyle(
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Tasks List
          if (taskViewModel.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (taskViewModel.filteredTasks.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: EmptyState(
                title: 'No tasks found',
                subtitle: 'Try another filter or add a task to get started.',
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: taskViewModel.filteredTasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = taskViewModel.filteredTasks[index];
                return TaskCard(
                  title: task.title,
                  description: task.description,
                  date: task.scheduledDate,
                  isCompleted: task.isCompleted,
                  onEdit: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddEditTaskScreen(task: task),
                      ),
                    );
                  },
                  onDelete: () => taskViewModel.deleteTask(task.id),
                  onMarkComplete: () => taskViewModel.toggleTask(task),
                );
              },
            ),

          const SizedBox(height: 20),

          // Add New Task Button
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: FilledButton.icon(
              onPressed: () => _openAddTaskSheet(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add New Task'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksBody(TaskViewModel taskViewModel, ThemeData theme) {
    final filteredTasks = taskViewModel.filteredTasks;
    final count = filteredTasks.length;

    return RefreshIndicator(
      onRefresh: taskViewModel.loadTasks,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Horizontal Filter Chips Tab Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTaskTabChip(
                  context,
                  label: 'All',
                  filter: TaskFilter.all,
                  isActive: taskViewModel.selectedFilter == TaskFilter.all,
                  onTap: () => taskViewModel.setFilter(TaskFilter.all),
                ),
                const SizedBox(width: 8),
                _buildTaskTabChip(
                  context,
                  label: 'Today',
                  filter: TaskFilter.today,
                  isActive: taskViewModel.selectedFilter == TaskFilter.today,
                  onTap: () => taskViewModel.setFilter(TaskFilter.today),
                ),
                const SizedBox(width: 8),
                _buildTaskTabChip(
                  context,
                  label: 'Upcoming',
                  filter: TaskFilter.future,
                  isActive: taskViewModel.selectedFilter == TaskFilter.future,
                  onTap: () => taskViewModel.setFilter(TaskFilter.future),
                ),
                const SizedBox(width: 8),
                _buildTaskTabChip(
                  context,
                  label: 'Completed',
                  filter: TaskFilter.completed,
                  isActive:
                      taskViewModel.selectedFilter == TaskFilter.completed,
                  onTap: () => taskViewModel.setFilter(TaskFilter.completed),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Subtitle showing task count
          Text(
            count == 1 ? '1 Task' : '$count Tasks',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),

          // Tasks List
          if (taskViewModel.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (filteredTasks.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: EmptyState(
                title: 'No tasks found',
                subtitle: 'Try another filter or add a task to get started.',
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredTasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return TaskCard(
                  title: task.title,
                  description: task.description,
                  date: task.scheduledDate,
                  isCompleted: task.isCompleted,
                  onEdit: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddEditTaskScreen(task: task),
                      ),
                    );
                  },
                  onDelete: () => taskViewModel.deleteTask(task.id),
                  onMarkComplete: () => taskViewModel.toggleTask(task),
                );
              },
            ),
          const SizedBox(height: 80), // bottom margin spacing
        ],
      ),
    );
  }

  Widget _buildTaskTabChip(
    BuildContext context, {
    required String label,
    required TaskFilter filter,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF6366F1)
              : (theme.brightness == Brightness.light
                    ? const Color(0xFFF1F5F9)
                    : const Color(0xFF1E293B)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? const Color(0xFF6366F1)
                : (theme.brightness == Brightness.light
                      ? Colors.grey.shade200
                      : Colors.grey.shade800),
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : (theme.brightness == Brightness.light
                      ? Colors.grey.shade600
                      : Colors.grey.shade400),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderBody() {
    String name = 'Screen';
    if (_currentIndex == 2) name = 'Calendar';
    if (_currentIndex == 3) name = 'Focus';
    if (_currentIndex == 4) name = 'Profile';

    return Center(
      child: Text(
        '$name Screen Coming Soon!',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, TaskViewModel taskViewModel) {
    final theme = Theme.of(context);
    final totalTasksToday = taskViewModel.totalTasksToday;
    final completedTasksToday = taskViewModel.completedTasksToday;
    final progress = totalTasksToday > 0
        ? completedTasksToday / totalTasksToday
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: theme.brightness == Brightness.light
            ? const LinearGradient(
                colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.brightness == Brightness.light
              ? const Color(0xFFE2E8F0)
              : const Color(0xFF334155),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.light
                  ? Colors.white
                  : const Color(0xFF0F172A),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 58,
                  height: 58,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5,
                    backgroundColor: theme.brightness == Brightness.light
                        ? const Color(0xFFF1F5F9)
                        : const Color(0xFF1E293B),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF6366F1),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$completedTasksToday',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.brightness == Brightness.light
                            ? const Color(0xFF0F172A)
                            : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'of $totalTasksToday',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep going! 🎉',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: theme.brightness == Brightness.light
                        ? const Color(0xFF1E1B4B)
                        : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "You're making great progress today.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.brightness == Brightness.light
                        ? const Color(0xFF4338CA).withValues(alpha: 0.85)
                        : Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String label,
    required String count,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.light
              ? Colors.white
              : AppColors.darkCardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? const Color(0xFF6366F1)
                : (theme.brightness == Brightness.light
                      ? Colors.grey.shade100
                      : Colors.grey.shade800),
            width: isActive ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.light
                    ? iconBgColor
                    : iconBgColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? Colors.white
            : AppColors.darkCardBackground,
        border: Border(
          top: BorderSide(
            color: theme.brightness == Brightness.light
                ? Colors.grey.shade100
                : Colors.grey.shade800,
            width: 1.0,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavBarItem(context, Icons.home_rounded, 'Home', 0),
            _buildNavBarItem(context, Icons.assignment_outlined, 'Tasks', 1),
            _buildNavBarItem(
              context,
              Icons.calendar_month_outlined,
              'Calendar',
              2,
            ),
            _buildNavBarItem(context, Icons.radar_rounded, 'Focus', 3),
            _buildNavBarItem(
              context,
              Icons.person_outline_rounded,
              'Profile',
              4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    final theme = Theme.of(context);
    final isActive = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (index == 4) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            return;
          }

          setState(() {
            _currentIndex = index;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? const Color(0xFF6366F1)
                  : (theme.brightness == Brightness.light
                        ? Colors.grey.shade400
                        : Colors.grey.shade600),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF6366F1)
                    : (theme.brightness == Brightness.light
                          ? Colors.grey.shade500
                          : Colors.grey.shade500),
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeViewModel = context.watch<ThemeViewModel>();
    final theme = Theme.of(context);

    return Consumer<TaskViewModel>(
      builder: (context, taskViewModel, _) {
        return Scaffold(
          appBar: _buildAppBar(themeViewModel, theme),
          bottomNavigationBar: _buildBottomNavBar(context),
          floatingActionButton: _buildFAB(),
          body: SafeArea(child: _buildBody(taskViewModel, theme)),
        );
      },
    );
  }
}
