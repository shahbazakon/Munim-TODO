import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../controllers/auth_controller.dart';
import '../controllers/task_controller.dart';
import '../models/task_model.dart';
import 'task_details_screen.dart';
import 'login_screen.dart';

class KanbanScreen extends StatelessWidget {
  const KanbanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Munim Todo'),
        actions: [
          if (authController.canSync())
            Obx(() {
              final hasUnsynced = taskController.hasUnsyncedTasks();
              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.sync),
                    if (hasUnsynced)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: taskController.syncTasks,
                tooltip: 'Sync Tasks',
              );
            }),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Account',
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 18),
                    const SizedBox(width: 8),
                    Obx(() => Text(
                          authController.currentUser?.username ?? 'User',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'role',
                child: Row(
                  children: [
                    const Icon(Icons.admin_panel_settings, size: 18),
                    const SizedBox(width: 8),
                    Obx(() => Text(
                          'Role: ${authController.currentUser?.role.toString().split('.').last ?? 'Unknown'}',
                        )),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                onTap: () {
                  authController.logout();
                  Get.offAll(() => LoginScreen());
                },
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return Obx(() {
          if (taskController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          // Use a responsive approach based on width rather than just orientation
          if (constraints.maxWidth < 600) {
            return _buildPortraitLayout(
                context, taskController, authController);
          } else {
            return _buildLandscapeLayout(
                context, taskController, authController);
          }
        });
      }),
      floatingActionButton: authController.canCreateTask()
          ? FloatingActionButton.extended(
              onPressed: () => Get.to(() => const TaskDetailsScreen()),
              label: const Text('New Task'),
              icon: const Icon(Icons.add),
              tooltip: 'Add New Task',
            )
          : null,
    );
  }

  Widget _buildPortraitLayout(BuildContext context,
      TaskController taskController, AuthController authController) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Custom TabBar with status indicators
          Material(
            color: Colors.grey.shade100,
            child: TabBar(
              isScrollable: false,
              tabAlignment: TabAlignment.fill,
              tabs: [
                _buildSimpleTab(
                  'To Do',
                  Icons.pending,
                  Colors.orange,
                  taskController.getTasksByStatus(TaskStatus.todo).length,
                ),
                _buildSimpleTab(
                  'In Progress',
                  Icons.sync,
                  Colors.blue,
                  taskController.getTasksByStatus(TaskStatus.inProgress).length,
                ),
                _buildSimpleTab(
                  'Done',
                  Icons.check_circle,
                  Colors.green,
                  taskController.getTasksByStatus(TaskStatus.done).length,
                ),
              ],
              indicatorColor: Colors.blue.shade700,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.black54,
              dividerHeight: 1,
              dividerColor: Colors.grey.shade300,
            ),
          ),

          // TabBarView with each status column
          Expanded(
            child: TabBarView(
              children: [
                _buildTabContent(
                  context,
                  TaskStatus.todo,
                  taskController.getTasksByStatus(TaskStatus.todo),
                  taskController,
                  authController,
                ),
                _buildTabContent(
                  context,
                  TaskStatus.inProgress,
                  taskController.getTasksByStatus(TaskStatus.inProgress),
                  taskController,
                  authController,
                ),
                _buildTabContent(
                  context,
                  TaskStatus.done,
                  taskController.getTasksByStatus(TaskStatus.done),
                  taskController,
                  authController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context,
      TaskController taskController, AuthController authController) {
    return Row(
      children: [
        Expanded(
          child: _buildStatusColumn(
            context,
            'To Do',
            TaskStatus.todo,
            taskController.getTasksByStatus(TaskStatus.todo),
            taskController,
            authController,
          ),
        ),
        Expanded(
          child: _buildStatusColumn(
            context,
            'In Progress',
            TaskStatus.inProgress,
            taskController.getTasksByStatus(TaskStatus.inProgress),
            taskController,
            authController,
          ),
        ),
        Expanded(
          child: _buildStatusColumn(
            context,
            'Done',
            TaskStatus.done,
            taskController.getTasksByStatus(TaskStatus.done),
            taskController,
            authController,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleTab(String title, IconData icon, Color color, int count) {
    return Tab(
      height: 56,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                title.split(' ').first,
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    TaskStatus status,
    List<Task> tasks,
    TaskController taskController,
    AuthController authController,
  ) {
    return Container(
      color: status == TaskStatus.todo
          ? Colors.orange.shade50.withOpacity(0.3)
          : status == TaskStatus.inProgress
              ? Colors.blue.shade50.withOpacity(0.3)
              : Colors.green.shade50.withOpacity(0.3),
      child: DragTarget<Task>(
        onWillAccept: (task) => task != null && authController.canMoveTask(),
        onAccept: (task) {
          taskController.moveTask(task, status);
          _showStatusChangeSnackbar(context, task, status);
        },
        builder: (context, candidateTasks, rejectedTasks) {
          return tasks.isEmpty
              ? _buildEmptyStateForStatus(
                  context, status, taskController, authController)
              : _buildTaskList(
                  tasks, context, status, taskController, authController);
        },
      ),
    );
  }

  Widget _buildEmptyStateForStatus(
    BuildContext context,
    TaskStatus status,
    TaskController taskController,
    AuthController authController,
  ) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                status == TaskStatus.todo
                    ? Icons.add_task
                    : status == TaskStatus.inProgress
                        ? Icons.hourglass_empty
                        : Icons.task_alt,
                size: 64,
                color: status == TaskStatus.todo
                    ? Colors.orange.shade300
                    : status == TaskStatus.inProgress
                        ? Colors.blue.shade300
                        : Colors.green.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                status == TaskStatus.todo
                    ? 'No tasks to do'
                    : status == TaskStatus.inProgress
                        ? 'No tasks in progress'
                        : 'No completed tasks',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                status == TaskStatus.todo
                    ? 'Create a new task or drag existing tasks here'
                    : status == TaskStatus.inProgress
                        ? 'Drag tasks here to mark them as in progress'
                        : 'Drag tasks here to mark them as completed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              if (status == TaskStatus.todo && authController.canCreateTask())
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: ElevatedButton.icon(
                    onPressed: () => Get.to(() => const TaskDetailsScreen()),
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Task'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(
    List<Task> tasks,
    BuildContext context,
    TaskStatus status,
    TaskController taskController,
    AuthController authController,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        if (!authController.canMoveTask()) {
          return _TaskCard(
            task: task,
            onTap: () => Get.to(() => TaskDetailsScreen(task: task)),
          );
        }

        return _buildSlidableTaskCard(
            context, task, status, taskController, authController);
      },
    );
  }

  Widget _buildSlidableTaskCard(
    BuildContext context,
    Task task,
    TaskStatus currentStatus,
    TaskController taskController,
    AuthController authController,
  ) {
    // Determine available actions based on current status
    final TaskStatus? leftActionStatus = currentStatus == TaskStatus.inProgress
        ? TaskStatus.todo
        : currentStatus == TaskStatus.done
            ? TaskStatus.inProgress
            : null;

    final TaskStatus? rightActionStatus = currentStatus == TaskStatus.todo
        ? TaskStatus.inProgress
        : currentStatus == TaskStatus.inProgress
            ? TaskStatus.done
            : null;

    // Action labels and colors
    final leftActionLabel = leftActionStatus == TaskStatus.todo
        ? 'Move to To Do'
        : 'Move to In Progress';

    final rightActionLabel = rightActionStatus == TaskStatus.inProgress
        ? 'Start Working'
        : 'Mark Complete';

    final leftActionColor =
        leftActionStatus == TaskStatus.todo ? Colors.orange : Colors.blue;

    final rightActionColor =
        rightActionStatus == TaskStatus.inProgress ? Colors.blue : Colors.green;

    final leftActionIcon = leftActionStatus == TaskStatus.todo
        ? Icons.assignment_return
        : Icons.time_to_leave;

    final rightActionIcon = rightActionStatus == TaskStatus.inProgress
        ? Icons.play_arrow
        : Icons.check;

    return Slidable(
      key: ValueKey(task.id),

      // Left action - move back in workflow
      startActionPane: leftActionStatus != null
          ? ActionPane(
              motion: const DrawerMotion(),
              dismissible: DismissiblePane(
                onDismissed: () {
                  taskController.moveTask(task, leftActionStatus);
                  _showStatusChangeSnackbar(context, task, leftActionStatus);
                },
              ),
              children: [
                SlidableAction(
                  onPressed: (_) {
                    taskController.moveTask(task, leftActionStatus);
                    _showStatusChangeSnackbar(context, task, leftActionStatus);
                  },
                  backgroundColor: leftActionColor,
                  foregroundColor: Colors.white,
                  icon: leftActionIcon,
                  label: leftActionLabel,
                ),
              ],
            )
          : null,

      // Right action - move forward in workflow
      endActionPane: rightActionStatus != null
          ? ActionPane(
              motion: const DrawerMotion(),
              dismissible: DismissiblePane(
                onDismissed: () {
                  taskController.moveTask(task, rightActionStatus);
                  _showStatusChangeSnackbar(context, task, rightActionStatus);
                },
              ),
              children: [
                SlidableAction(
                  onPressed: (_) {
                    taskController.moveTask(task, rightActionStatus);
                    _showStatusChangeSnackbar(context, task, rightActionStatus);
                  },
                  backgroundColor: rightActionColor,
                  foregroundColor: Colors.white,
                  icon: rightActionIcon,
                  label: rightActionLabel,
                ),
              ],
            )
          : null,

      // The actual task card
      child: Draggable<Task>(
        data: task,
        feedback: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _TaskCard(task: task),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.5,
          child: _TaskCard(task: task),
        ),
        child: Stack(
          children: [
            _TaskCard(
              task: task,
              onTap: () => Get.to(() => TaskDetailsScreen(task: task)),
            ),
            if (rightActionStatus != null)
              Positioned(
                top: 8,
                right: 8,
                child: Tooltip(
                  message: rightActionLabel,
                  child: InkWell(
                    onTap: () {
                      taskController.moveTask(task, rightActionStatus);
                      _showStatusChangeSnackbar(
                          context, task, rightActionStatus);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: rightActionColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: rightActionColor, width: 1),
                      ),
                      child: Icon(
                        rightActionIcon,
                        color: rightActionColor,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showStatusChangeSnackbar(
      BuildContext context, Task task, TaskStatus newStatus) {
    String statusText;
    Color backgroundColor;
    IconData iconData;

    switch (newStatus) {
      case TaskStatus.todo:
        statusText = 'To Do';
        backgroundColor = Colors.orange;
        iconData = Icons.assignment_return;
        break;
      case TaskStatus.inProgress:
        statusText = 'In Progress';
        backgroundColor = Colors.blue;
        iconData = Icons.play_arrow;
        break;
      case TaskStatus.done:
        statusText = 'Done';
        backgroundColor = Colors.green;
        iconData = Icons.check_circle;
        break;
    }

    Get.snackbar(
      'Task Status Updated',
      '"${task.title}" moved to $statusText',
      icon: Icon(iconData, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(8),
      duration: const Duration(seconds: 2),
    );
  }

  Widget _buildStatusColumn(
    BuildContext context,
    String title,
    TaskStatus status,
    List<Task> tasks,
    TaskController taskController,
    AuthController authController,
  ) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: status == TaskStatus.todo
              ? Colors.orange.shade300
              : status == TaskStatus.inProgress
                  ? Colors.blue.shade300
                  : Colors.green.shade300,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: status == TaskStatus.todo
                  ? Colors.orange.shade50
                  : status == TaskStatus.inProgress
                      ? Colors.blue.shade50
                      : Colors.green.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == TaskStatus.todo
                      ? Icons.pending
                      : status == TaskStatus.inProgress
                          ? Icons.sync
                          : Icons.check_circle,
                  color: status == TaskStatus.todo
                      ? Colors.orange
                      : status == TaskStatus.inProgress
                          ? Colors.blue
                          : Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: status == TaskStatus.todo
                            ? Colors.orange.shade800
                            : status == TaskStatus.inProgress
                                ? Colors.blue.shade800
                                : Colors.green.shade800,
                      ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: TextStyle(
                      color: status == TaskStatus.todo
                          ? Colors.orange.shade800
                          : status == TaskStatus.inProgress
                              ? Colors.blue.shade800
                              : Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: DragTarget<Task>(
              onWillAccept: (task) =>
                  task != null && authController.canMoveTask(),
              onAccept: (task) {
                taskController.moveTask(task, status);
                _showStatusChangeSnackbar(context, task, status);
              },
              builder: (context, candidateTasks, rejectedTasks) {
                return tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              status == TaskStatus.todo
                                  ? Icons.add_task
                                  : status == TaskStatus.inProgress
                                      ? Icons.hourglass_empty
                                      : Icons.task_alt,
                              size: 48,
                              color: status == TaskStatus.todo
                                  ? Colors.orange.shade300
                                  : status == TaskStatus.inProgress
                                      ? Colors.blue.shade300
                                      : Colors.green.shade300,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              status == TaskStatus.todo
                                  ? 'No tasks to do'
                                  : status == TaskStatus.inProgress
                                      ? 'No tasks in progress'
                                      : 'No completed tasks',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];

                          if (!authController.canMoveTask()) {
                            return Draggable<Task>(
                              data: task,
                              feedback: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _TaskCard(task: task),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.5,
                                child: _TaskCard(task: task),
                              ),
                              child: _TaskCard(
                                task: task,
                                onTap: () =>
                                    Get.to(() => TaskDetailsScreen(task: task)),
                              ),
                            );
                          }

                          return _buildSlidableTaskCard(context, task, status,
                              taskController, authController);
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  // The original build tab with more details - keep for reference
  Widget _buildTab(String title, IconData icon, Color color, int count) {
    return Tab(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const _TaskCard({
    required this.task,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: _getPriorityBorderColor(),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    if (!task.synced)
                      Tooltip(
                        message: 'Not synced',
                        child: const Icon(
                          Icons.sync_problem,
                          color: Colors.orange,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _PriorityChip(priority: task.priority),
                    const Spacer(),
                    Text(
                      'By: ${task.createdBy}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityBorderColor() {
    switch (task.priority) {
      case TaskPriority.low:
        return Colors.green.shade200;
      case TaskPriority.medium:
        return Colors.orange.shade200;
      case TaskPriority.high:
        return Colors.red.shade200;
    }
  }
}

class _PriorityChip extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (priority) {
      case TaskPriority.low:
        color = Colors.green;
        label = 'Low';
        icon = Icons.arrow_downward;
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        label = 'Medium';
        icon = Icons.remove;
        break;
      case TaskPriority.high:
        color = Colors.red;
        label = 'High';
        icon = Icons.arrow_upward;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
