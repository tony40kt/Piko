import 'package:flutter/foundation.dart';

import 'subscription_manager.dart';

/// 說明開啟付費牆的原因，方便 UI 顯示對應文案。
enum PaywallReason {
  lockedIsland,
  additionalChildProfile,
  dailyChallengeSticker,
}

/// 集中管理付費牆的顯示狀態與訂閱後的自動關閉。
class PaywallController extends ChangeNotifier {
  PaywallController(this._subscriptionManager) {
    _subscriptionManager.addListener(_handleSubscriptionChange);
  }

  final SubscriptionManager _subscriptionManager;
  PaywallReason? _reason;

  bool get isVisible => _reason != null;
  PaywallReason? get reason => _reason;

  /// 僅在使用者尚未訂閱時顯示付費牆。
  bool show(PaywallReason reason) {
    if (_subscriptionManager.isPremium) return false;
    _reason = reason;
    notifyListeners();
    return true;
  }

  void dismiss() {
    if (_reason == null) return;
    _reason = null;
    notifyListeners();
  }

  void _handleSubscriptionChange() {
    if (_subscriptionManager.isPremium && _reason != null) {
      _reason = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscriptionManager.removeListener(_handleSubscriptionChange);
    super.dispose();
  }
}
