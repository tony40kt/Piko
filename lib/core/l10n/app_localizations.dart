import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// 基礎介面文字（英文、繁體中文、簡體中文）。
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'),
  ];

  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const _en = <String, String>{
    'appTitle': 'Magic Sticker Island',
    'createProfileTitle': 'Create Child Profile',
    'nameLabel': "Child's name",
    'nameRequired': 'Please enter a name',
    'createProfileButton': 'Create',
    'selectProfileTitle': 'Who is playing?',
    'homeTitle': 'Home',
    'welcome': 'Welcome, {name}!',
    'addProfile': 'Add profile',
  };

  static const _zhTW = <String, String>{
    'appTitle': '奇妙貼貼島',
    'createProfileTitle': '建立個人檔案',
    'nameLabel': '小朋友的名字',
    'nameRequired': '請輸入名字',
    'createProfileButton': '建立',
    'selectProfileTitle': '誰要來玩？',
    'homeTitle': '主頁',
    'welcome': '歡迎，{name}！',
    'addProfile': '新增帳戶',
  };

  static const _zhCN = <String, String>{
    'appTitle': '奇妙贴贴岛',
    'createProfileTitle': '创建个人档案',
    'nameLabel': '小朋友的名字',
    'nameRequired': '请输入名字',
    'createProfileButton': '创建',
    'selectProfileTitle': '谁要来玩？',
    'homeTitle': '主页',
    'welcome': '欢迎，{name}！',
    'addProfile': '新增账户',
  };

  Map<String, String> get _strings {
    if (locale.languageCode != 'zh') return _en;
    final traditional = locale.scriptCode == 'Hant' ||
        (locale.scriptCode == null &&
            (locale.countryCode == 'TW' ||
                locale.countryCode == 'HK' ||
                locale.countryCode == 'MO'));
    return traditional ? _zhTW : _zhCN;
  }

  String _t(String key) => _strings[key] ?? _en[key]!;

  String get appTitle => _t('appTitle');
  String get createProfileTitle => _t('createProfileTitle');
  String get nameLabel => _t('nameLabel');
  String get nameRequired => _t('nameRequired');
  String get createProfileButton => _t('createProfileButton');
  String get selectProfileTitle => _t('selectProfileTitle');
  String get homeTitle => _t('homeTitle');
  String get addProfile => _t('addProfile');
  String welcome(String name) => _t('welcome').replaceAll('{name}', name);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      const ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
