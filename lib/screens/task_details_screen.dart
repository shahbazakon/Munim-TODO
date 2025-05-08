import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/task_controller.dart';
import '../models/task_model.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Task? task;

  const TaskDetailsScreen({super.key, this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late TaskPriority _priority;
  final _taskController = Get.find<TaskController>();
  final _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _priority = widget.task!.priority;
    } else {
      _priority = TaskPriority.medium;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    final canEdit = _authController.canEditTask();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          if (isEditing && _authController.canDeleteTask())
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Task'),
                    content: const Text(
                        'Are you sure you want to delete this task?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          _taskController.deleteTask(widget.task!.id);
                          Navigator.pop(context);
                          Get.back();
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task status and creation info card
                  if (isEditing)
                    Card(
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  widget.task!.status == TaskStatus.todo
                                      ? Icons.pending
                                      : widget.task!.status ==
                                              TaskStatus.inProgress
                                          ? Icons.sync
                                          : Icons.check_circle,
                                  color: widget.task!.status == TaskStatus.todo
                                      ? Colors.orange
                                      : widget.task!.status ==
                                              TaskStatus.inProgress
                                          ? Colors.blue
                                          : Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Status: ${widget.task!.status == TaskStatus.todo ? 'To Do' : widget.task!.status == TaskStatus.inProgress ? 'In Progress' : 'Done'}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                Icon(
                                  _getPriorityIcon(),
                                  color: _getPriorityColor(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Created by: ${widget.task!.createdBy}'),
                            const SizedBox(height: 4),
                            Text(
                                'Date: ${_getFormattedDate(widget.task!.createdAt)}'),
                            if (!widget.task!.synced) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.sync_problem,
                                      color: Colors.orange.shade800, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Not synced',
                                    style: TextStyle(
                                      color: Colors.orange.shade800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                  // Title field
                  const Text(
                    'Title',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Enter task title',
                      border: OutlineInputBorder(),
                    ),
                    enabled: canEdit,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Description field
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Enter task description',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    enabled: canEdit,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Priority field
                  const Text(
                    'Priority',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<TaskPriority>(
                    value: _priority,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    onChanged: canEdit
                        ? (value) {
                            if (value != null) {
                              setState(() {
                                _priority = value;
                              });
                            }
                          }
                        : null,
                    items: TaskPriority.values.map((priority) {
                      String label;
                      IconData icon;
                      Color color;

                      switch (priority) {
                        case TaskPriority.low:
                          label = 'Low';
                          icon = Icons.arrow_downward;
                          color = Colors.green;
                          break;
                        case TaskPriority.medium:
                          label = 'Medium';
                          icon = Icons.remove;
                          color = Colors.orange;
                          break;
                        case TaskPriority.high:
                          label = 'High';
                          icon = Icons.arrow_upward;
                          color = Colors.red;
                          break;
                      }

                      return DropdownMenuItem(
                        value: priority,
                        child: Row(
                          children: [
                            Icon(icon, color: color, size: 18),
                            const SizedBox(width: 8),
                            Text(label),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  if (canEdit)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          isEditing ? 'Update Task' : 'Create Task',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getPriorityIcon() {
    switch (widget.task!.priority) {
      case TaskPriority.low:
        return Icons.arrow_downward;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.arrow_upward;
    }
  }

  Color _getPriorityColor() {
    switch (widget.task!.priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }

  String _getFormattedDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (widget.task != null) {
        // Update existing task
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          priority: _priority,
        );
        _taskController.updateTask(updatedTask);
      } else {
        // Create new task
        _taskController.createTask(
          title: _titleController.text,
          description: _descriptionController.text,
          priority: _priority,
        );
      }
      Get.back();
    }
  }
}
