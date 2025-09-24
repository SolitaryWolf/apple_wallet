# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-09-24

### Added
- Initial release of Apple Wallet Flutter package
- In-app provisioning support for iOS
- PassKit integration for adding payment passes to Apple Wallet
- `AddToAppleWalletButton` widget with customizable styles
- Support for payment pass management (add, remove, list, check activation status)
- Real-time pass library change notifications
- Comprehensive error handling with custom exception types
- iOS native bridge implementation using Swift and PassKit framework
- Support for various payment networks (Visa, MasterCard, Amex, etc.)

### Features
- **In-app Provisioning**: Add payment passes directly from your Flutter app
- **Pass Management**: List, remove, and check activation status of payment passes
- **Event Streaming**: Listen to pass library changes in real-time
- **Custom UI Components**: Pre-built AddToAppleWalletButton with multiple styles
- **Error Handling**: Comprehensive exception handling for all operations
- **Platform Integration**: Native iOS implementation using PassKit framework

### Requirements
- iOS 12.0+
- Flutter 3.0.0+
- Dart SDK 3.8.1+
- PassKit framework
- Apple Developer account with in-app provisioning entitlements