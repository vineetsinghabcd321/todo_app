// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:hive/hive.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app/main.dart';
import 'package:todo_app/models/task_item.dart';
import 'package:todo_app/services/hive_service.dart';

void main() {
  setUpAll(() async {
    Hive.init((await Directory.systemTemp.createTemp('todo_app_test')).path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskItemAdapter());
    }
    await Hive.openBox<TaskItem>(HiveService.taskBoxName);
    await Hive.openBox<String>(HiveService.themeBoxName);
  });

  testWidgets('renders the todo app shell', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Todo Planner'), findsOneWidget);
  });
}
