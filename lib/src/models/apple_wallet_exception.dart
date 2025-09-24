class AppleWalletException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppleWalletException(
    this.message, {
    this.code,
    this.details,
  });

  @override
  String toString() {
    if (code != null) {
      return 'AppleWalletException($code): $message';
    }
    return 'AppleWalletException: $message';
  }
}

class PaymentPassProvisioningException extends AppleWalletException {
  const PaymentPassProvisioningException(
    String message, {
    String? code,
    dynamic details,
  }) : super(message, code: code, details: details);
}

class PassKitUnavailableException extends AppleWalletException {
  const PassKitUnavailableException(
    String message, {
    String? code,
    dynamic details,
  }) : super(message, code: code, details: details);
}