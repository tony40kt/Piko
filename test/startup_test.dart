import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_sticker_island/app.dart';
import 'package:magic_sticker_island/features/profile/profile_controller.dart';
import 'package:magic_sticker_island/features/profile/profile_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProfileController> seeded(int n) async {
  SharedPreferences.setMockInitialValues({});
  final c = await ProfileController.load();
  for (var i = 0; i < n; i++) {
    await c.createProfile('Kid$i');
  }
  return ProfileController.load();
}

void main() {
  testWidgets('0 profiles shows create screen', (t) async {
    await t.pumpWidget(PikoApp(controller: await seeded(0)));
    await t.pumpAndSettle();
    expect(find.byType(CreateProfileScreen), findsOneWidget);
  });

  testWidgets('1 profile goes home', (t) async {
    await t.pumpWidget(PikoApp(controller: await seeded(1)));
    await t.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('2 profiles shows selection', (t) async {
    await t.pumpWidget(PikoApp(controller: await seeded(2)));
    await t.pumpAndSettle();
    expect(find.byType(ProfileSelectionScreen), findsOneWidget);
  });

  testWidgets('locale switches text', (t) async {
    t.platformDispatcher.localesTestValue = const [
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN')
    ];
    addTearDown(t.platformDispatcher.clearLocalesTestValue);
    await t.pumpWidget(PikoApp(controller: await seeded(0)));
    await t.pumpAndSettle();
    expect(find.text('创建个人档案'), findsOneWidget);
  });

  test('update profile persists', () async {
    final c = await seeded(1);
    await c.updateProfile(c.profiles.first.copyWith(name: 'New'));
    expect((await ProfileController.load()).profiles.first.name, 'New');
  });
}
