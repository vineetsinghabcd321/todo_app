import 'package:flutter/material.dart';

import '../models/task_item.dart';
import '../repositories/task_repository.dart';
import '../utils/date_utils.dart';

enum TaskFilter { all, yesterday, today, future, completed, pending }

class TaskViewModel extends ChangeNotifier {
  TaskViewModel({required TaskRepository repository})
    : _repository = repository;

  final TaskRepository _repository;

  List<TaskItem> _tasks = [];
  bool _isLoading = false;
  TaskFilter _selectedFilter = TaskFilter.all;

  List<TaskItem> get tasks => filteredTasks;
  List<TaskItem> get allTasks => List.unmodifiable(_tasks);
  List<TaskItem> get filteredTasks => List.unmodifiable(_applyFilter(_tasks));
  bool get isLoading => _isLoading;
  TaskFilter get selectedFilter => _selectedFilter;

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((task) => task.isCompleted).length;

  int get todayTasksCount => _tasks
      .where((task) => DateUtilsHelper.isToday(task.scheduledDate))
      .length;

  int get upcomingTasksCount => _tasks
      .where(
        (task) =>
            DateUtilsHelper.isAfterToday(task.scheduledDate) &&
            !task.isCompleted,
      )
      .length;

  int get completedTasksCount => completedTasks;

  int get overdueTasksCount => _tasks
      .where(
        (task) =>
            !task.isCompleted &&
            DateUtilsHelper.isBeforeToday(task.scheduledDate),
      )
      .length;

  int get totalTasksToday => _tasks
      .where((task) => DateUtilsHelper.isToday(task.scheduledDate))
      .length;

  int get completedTasksToday => _tasks
      .where(
        (task) =>
            task.isCompleted && DateUtilsHelper.isToday(task.scheduledDate),
      )
      .length;

  void setFilter(TaskFilter filter) {
    if (_selectedFilter == filter) {
      return;
    }

    _selectedFilter = filter;
    notifyListeners();
  }

  Map<DateTime, List<TaskItem>> get groupedTasks {
    final Map<DateTime, List<TaskItem>> grouped = {};
    for (final task in filteredTasks) {
      final key = DateUtilsHelper.normalize(task.scheduledDate);
      grouped.putIfAbsent(key, () => []).add(task);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((left, right) => right.compareTo(left));

    return {
      for (final key in sortedKeys)
        key: grouped[key]!
          ..sort(
            (left, right) => left.isCompleted == right.isCompleted
                ? left.createdAt.compareTo(right.createdAt)
                : left.isCompleted
                ? 1
                : -1,
          ),
    };
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    _tasks = await _repository.fetchTasks();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(
    String title,
    String description,
    DateTime scheduledDate,
  ) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return;
    }

    final task = TaskItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: trimmedTitle,
      scheduledDate: DateUtilsHelper.normalize(scheduledDate),
      createdAt: DateTime.now(),
      description: description.trim(),
    );

    await _repository.addTask(task);
    await loadTasks();
  }

  Future<void> editTask(TaskItem updatedTask) async {
    await _repository.updateTask(updatedTask);
    await loadTasks();
  }

  Future<void> toggleTask(TaskItem task) async {
    await _repository.updateTask(task.copyWith(isCompleted: !task.isCompleted));
    await loadTasks();
  }

  Future<void> deleteTask(String taskId) async {
    await _repository.deleteTask(taskId);
    await loadTasks();
  }

  Future<void> clearCompletedTasks() async {
    await _repository.clearCompletedTasks();
    await loadTasks();
  }

  List<TaskItem> _applyFilter(List<TaskItem> tasks) {
    return tasks.where((task) {
      final category = DateUtilsHelper.categorize(task.scheduledDate);

      switch (_selectedFilter) {
        case TaskFilter.all:
          return true;
        case TaskFilter.yesterday:
          return category == TaskDateCategory.yesterday;
        case TaskFilter.today:
          return category == TaskDateCategory.today;
        case TaskFilter.future:
          return category == TaskDateCategory.future && !task.isCompleted;
        case TaskFilter.completed:
          return task.isCompleted;
        case TaskFilter.pending:
          return !task.isCompleted;
      }
    }).toList();
  }
}
