import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// 管理 RevenueCat 訂閱狀態，供整個應用程式共用。
///
/// API 金鑰應由應用程式啟動設定或安全的建置設定傳入，不要寫入原始碼。
class SubscriptionManager extends ChangeNotifier {
  SubscriptionManager({this.premiumEntitlementId = 'premium'});

  final String premiumEntitlementId;

  bool _isPremium = false;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _revenueCatConfigured = false;
  bool _listenerRegistered = false;
  String? _configuredApiKey;
  Object? _lastError;
  Future<void>? _initializationFuture;

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  Object? get lastError => _lastError;

  /// 設定 RevenueCat 並載入目前使用者的權益。
  ///
  /// 重複呼叫會共用同一個初始化工作；若已使用不同的 API 金鑰設定，
  /// 則明確失敗，避免靜默連到錯誤的商店專案。
  Future<void> initialize({required String apiKey}) async {
    final normalizedApiKey = apiKey.trim();
    if (normalizedApiKey.isEmpty) {
      throw ArgumentError.value(apiKey, 'apiKey', 'API 金鑰不可為空');
    }
    if (_configuredApiKey != null &&
        _configuredApiKey != normalizedApiKey) {
      throw StateError('RevenueCat 已使用不同的 API 金鑰設定');
    }
    if (_isInitialized) return;
    final existingInitialization = _initializationFuture;
    if (existingInitialization != null) {
      await existingInitialization;
      return;
    }

    _configuredApiKey = normalizedApiKey;
    final initialization = _configureAndLoad(normalizedApiKey);
    _initializationFuture = initialization;
    try {
      await initialization;
    } finally {
      if (!_isInitialized) {
        _initializationFuture = null;
      }
    }
  }

  Future<void> _configureAndLoad(String apiKey) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      if (!_revenueCatConfigured) {
        await Purchases.configure(PurchasesConfiguration(apiKey));
        _revenueCatConfigured = true;
      }
      if (!_listenerRegistered) {
        Purchases.addCustomerInfoUpdateListener(_handleCustomerInfoUpdate);
        _listenerRegistered = true;
      }
      _applyCustomerInfo(await Purchases.getCustomerInfo());
      _isInitialized = true;
    } catch (error) {
      _lastError = error;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handleCustomerInfoUpdate(CustomerInfo customerInfo) {
    _applyCustomerInfo(customerInfo);
  }

  void _applyCustomerInfo(CustomerInfo customerInfo) {
    final updatedPremiumStatus =
        customerInfo.entitlements.active.containsKey(premiumEntitlementId);
    if (_isPremium == updatedPremiumStatus) return;

    _isPremium = updatedPremiumStatus;
    notifyListeners();
  }

  /// 重新向 RevenueCat 取得權益，適用於恢復購買或回到前景時。
  Future<void> refreshCustomerInfo() async {
    if (!_isInitialized) {
      throw StateError('請先初始化 SubscriptionManager');
    }

    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      _applyCustomerInfo(await Purchases.getCustomerInfo());
    } catch (error) {
      _lastError = error;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (_listenerRegistered) {
      Purchases.removeCustomerInfoUpdateListener(_handleCustomerInfoUpdate);
      _listenerRegistered = false;
    }
    super.dispose();
  }
}
