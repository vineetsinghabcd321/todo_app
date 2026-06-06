import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'models/task_item.dart';
import 'repositories/task_repository.dart';
import 'services/hive_service.dart';
import 'utils/app_theme.dart';
import 'viewmodels/task_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'views/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TaskItemAdapter());
  }

  await HiveService.initialize();

  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TaskRepository>(create: (_) => TaskRepository()),
        ChangeNotifierProvider<ThemeViewModel>(
          create: (_) => ThemeViewModel()..loadTheme(),
        ),
        ChangeNotifierProvider<TaskViewModel>(
          create: (context) =>
              TaskViewModel(repository: context.read<TaskRepository>())
                ..loadTasks(),
        ),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, _) {
          return MaterialApp(
            title: 'Todo App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeViewModel.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
