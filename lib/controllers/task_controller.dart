import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../services/hive_service.dart';
import 'auth_controller.dart';

class TaskController extends GetxController {
  final _authController = Get.find<AuthController>();
  final _uuid = Uuid();

  final RxList<Task> tasks = <Task>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  void loadTasks() {
    tasks.value = HiveService.getAllTasks();
  }

  Future<void> createTask({
    required String title,
    required String description,
    required TaskPriority priority,
  }) async {
    if (!_authController.canCreateTask()) return;

    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      priority: priority,
      status: TaskStatus.todo,
      createdBy: _authController.currentUser!.username,
    );

    await HiveService.saveTask(task);
    tasks.add(task);
  }

  Future<void> updateTask(Task task) async {
    if (!_authController.canEditTask()) return;

    await HiveService.saveTask(task);
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
    }
  }

  Future<void> deleteTask(String taskId) async {
    if (!_authController.canDeleteTask()) return;

    await HiveService.deleteTask(taskId);
    tasks.removeWhere((task) => task.id == taskId);
  }

  Future<void> moveTask(Task task, TaskStatus newStatus) async {
    if (!_authController.canMoveTask()) return;

    final updatedTask = task.copyWith(
      status: newStatus,
      synced: false,
    );
    await updateTask(updatedTask);
  }

  Future<void> syncTasks() async {
    if (!_authController.canSync()) return;

    isLoading.value = true;
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      await HiveService.markTasksAsSynced();
      loadTasks();
    } finally {
      isLoading.value = false;
    }
  }

  List<Task> getTasksByStatus(TaskStatus status) {
    return tasks.where((task) => task.status == status).toList();
  }

  bool hasUnsyncedTasks() {
    return tasks.any((task) => !task.synced);
  }
}
