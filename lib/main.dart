import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:munim_todo/controllers/auth_controller.dart';
import 'package:munim_todo/controllers/task_controller.dart';
import 'package:munim_todo/screens/login_screen.dart';
import 'package:munim_todo/services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize HiveService
  await HiveService.init();

  // Initialize controllers
  Get.put(AuthController());
  Get.put(TaskController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Munim Todo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}
