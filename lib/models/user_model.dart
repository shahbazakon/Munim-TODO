import 'package:hive/hive.dart';

// Replace the part declaration with manual adapter implementation
// part 'user_model.g.dart';

enum UserRole {
  admin,
  editor,
  viewer,
}

class User {
  final String id;
  final String username;
  final String password;
  final UserRole role;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isEditor => role == UserRole.editor;
  bool get isViewer => role == UserRole.viewer;

  bool canEditTask() => isAdmin || isEditor;
  bool canCreateTask() => isAdmin || isEditor;
  bool canDeleteTask() => isAdmin;
  bool canMoveTask() => isAdmin || isEditor;
  bool canSync() => isAdmin || isEditor;
}

// Manual implementation of Hive adapters
class UserAdapter extends TypeAdapter<User> {
  @override
  final typeId = 0;

  @override
  User read(BinaryReader reader) {
    return User(
      id: reader.read(),
      username: reader.read(),
      password: reader.read(),
      role: UserRoleAdapter().read(reader),
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.write(obj.id);
    writer.write(obj.username);
    writer.write(obj.password);
    UserRoleAdapter().write(writer, obj.role);
  }
}

class UserRoleAdapter extends TypeAdapter<UserRole> {
  @override
  final typeId = 1;

  @override
  UserRole read(BinaryReader reader) {
    return UserRole.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, UserRole obj) {
    writer.writeByte(obj.index);
  }
}
