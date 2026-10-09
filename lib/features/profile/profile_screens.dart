import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import 'profile_controller.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key, required this.controller, this.onCreated});

  final ProfileController controller;
  final ValueChanged<ChildProfile>? onCreated;

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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

class ProfileSelectionScreen extends StatelessWidget {
  const ProfileSelectionScreen({
    super.key,
    required this.profiles,
    required this.onSelected,
    required this.onAddProfile,
  });

  final List<ChildProfile> profiles;
  final ValueChanged<ChildProfile> onSelected;
  final VoidCallback onAddProfile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.selectProfileTitle)),
      body: ListView(
        children: [
          for (final p in profiles)
            ListTile(
              leading: const Icon(Icons.child_care),
              title: Text(p.name),
              onTap: () => onSelected(p),
            ),
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.profile});

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
