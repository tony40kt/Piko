import 'package:flutter/material.dart';

import 'core/l10n/app_localizations.dart';
import 'features/profile/profile_controller.dart';
import 'features/profile/profile_screens.dart';

/// 應用程式根元件，設定多語系與首頁。
class PikoApp extends StatelessWidget {
  const PikoApp({super.key, required this.controller});

  /// 個人檔案控制器
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 依裝置語系產生應用程式標題
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      // 本地化代理（含 flutter_localizations）
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // 支援語系：英文、繁體中文、簡體中文
      supportedLocales: AppLocalizations.supportedLocales,
      // 啟動時依帳戶數量決定首個畫面
      home: StartupGate(controller: controller),
    );
  }
}

/// 啟動導流：0 個帳戶建立、1 個直達主頁、2 個以上選擇帳戶。
class StartupGate extends StatefulWidget {
  const StartupGate({super.key, required this.controller});

  final ProfileController controller;

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  /// 目前已選定（或剛建立）的個人檔案
  ChildProfile? _selected;

  /// 是否正在從選擇畫面新增帳戶
  bool _adding = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    // 監聽控制器，帳戶變動時重新判斷畫面
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        // 已選定帳戶：進入主頁
        if (_selected != null) return HomeScreen(profile: _selected!);
        // 0 個帳戶（或正在新增）：顯示建立個人檔案畫面
        if (controller.profileCount == 0 || _adding) {
          return CreateProfileScreen(
            controller: controller,
            // 建立完成後直接進入主頁
            onCreated: (p) => setState(() {
              _adding = false;
              _selected = p;
            }),
          );
        }
        // 1 個帳戶：跳過選擇，直達主頁
        if (controller.profileCount == 1) {
          return HomeScreen(profile: controller.profiles.first);
        }
        // 2 個以上帳戶：顯示帳戶選擇畫面
        return ProfileSelectionScreen(
          profiles: controller.profiles,
          onSelected: (p) => setState(() => _selected = p),
          onAddProfile: () => setState(() => _adding = true),
        );
      },
    );
  }
}
