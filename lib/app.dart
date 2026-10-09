import 'package:flutter/material.dart';

import 'core/l10n/app_localizations.dart';
import 'features/profile/profile_controller.dart';
import 'features/profile/profile_screens.dart';

class PikoApp extends StatelessWidget {
  const PikoApp({super.key, required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
  ChildProfile? _selected;
  bool _adding = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (_selected != null) return HomeScreen(profile: _selected!);
        if (controller.profileCount == 0 || _adding) {
          return CreateProfileScreen(
            controller: controller,
            onCreated: (p) => setState(() {
              _adding = false;
              _selected = p;
            }),
          );
        }
        if (controller.profileCount == 1) {
          return HomeScreen(profile: controller.profiles.first);
        }
        return ProfileSelectionScreen(
          profiles: controller.profiles,
          onSelected: (p) => setState(() => _selected = p),
          onAddProfile: () => setState(() => _adding = true),
        );
      },
    );
  }
}
