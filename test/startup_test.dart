import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_sticker_island/app.dart';
import 'package:magic_sticker_island/features/profile/profile_controller.dart';
import 'package:magic_sticker_island/features/profile/profile_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 建立含 n 個個人檔案的控制器（模擬重新啟動後重新載入）。
Future<ProfileController> seeded(int n) async {
  SharedPreferences.setMockInitialValues({});
  final c = await ProfileController.load();
  for (var i = 0; i < n; i++) {
    await c.createProfile('Kid$i');
  }
  return ProfileController.load();
}

void main() {
  // 0 個帳戶：顯示建立畫面
  testWidgets('0 profiles shows create screen', (t) async {
    await t.pumpWidget(PikoApp(controller: await seeded(0)));
    await t.pumpAndSettle();
    expect(find.byType(CreateProfileScreen), findsOneWidget);
  });

  // 1 個帳戶：直達主頁
  testWidgets('1 profile goes home', (t) async {
    await t.pumpWidget(PikoApp(controller: await seeded(1)));
    await t.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  // 2 個帳戶：顯示選擇畫面
  testWidgets('2 profiles shows selection', (t) async {
    await t.pumpWidget(PikoApp(controller: await seeded(2)));
    await t.pumpAndSettle();
    expect(find.byType(ProfileSelectionScreen), findsOneWidget);
  });

  // 切換裝置語系為簡體中文時，介面文字隨之改變
  testWidgets('locale switches text', (t) async {
    t.platformDispatcher.localesTestValue = const [
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN')
    ];
    addTearDown(t.platformDispatcher.clearLocalesTestValue);
    await t.pumpWidget(PikoApp(controller: await seeded(0)));
    await t.pumpAndSettle();
    expect(find.text('创建个人档案'), findsOneWidget);
  });

  // 更新個人檔案後重新載入仍保留
  test('update profile persists', () async {
    final c = await seeded(1);
    await c.updateProfile(c.profiles.first.copyWith(name: 'New'));
    expect((await ProfileController.load()).profiles.first.name, 'New');
  });
}
