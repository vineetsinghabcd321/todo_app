import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/task_item.dart';

class HiveService {
  HiveService._internal();

  static final HiveService instance = HiveService._internal();

  static const String taskBoxName = 'task_box';
  static const String themeBoxName = 'theme_box';
  static const String _themeKey = 'theme_mode';

  Future<void>? _initializeFuture;

  static Future<void> initialize() => instance._initialize();

  Future<void> _initialize() {
    _initializeFuture ??= _bootstrap();
    return _initializeFuture!;
  }

  Future<void> _bootstrap() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskItemAdapter());
    }

    if (!Hive.isBoxOpen(taskBoxName)) {
      await Hive.openBox<TaskItem>(taskBoxName);
    }

    if (!Hive.isBoxOpen(themeBoxName)) {
      await Hive.openBox<String>(themeBoxName);
    }
  }

  Box<TaskItem> get _taskBox => Hive.box<TaskItem>(taskBoxName);

  Box<String> get _themeBox => Hive.box<String>(themeBoxName);

  Future<Box<TaskItem>> openTaskBox() async {
    await _initialize();
    return _taskBox;
  }

  Future<Box<String>> openThemeBox() async {
    await _initialize();
    return _themeBox;
  }

  Future<void> addTask(TaskItem task) async {
    await _initialize();
    await _taskBox.put(task.id, task);
  }

  Future<void> updateTask(TaskItem task) async {
    await _initialize();
    await _taskBox.put(task.id, task);
  }

  Future<void> deleteTask(String taskId) async {
    await _initialize();
    await _taskBox.delete(taskId);
  }

  List<TaskItem> getAllTasks() {
    if (!Hive.isBoxOpen(taskBoxName)) {
      return const [];
    }

    final tasks = _taskBox.values.toList();
    tasks.sort((left, right) {
      final scheduledDateComparison = right.scheduledDate.compareTo(
        left.scheduledDate,
      );
      if (scheduledDateComparison != 0) {
        return scheduledDateComparison;
      }

      return right.createdAt.compareTo(left.createdAt);
    });
    return tasks;
  }

  Future<void> saveTheme(ThemeMode themeMode) async {
    await _initialize();
    await _themeBox.put(_themeKey, themeMode.name);
  }

  ThemeMode getSavedTheme() {
    if (!Hive.isBoxOpen(themeBoxName)) {
      return ThemeMode.system;
    }

    final savedThemeName = _themeBox.get(_themeKey) ?? ThemeMode.system.name;

    return ThemeMode.values.firstWhere(
      (themeMode) => themeMode.name == savedThemeName,
      orElse: () => ThemeMode.system,
    );
  }
}
