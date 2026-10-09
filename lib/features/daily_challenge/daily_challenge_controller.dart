import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/subscription/subscription_manager.dart';

/// 一次每日挑戰結束後可發放的獎勵資料。
@immutable
class DailyChallengeResult {
  const DailyChallengeResult({
    required this.correctAnswers,
    required this.baseCoins,
    required this.awardedCoins,
    required this.isPremium,
  });

  final int correctAnswers;
  final int baseCoins;
  final int awardedCoins;
  final bool isPremium;
}

/// 管理每位兒童每日一次的挑戰、獎勵與累積參加次數。
class DailyChallengeController extends ChangeNotifier {
  DailyChallengeController._({
    required SharedPreferences preferences,
    required SubscriptionManager subscriptionManager,
    required String storageKey,
    required int participationCount,
    required String? lastParticipationDate,
    required DateTime Function() clock,
  })  : _preferences = preferences,
        _subscriptionManager = subscriptionManager,
        _storageKey = storageKey,
        _participationCount = participationCount,
        _lastParticipationDate = lastParticipationDate,
        _clock = clock;

  static const int questionCount = 3;
  static const int coinsPerCorrectAnswer = 3;
  static const String _storageKeyPrefix = 'daily_challenge_v1_';

  final SharedPreferences _preferences;
  final SubscriptionManager _subscriptionManager;
  final String _storageKey;
  final DateTime Function() _clock;

  int _participationCount;
  String? _lastParticipationDate;
  int _questionIndex = 0;
  int _correctAnswers = 0;
  bool _isStarting = false;
  bool _isInProgress = false;
  bool _isCompleted = false;

  int get participationCount => _participationCount;
  int get questionIndex => _questionIndex;
  int get correctAnswers => _correctAnswers;
  bool get isInProgress => _isInProgress;
  bool get isCompleted => _isCompleted;
  bool get canAnswer => _isInProgress && _questionIndex < questionCount;
  bool get canComplete => _isInProgress && _questionIndex == questionCount;
  bool get hasParticipatedToday =>
      _lastParticipationDate == _dateKey(_clock());

  /// 載入依兒童個人檔案隔離的本機參加紀錄。
  static Future<DailyChallengeController> create({
    required String profileId,
    required SubscriptionManager subscriptionManager,
    SharedPreferences? preferences,
    DateTime Function()? clock,
  }) async {
    final normalizedProfileId = profileId.trim();
    if (normalizedProfileId.isEmpty) {
      throw ArgumentError.value(profileId, 'profileId', '個人檔案 ID 不可為空');
    }

    final store = preferences ?? await SharedPreferences.getInstance();
    final storageKey = '$_storageKeyPrefix'
        '${base64Url.encode(utf8.encode(normalizedProfileId))}';
    var participationCount = 0;
    String? lastParticipationDate;
    final savedState = store.getString(storageKey);

    if (savedState != null) {
      try {
        final decoded = jsonDecode(savedState);
        if (decoded is Map<String, dynamic>) {
          final savedCount = decoded['participationCount'];
          final savedDate = decoded['lastParticipationDate'];
          if (savedCount is int && savedCount >= 0) {
            participationCount = savedCount;
          }
          if (savedDate is String && _isValidDateKey(savedDate)) {
            lastParticipationDate = savedDate;
          }
        }
      } on FormatException {
        // 損毀或舊格式的本機資料不應阻止孩子開始遊戲。
        await store.remove(storageKey);
      }
    }

    return DailyChallengeController._(
      preferences: store,
      subscriptionManager: subscriptionManager,
      storageKey: storageKey,
      participationCount: participationCount,
      lastParticipationDate: lastParticipationDate,
      clock: clock ?? DateTime.now,
    );
  }

  /// 開始當日挑戰時立即鎖定當天並累加參加次數，不看最後答對幾題。
  ///
  /// 回傳 false 表示今日已經開始過；儲存失敗則拋出錯誤，避免在未能
  /// 持久化每日限制時仍開放挑戰。
  Future<bool> startChallenge() async {
    final today = _dateKey(_clock());
    if (_lastParticipationDate == today || _isInProgress || _isStarting) {
      return false;
    }

    _isStarting = true;
    try {
      final nextParticipationCount = _participationCount + 1;
      final persisted = await _preferences.setString(
        _storageKey,
        jsonEncode({
          'participationCount': nextParticipationCount,
          'lastParticipationDate': today,
        }),
      );
      if (!persisted) {
        throw StateError('無法儲存每日挑戰參加紀錄');
      }

      _lastParticipationDate = today;
      _participationCount = nextParticipationCount;
      _questionIndex = 0;
      _correctAnswers = 0;
      _isInProgress = true;
      _isCompleted = false;
      notifyListeners();
      return true;
    } finally {
      _isStarting = false;
    }
  }

  /// 記錄一道題目的作答。答對得 3 枚學習幣，答錯得 0 枚。
  void submitAnswer({required bool isCorrect}) {
    if (!canAnswer) {
      throw StateError('目前沒有可作答的每日挑戰題目');
    }
    if (isCorrect) _correctAnswers++;
    _questionIndex++;
    notifyListeners();
  }

  /// 完成三題後結算獎勵；訂閱狀態於結算當下檢查並套用雙倍。
  DailyChallengeResult completeChallenge() {
    if (!canComplete) {
      throw StateError('必須完成全部 $questionCount 題才能結算每日挑戰');
    }

    final baseCoins = _correctAnswers * coinsPerCorrectAnswer;
    final isPremium = _subscriptionManager.isPremium;
    final result = DailyChallengeResult(
      correctAnswers: _correctAnswers,
      baseCoins: baseCoins,
      awardedCoins: isPremium ? baseCoins * 2 : baseCoins,
      isPremium: isPremium,
    );

    _isInProgress = false;
    _isCompleted = true;
    notifyListeners();
    return result;
  }

  /// 達標貼紙以參加次數為準，不受答題正確率影響。
  bool hasReachedParticipationMilestone(int target) {
    if (target <= 0) {
      throw ArgumentError.value(target, 'target', '里程碑次數必須大於零');
    }
    return _participationCount >= target;
  }

  /// 免費使用者可查看已達標貼紙，但必須訂閱才能領取。
  bool canClaimParticipationSticker(int target) =>
      hasReachedParticipationMilestone(target) &&
      _subscriptionManager.isPremium;

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static bool _isValidDateKey(String value) =>
      RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value);
}
