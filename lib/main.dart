import 'package:flutter/material.dart';

import 'app.dart';
import 'features/profile/profile_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = await ProfileController.load();
  runApp(PikoApp(controller: controller));
}
