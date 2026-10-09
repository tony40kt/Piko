import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class ChildProfile {
  const ChildProfile({required this.id, required this.name});

  final String id;
  final String name;

  ChildProfile copyWith({String? name}) =>
      ChildProfile(id: id, name: name ?? this.name);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory ChildProfile.fromJson(Map<String, dynamic> json) =>
      ChildProfile(id: json['id'] as String, name: json['name'] as String);
}

/// 以 SharedPreferences 持久化兒童個人檔案。
class ProfileController extends ChangeNotifier {
  ProfileController._(this._preferences, List<ChildProfile> profiles)
      : _profiles = profiles;

  static const storageKey = 'child_profiles';

  final SharedPreferences _preferences;
  List<ChildProfile> _profiles;

  static Future<ProfileController> load([SharedPreferences? preferences]) async {
    final prefs = preferences ?? await SharedPreferences.getInstance();
    var profiles = <ChildProfile>[];
    final raw = prefs.getString(storageKey);
    if (raw != null) {
      try {
        profiles = (jsonDecode(raw) as List<dynamic>)
            .map((e) => ChildProfile.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        profiles = <ChildProfile>[];
      }
    }
    return ProfileController._(prefs, profiles);
  }

  List<ChildProfile> get profiles => List.unmodifiable(_profiles);
  int get profileCount => _profiles.length;

  Future<ChildProfile> createProfile(String name) async {
    final profile = ChildProfile(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
    );
    _profiles = [..._profiles, profile];
    await _save();
    return profile;
  }

  Future<void> updateProfile(ChildProfile profile) async {
    _profiles = [
      for (final p in _profiles) p.id == profile.id ? profile : p,
    ];
    await _save();
  }

  Future<void> _save() async {
    await _preferences.setString(
      storageKey,
      jsonEncode(_profiles.map((p) => p.toJson()).toList()),
    );
    notifyListeners();
  }
}
