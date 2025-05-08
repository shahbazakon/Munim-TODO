import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

class HiveService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // Register adapters only if not already registered
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UserAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(UserRoleAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TaskAdapter());
    if (!Hive.isAdapterRegistered(3))
      Hive.registerAdapter(TaskPriorityAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(TaskStatusAdapter());

    // Open boxes
    await Hive.openBox<User>('users');
    await Hive.openBox<Task>('tasks');

    _initialized = true;
  }

  // User operations
  static Box<User> get usersBox => Hive.box<User>('users');

  static Future<void> saveUser(User user) async {
    await usersBox.put(user.id, user);
  }

  static User? getUser(String id) {
    return usersBox.get(id);
  }

  static User? getUserByUsername(String username) {
    try {
      return usersBox.values.firstWhere(
        (user) => user.username == username,
      );
    } catch (e) {
      return null;
    }
  }

  static List<User> getAllUsers() {
    return usersBox.values.toList();
  }

  // Task operations
  static Box<Task> get tasksBox => Hive.box<Task>('tasks');

  static Future<void> saveTask(Task task) async {
    await tasksBox.put(task.id, task);
  }

  static Task? getTask(String id) {
    return tasksBox.get(id);
  }

  static List<Task> getAllTasks() {
    return tasksBox.values.toList();
  }

  static List<Task> getTasksByStatus(TaskStatus status) {
    return tasksBox.values.where((task) => task.status == status).toList();
  }

  static Future<void> deleteTask(String id) async {
    await tasksBox.delete(id);
  }

  static Future<void> markTasksAsSynced() async {
    for (var task in tasksBox.values) {
      if (!task.synced) {
        final updatedTask = task.copyWith(synced: true);
        await tasksBox.put(task.id, updatedTask);
      }
    }
  }
}
