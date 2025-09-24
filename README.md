# Apple Wallet

A Flutter package for Apple Wallet integration with in-app provisioning and wallet extension support.

[![pub package](https://img.shields.io/pub/v/apple_wallet.svg)](https://pub.dev/packages/apple_wallet)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- ✅ **In-app Provisioning**: Add payment passes directly from your Flutter app to Apple Wallet
- ✅ **Pass Management**: List, remove, and check activation status of payment passes
- ✅ **Real-time Events**: Listen to pass library changes with event streaming
- ✅ **Custom UI Components**: Pre-built `AddToAppleWalletButton` with multiple styles
- ✅ **Comprehensive Error Handling**: Custom exception types for different error scenarios
- ✅ **Native iOS Integration**: Built with Swift and PassKit framework
- ✅ **Multiple Payment Networks**: Support for Visa, MasterCard, Amex, and more

## Requirements

- iOS 12.0+
- Flutter 3.0.0+
- Dart SDK 3.8.1+
- Apple Developer account with in-app provisioning entitlements
- PassKit framework access

## Installation

Add `apple_wallet` to your `pubspec.yaml`:

```yaml
dependencies:
  apple_wallet: ^0.1.0
```

Then run:
```bash
flutter pub get
```

## iOS Setup

### 1. Enable PassKit Capability

In your iOS project, you need to enable the PassKit capability:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select your app target
3. Go to "Signing & Capabilities" tab
4. Click "+ Capability" and add "Apple Pay & Wallet"

### 2. Add Entitlements

For in-app provisioning, you need special entitlements from Apple. Add this to your `ios/Runner/Runner.entitlements`:

```xml
<dict>
    <key>com.apple.developer.payment-pass-provisioning</key>
    <true/>
</dict>
```

**Note**: You must contact Apple at apple-pay-inquiries@apple.com to get approval for this entitlement.

### 3. Update Info.plist

Add usage descriptions to `ios/Runner/Info.plist`:

```xml
<key>NSAppleWalletUsageDescription</key>
<string>This app uses Apple Wallet to manage payment cards</string>
```

## Usage

### Basic Setup

```dart
import 'package:apple_wallet/apple_wallet.dart';

// Check if PassKit is available
bool isAvailable = await AppleWallet.isPassKitAvailable;
bool canAddPasses = await AppleWallet.canAddPasses;
```

### Adding a Payment Pass

```dart
// Create a payment pass request
PaymentPassRequest request = PaymentPassRequest(
  cardholderName: 'John Doe',
  primaryAccountSuffix: '1234',
  localizedDescription: 'My Credit Card',
  paymentNetwork: PaymentNetwork.visa,
  encryptedPassData: {
    'version': '1',
    'data': 'encrypted_data_from_your_server',
    'signature': 'signature_from_your_server',
    'header': 'header_from_your_server',
  },
);

// Add the pass
try {
  String result = await AppleWallet.addPaymentPass(request: request);
  print('Pass added successfully: $result');
} catch (e) {
  print('Error adding pass: $e');
}
```

### Using the AddToAppleWalletButton Widget

```dart
AddToAppleWalletButton(
  paymentPassRequest: request,
  style: AddToAppleWalletButtonStyle.black,
  onSuccess: (result) {
    print('Pass added: $result');
  },
  onError: (error) {
    print('Error: ${error.message}');
  },
)
```

### Managing Payment Passes

```dart
// Get all payment passes
List<PaymentPass> passes = await AppleWallet.getPaymentPasses();

// Remove a payment pass
bool removed = await AppleWallet.removePaymentPass('pass.com.example.card');

// Check if a pass is activated
bool isActivated = await AppleWallet.isPaymentPassActivated('pass.com.example.card');
```

### Listening to Pass Library Changes

```dart
AppleWallet.passLibraryChanges.listen((PassLibraryChange change) {
  print('Pass library changed: ${change.type}');
  print('Pass identifier: ${change.passTypeIdentifier}');
});
```

## API Reference

### Core Methods

| Method | Description | Return Type |
|--------|-------------|-------------|
| `isPassKitAvailable` | Check if PassKit is available on device | `Future<bool>` |
| `canAddPasses` | Check if passes can be added to wallet | `Future<bool>` |
| `addPaymentPass(request)` | Add a payment pass to wallet | `Future<String>` |
| `getPaymentPasses()` | Get all payment passes in wallet | `Future<List<PaymentPass>>` |
| `removePaymentPass(identifier)` | Remove a payment pass from wallet | `Future<bool>` |
| `isPaymentPassActivated(identifier)` | Check if pass is activated | `Future<bool>` |
| `passLibraryChanges` | Stream of pass library changes | `Stream<PassLibraryChange>` |

### Models

#### PaymentPassRequest

```dart
PaymentPassRequest({
  required String cardholderName,
  required String primaryAccountSuffix,
  required String localizedDescription,
  required PaymentNetwork paymentNetwork,
  required Map<String, String> encryptedPassData,
  String? activationData,
  String? wrappingKeyHash,
  Map<String, dynamic>? metadata,
})
```

#### PaymentPass

```dart
PaymentPass({
  required String passTypeIdentifier,
  required String serialNumber,
  required String localizedDescription,
  required String organizationName,
  required bool isActivated,
  DateTime? activationDate,
  Map<String, dynamic>? metadata,
})
```

#### PaymentNetwork

Supported payment networks:
- `PaymentNetwork.visa`
- `PaymentNetwork.masterCard`
- `PaymentNetwork.amex`
- `PaymentNetwork.discover`
- `PaymentNetwork.jcb`
- `PaymentNetwork.unionPay`
- `PaymentNetwork.maestro`
- `PaymentNetwork.girocard`
- `PaymentNetwork.interac`
- `PaymentNetwork.eftpos`

### Widgets

#### AddToAppleWalletButton

```dart
AddToAppleWalletButton({
  required PaymentPassRequest paymentPassRequest,
  AddToAppleWalletButtonStyle style = AddToAppleWalletButtonStyle.black,
  double? width,
  double? height,
  VoidCallback? onPressed,
  void Function(String result)? onSuccess,
  void Function(AppleWalletException error)? onError,
  EdgeInsetsGeometry? margin,
  EdgeInsetsGeometry? padding,
})
```

Button styles:
- `AddToAppleWalletButtonStyle.black`
- `AddToAppleWalletButtonStyle.blackOutline`
- `AddToAppleWalletButtonStyle.white`
- `AddToAppleWalletButtonStyle.whiteOutline`

## Error Handling

The package provides custom exception types:

```dart
try {
  await AppleWallet.addPaymentPass(request: request);
} on PaymentPassProvisioningException catch (e) {
  // Handle provisioning specific errors
  print('Provisioning error: ${e.message}');
} on PassKitUnavailableException catch (e) {
  // Handle PassKit unavailable errors
  print('PassKit unavailable: ${e.message}');
} on AppleWalletException catch (e) {
  // Handle general Apple Wallet errors
  print('Apple Wallet error: ${e.message}');
}
```

## Security Considerations

1. **Encrypted Pass Data**: Always encrypt pass data on your server using Apple's certificates
2. **Server Integration**: In-app provisioning requires server-side integration with Apple's PassKit Web Service
3. **Entitlements**: Only use in-app provisioning entitlements in production after approval from Apple
4. **Certificate Management**: Properly manage and rotate encryption certificates

## Example

See the [example](example/) folder for a complete sample application demonstrating all features.

## Platform Support

| Platform | Support |
|----------|---------|
| iOS      | ✅      |
| Android  | ❌      |
| Web      | ❌      |
| macOS    | ❌      |
| Windows  | ❌      |
| Linux    | ❌      |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions, please file an issue on the [GitHub repository](https://github.com/yourusername/apple_wallet/issues).

## Acknowledgments

- Built with Flutter and the PassKit framework
- Inspired by Apple's PassKit documentation and best practices
