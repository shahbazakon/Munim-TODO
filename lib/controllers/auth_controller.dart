import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';

class AuthController extends GetxController {
  final Rx<User?> _currentUser = Rx<User?>(null);

  User? get currentUser => _currentUser.value;
  bool get isLoggedIn => _currentUser.value != null;

  // Mock users for testing
  final List<User> _mockUsers = [
    User(
      id: '1',
      username: 'admin',
      password: 'admin123',
      role: UserRole.admin,
    ),
    User(
      id: '2',
      username: 'editor',
      password: 'editor123',
      role: UserRole.editor,
    ),
    User(
      id: '3',
      username: 'viewer',
      password: 'viewer123',
      role: UserRole.viewer,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeUsers();
  }

  void _initializeUsers() {
    if (HiveService.getAllUsers().isEmpty) {
      for (var user in _mockUsers) {
        HiveService.saveUser(user);
      }
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final user = HiveService.getAllUsers().firstWhere(
        (user) => user.username == username && user.password == password,
      );
      _currentUser.value = user;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String username, String password, UserRole role) async {
    try {
      // Check if username already exists
      if (HiveService.getUserByUsername(username) != null) {
        return false;
      }

      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username,
        password: password,
        role: role,
      );

      await HiveService.saveUser(newUser);
      return true;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _currentUser.value = null;
  }

  bool canEditTask() => currentUser?.canEditTask() ?? false;
  bool canCreateTask() => currentUser?.canCreateTask() ?? false;
  bool canDeleteTask() => currentUser?.canDeleteTask() ?? false;
  bool canMoveTask() => currentUser?.canMoveTask() ?? false;
  bool canSync() => currentUser?.canSync() ?? false;
}
