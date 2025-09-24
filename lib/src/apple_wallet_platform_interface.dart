import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'models/models.dart';

abstract class AppleWalletPlatform extends PlatformInterface {
  AppleWalletPlatform() : super(token: _token);

  static final Object _token = Object();

  static AppleWalletPlatform _instance = MethodChannelAppleWallet();

  static AppleWalletPlatform get instance => _instance;

  static set instance(AppleWalletPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> canAddPasses() {
    throw UnimplementedError('canAddPasses() has not been implemented.');
  }

  Future<bool> isPassKitAvailable() {
    throw UnimplementedError('isPassKitAvailable() has not been implemented.');
  }

  Future<String> addPaymentPass({
    required PaymentPassRequest request,
  }) {
    throw UnimplementedError('addPaymentPass() has not been implemented.');
  }

  Future<List<PaymentPass>> getPaymentPasses() {
    throw UnimplementedError('getPaymentPasses() has not been implemented.');
  }

  Future<bool> removePaymentPass(String passTypeIdentifier) {
    throw UnimplementedError('removePaymentPass() has not been implemented.');
  }

  Future<bool> isPaymentPassActivated(String passTypeIdentifier) {
    throw UnimplementedError('isPaymentPassActivated() has not been implemented.');
  }

  Stream<PassLibraryChange> get passLibraryChanges {
    throw UnimplementedError('passLibraryChanges has not been implemented.');
  }
}

class MethodChannelAppleWallet extends AppleWalletPlatform {
  static const MethodChannel _channel = MethodChannel('apple_wallet');
  static const EventChannel _eventChannel = EventChannel('apple_wallet/events');

  @override
  Future<bool> canAddPasses() async {
    final result = await _channel.invokeMethod<bool>('canAddPasses');
    return result ?? false;
  }

  @override
  Future<bool> isPassKitAvailable() async {
    final result = await _channel.invokeMethod<bool>('isPassKitAvailable');
    return result ?? false;
  }

  @override
  Future<String> addPaymentPass({
    required PaymentPassRequest request,
  }) async {
    final result = await _channel.invokeMethod<String>(
      'addPaymentPass',
      request.toJson(),
    );
    return result ?? '';
  }

  @override
  Future<List<PaymentPass>> getPaymentPasses() async {
    final result = await _channel.invokeMethod<List<dynamic>>('getPaymentPasses');
    if (result == null) return [];

    return result
        .map((json) => PaymentPass.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<bool> removePaymentPass(String passTypeIdentifier) async {
    final result = await _channel.invokeMethod<bool>(
      'removePaymentPass',
      {'passTypeIdentifier': passTypeIdentifier},
    );
    return result ?? false;
  }

  @override
  Future<bool> isPaymentPassActivated(String passTypeIdentifier) async {
    final result = await _channel.invokeMethod<bool>(
      'isPaymentPassActivated',
      {'passTypeIdentifier': passTypeIdentifier},
    );
    return result ?? false;
  }

  @override
  Stream<PassLibraryChange> get passLibraryChanges {
    return _eventChannel.receiveBroadcastStream().map(
      (event) => PassLibraryChange.fromJson(Map<String, dynamic>.from(event)),
    );
  }
}