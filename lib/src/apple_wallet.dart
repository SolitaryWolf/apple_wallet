import 'apple_wallet_platform_interface.dart';
import 'models/models.dart';

class AppleWallet {
  static AppleWalletPlatform get _platform => AppleWalletPlatform.instance;

  static Future<bool> get canAddPasses => _platform.canAddPasses();

  static Future<bool> get isPassKitAvailable => _platform.isPassKitAvailable();

  static Future<String> addPaymentPass({
    required PaymentPassRequest request,
  }) {
    return _platform.addPaymentPass(request: request);
  }

  static Future<List<PaymentPass>> getPaymentPasses() {
    return _platform.getPaymentPasses();
  }

  static Future<bool> removePaymentPass(String passTypeIdentifier) {
    return _platform.removePaymentPass(passTypeIdentifier);
  }

  static Future<bool> isPaymentPassActivated(String passTypeIdentifier) {
    return _platform.isPaymentPassActivated(passTypeIdentifier);
  }

  static Stream<PassLibraryChange> get passLibraryChanges =>
      _platform.passLibraryChanges;
}