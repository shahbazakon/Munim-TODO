import 'package:hive/hive.dart';

// Replace the part declaration with manual adapter implementation
// part 'task_model.g.dart';

enum TaskPriority {
  low,
  medium,
  high,
}

enum TaskStatus {
  todo,
  inProgress,
  done,
}

class Task {
  final String id;
  String title;
  String description;
  TaskPriority priority;
  TaskStatus status;
  final String createdBy;
  bool synced;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdBy,
    this.synced = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    bool? synced,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdBy: createdBy,
      synced: synced ?? this.synced,
      createdAt: createdAt,
    );
  }
}

// Manual implementation of Hive adapters
class TaskAdapter extends TypeAdapter<Task> {
  @override
  final typeId = 2;

  @override
  Task read(BinaryReader reader) {
    return Task(
      id: reader.read(),
      title: reader.read(),
      description: reader.read(),
      priority: TaskPriorityAdapter().read(reader),
      status: TaskStatusAdapter().read(reader),
      createdBy: reader.read(),
      synced: reader.read(),
      createdAt: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.write(obj.id);
    writer.write(obj.title);
    writer.write(obj.description);
    TaskPriorityAdapter().write(writer, obj.priority);
    TaskStatusAdapter().write(writer, obj.status);
    writer.write(obj.createdBy);
    writer.write(obj.synced);
    writer.write(obj.createdAt);
  }
}

class TaskPriorityAdapter extends TypeAdapter<TaskPriority> {
  @override
  final typeId = 3;

  @override
  TaskPriority read(BinaryReader reader) {
    return TaskPriority.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, TaskPriority obj) {
    writer.writeByte(obj.index);
  }
}

class TaskStatusAdapter extends TypeAdapter<TaskStatus> {
  @override
  final typeId = 4;

  @override
  TaskStatus read(BinaryReader reader) {
    return TaskStatus.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, TaskStatus obj) {
    writer.writeByte(obj.index);
  }
}
