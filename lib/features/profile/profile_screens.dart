import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import 'profile_controller.dart';

/// 建立個人檔案畫面。
class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key, required this.controller, this.onCreated});

  /// 個人檔案控制器
  final ProfileController controller;

  /// 建立完成後的回呼
  final ValueChanged<ChildProfile>? onCreated;

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  /// 表單驗證用 key
  final _formKey = GlobalKey<FormState>();
  /// 名字輸入控制器
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// 驗證並送出表單。
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final profile = await widget.controller.createProfile(_nameController.text);
    widget.onCreated?.call(profile);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createProfileTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.nameLabel),
                // 名字不可為空
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.nameRequired : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(l10n.createProfileButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 帳戶選擇畫面（2 個以上帳戶時顯示）。
class ProfileSelectionScreen extends StatelessWidget {
  const ProfileSelectionScreen({
    super.key,
    required this.profiles,
    required this.onSelected,
    required this.onAddProfile,
  });

  /// 所有個人檔案
  final List<ChildProfile> profiles;

  /// 選取某個帳戶的回呼
  final ValueChanged<ChildProfile> onSelected;

  /// 點擊新增帳戶的回呼
  final VoidCallback onAddProfile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.selectProfileTitle)),
      body: ListView(
        children: [
          // 列出每個帳戶
          for (final p in profiles)
            ListTile(
              leading: const Icon(Icons.child_care),
              title: Text(p.name),
              onTap: () => onSelected(p),
            ),
          // 新增帳戶入口
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(l10n.addProfile),
            onTap: onAddProfile,
          ),
        ],
      ),
    );
  }
}

/// 主頁（階段 1 僅為占位畫面）。
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.profile});

  /// 目前使用的個人檔案
  final ChildProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: Center(child: Text(l10n.welcome(profile.name))),
    );
  }
}
