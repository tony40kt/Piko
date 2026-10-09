import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 兒童個人檔案資料。
@immutable
class ChildProfile {
  const ChildProfile({required this.id, required this.name});

  /// 唯一識別碼
  final String id;

  /// 顯示名稱
  final String name;

  /// 複製並更新指定欄位
  ChildProfile copyWith({String? name}) =>
      ChildProfile(id: id, name: name ?? this.name);

  /// 轉為 JSON 以便儲存
  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  /// 從 JSON 還原個人檔案
  factory ChildProfile.fromJson(Map<String, dynamic> json) =>
      ChildProfile(id: json['id'] as String, name: json['name'] as String);
}

/// 以 SharedPreferences 持久化兒童個人檔案。
class ProfileController extends ChangeNotifier {
  ProfileController._(this._preferences, List<ChildProfile> profiles)
      : _profiles = profiles;

  /// SharedPreferences 儲存鍵值
  static const storageKey = 'child_profiles';

  final SharedPreferences _preferences;

  /// 記憶體中的個人檔案清單
  List<ChildProfile> _profiles;

  /// 載入已儲存的個人檔案；資料損毀時視為空清單。
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
        // 資料格式錯誤，回復為空清單
        profiles = <ChildProfile>[];
      }
    }
    return ProfileController._(prefs, profiles);
  }

  /// 唯讀的個人檔案清單
  List<ChildProfile> get profiles => List.unmodifiable(_profiles);
  /// 個人檔案數量
  int get profileCount => _profiles.length;

  /// 建立新個人檔案並儲存。
  Future<ChildProfile> createProfile(String name) async {
    final profile = ChildProfile(
      // 以時間戳記產生唯一 id
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
    );
    _profiles = [..._profiles, profile];
    await _save();
    return profile;
  }

  /// 更新既有個人檔案（依 id 比對）並儲存。
  Future<void> updateProfile(ChildProfile profile) async {
    _profiles = [
      for (final p in _profiles) p.id == profile.id ? profile : p,
    ];
    await _save();
  }

  /// 寫入 SharedPreferences 並通知監聽者。
  Future<void> _save() async {
    await _preferences.setString(
      storageKey,
      jsonEncode(_profiles.map((p) => p.toJson()).toList()),
    );
    notifyListeners();
  }
}
