import '../models/task_item.dart';
import '../services/hive_service.dart';

class TaskRepository {
  TaskRepository({HiveService? hiveService})
    : _hiveService = hiveService ?? HiveService.instance;

  final HiveService _hiveService;

  Future<List<TaskItem>> fetchTasks() async {
    await _hiveService.openTaskBox();
    return _hiveService.getAllTasks();
  }

  List<TaskItem> getAllTasks() {
    return _hiveService.getAllTasks();
  }

  Future<void> addTask(TaskItem task) async {
    await _hiveService.addTask(task);
  }

  Future<void> updateTask(TaskItem task) async {
    await _hiveService.updateTask(task);
  }

  Future<void> deleteTask(String taskId) async {
    await _hiveService.deleteTask(taskId);
  }

  Future<void> clearCompletedTasks() async {
    final completedTaskIds = _hiveService
        .getAllTasks()
        .where((task) => task.isCompleted)
        .map((task) => task.id)
        .toList();
    for (final taskId in completedTaskIds) {
      await _hiveService.deleteTask(taskId);
    }
  }
}
