# todo_app

Detailed README — Todo Application

This is a compact Flutter todo application included in the assignment workspace. It showcases common mobile UI patterns (lists, cards, empty states), Provider-based state management, and responsive layout techniques suitable for both Android and iOS devices.

Summary / Purpose

- Purpose: A small, focused todo app used to create, edit, delete, and filter tasks. It is intentionally lightweight so you can use it as a playground for layout fixes, state-management examples, and UX experiments.
- Audience: Developers learning Provider + Flutter layouts or reviewers evaluating the assignment's responsive UI patterns.

Key features

- Add / Edit tasks using a bottom sheet or dedicated screen.
- Filter tasks by preset categories: All, Today, Upcoming, Completed, Overdue.
- Pull to refresh tasks with `RefreshIndicator`.
- Compact cards (`TaskCard`) for each task with edit, delete, and toggle-complete actions.
- Light / Dark theme support via a `ThemeViewModel`.
- Responsive fixes using `LayoutBuilder`, `Wrap`, `Expanded`, and `Flexible` to avoid overflow on small screens.

Project structure (important files)

- `lib/main.dart` — app entry point; registers providers and sets the initial route.
- `lib/viewmodels/` — `TaskViewModel`, `ThemeViewModel`, and other `ChangeNotifier` classes; central place for app state and computations (counts, filters, derived lists).
- `lib/views/home/home_screen.dart` — main screen for the todo list. Contains layout helpers such as `_buildMetricCard`, `_buildProgressCard` and demonstrates responsive techniques used to ensure correct rendering on iOS and Android.
- `lib/views/task/add_edit_task_screen.dart` and `lib/views/add_task_bottom_sheet.dart` — UI for adding and editing tasks.
- `lib/widgets/task_card.dart` — reusable card widget used for rendering each task item.
- `lib/widgets/empty_state.dart` — empty-state UI used when no tasks match the current filter.
- `pubspec.yaml` — dependencies and assets declarations.

How UI & State are organized

- State: `TaskViewModel` holds the list of tasks and exposes computed properties such as `todayTasksCount`, `completedTasksCount`, `filteredTasks`, and `selectedFilter`. UI subscribes with `context.watch<TaskViewModel>()` or `Consumer<TaskViewModel>`.
- UI Composition: Screens use small `_buildX()` helper methods within the screen class instead of one monolithic build method. This improves readability and makes it easy to unit-test parts of the UI.
- Responsiveness: Avoids fixed widths where possible. For components that must share available horizontal space (metric cards), `Expanded` inside a `Row` is used. For small, wrap-able content (greeting + badge) `LayoutBuilder` + `Wrap` is used to allow line wrapping instead of overflow.

Run & develop locally

1. Install dependencies:

```bash
cd todo_app
flutter pub get
```

2. Run on an Android emulator or iOS simulator / device:

```bash
flutter run
```

3. Run tests (if any):

```bash
flutter test
```

Adding screenshots

To add screenshots to the README:

1. Create a folder `assets/screenshots/` inside `todo_app` if it doesn't exist.
2. Add your screenshots (e.g., `home.png`, `add_task.png`, `profile.png`).
3. Register them in `pubspec.yaml` if you want Flutter to bundle them, or simply reference relative paths in the README.

Example README snippet to include a screenshot:

```md
![Home Screen](assets/screenshots/home.png)
```

Suggested screenshots to capture and add

- Home screen with metric cards and tasks list
- Add / Edit task screen (bottom sheet or screen)
- Empty state view when no tasks are available
- Task card in completed state

Screenshots

The following screenshots were detected in `assets/screenshot/`. You can remove or rename any of them and update the paths below as needed.

- Home screen: ![Home Screen](assets/screenshot/Home_screen.png)
- iOS Home: ![iOS Home](assets/screenshot/IOS_home_screen.png)
- Tasks list (1): ![Tasks](assets/screenshot/Tasks_screen.png)
- Tasks list (2): ![Tasks 2](assets/screenshot/Tasks_screen_2.png)
- Add Task screen: ![Add Task](assets/screenshot/task_add_screen.png)
- Profile page: ![Profile](assets/screenshot/profile_page.png)

If you want me to, I can automatically register these paths in `pubspec.yaml` and commit a version of the README with these images embedded.

Common issues and fixes

- Overflow on small iOS screens: inspect the header/greeting row and replace fixed-width children with `Flexible` or wrap the content using `Wrap`.
- `RenderBox was not laid out` errors: caused by unbounded constraints — e.g., using `Expanded` inside a horizontally scrolling `Row`. Fix by removing conflicting `Expanded` or replacing the scroll container with a constrained `SizedBox` or `Flexible` layout.
- Null check exceptions: ensure `TaskViewModel` initializes lists and values. Avoid `!` unless you are sure a value is non-null.

Extending the app (ideas)

- Persist tasks locally using `shared_preferences`, `hive`, or `sqflite`.
- Add sorting and custom filters.
- Add task reminders (local notifications).
- Add backend sync with a REST API for multi-device sync.

Where to look for implementation details (quick pointers)

- `todo_app/lib/views/home/home_screen.dart`: layout patterns and metric cards.
- `todo_app/lib/viewmodels/task_viewmodel.dart`: filtering, derived lists, and counts.
- `todo_app/lib/widgets/task_card.dart`: composition of list items and actions.

If you'd like, I can produce a ready-to-copy README section that includes your screenshots once you add them to `assets/screenshots/`.

---

If this is good, I'll mark the README for `todo_app` as complete. Want me to add the screenshot placeholders now or generate a `CONTRIBUTING.md` next?

