import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/date_utils.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.title,
    required this.date,
    required this.isCompleted,
    required this.onEdit,
    required this.onDelete,
    required this.onMarkComplete,
    this.description,
  });

  final String title;
  final String? description;
  final DateTime date;
  final bool isCompleted;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMarkComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCompleted
              ? colorScheme.primary.withValues(alpha: 0.15)
              : colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Circular Checkbox on the Left
                  GestureDetector(
                    onTap: onMarkComplete,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted
                              ? AppColors.primary
                              : (theme.brightness == Brightness.light
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade600),
                          width: 2.0,
                        ),
                        color: isCompleted ? AppColors.primary : Colors.transparent,
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Task Details in the Middle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isCompleted
                                ? (theme.brightness == Brightness.light
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600)
                                : colorScheme.onSurface,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // Pending/Completed Status Chip
                            _StatusChip(
                              label: isCompleted ? 'Completed' : 'Pending',
                              background: isCompleted
                                  ? (theme.brightness == Brightness.light
                                      ? AppColors.successBgLight
                                      : AppColors.successBgDark)
                                  : (theme.brightness == Brightness.light
                                      ? const Color(0xFFEEF2FF) // Lavender background
                                      : const Color(0xFF312E81)), // Dark indigo background
                              foreground: isCompleted
                                  ? (theme.brightness == Brightness.light
                                      ? AppColors.successFgLight
                                      : AppColors.successFgDark)
                                  : (theme.brightness == Brightness.light
                                      ? const Color(0xFF6366F1) // Purple/Indigo text
                                      : const Color(0xFFC7D2FE)),
                            ),
                            const SizedBox(width: 12),
                            // Date details
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateUtilsHelper.formatDateKey(date).split(' ').take(2).join(' '), // E.g., '07 Jun'
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Action Menu on the Right
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                    tooltip: 'Task options',
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                        case 'toggle':
                          onMarkComplete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20),
                            SizedBox(width: 12),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              isCompleted
                                  ? Icons.refresh_rounded
                                  : Icons.check_circle_outline_rounded,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(isCompleted ? 'Mark Pending' : 'Mark Complete'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (description != null && description!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 38.0),
                  child: Text(
                    description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      height: 1.3,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
