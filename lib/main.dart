import 'package:flutter/material.dart';

import 'app.dart';
import 'features/profile/profile_controller.dart';

/// 應用程式進入點：先載入本地儲存的個人檔案，再啟動 App。
Future<void> main() async {
  // 使用 SharedPreferences 前需先初始化 Flutter 綁定
  WidgetsFlutterBinding.ensureInitialized();
  // 從本地端讀取所有個人檔案
  final controller = await ProfileController.load();
  // 啟動根元件
  runApp(PikoApp(controller: controller));
}
