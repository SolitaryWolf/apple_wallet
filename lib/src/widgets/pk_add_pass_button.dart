import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../apple_wallet.dart';
import '../models/models.dart';

enum PKAddPassButtonStyle {
  black,
  blackOutline,
  white,
  whiteOutline,
}

class PKAddPassButton extends StatefulWidget {
  final PaymentPassRequest paymentPassRequest;
  final PKAddPassButtonStyle style;
  final double? width;
  final double? height;
  final VoidCallback? onPressed;
  final void Function(String result)? onSuccess;
  final void Function(AppleWalletException error)? onError;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const PKAddPassButton({
    super.key,
    required this.paymentPassRequest,
    this.style = PKAddPassButtonStyle.black,
    this.width,
    this.height,
    this.onPressed,
    this.onSuccess,
    this.onError,
    this.margin,
    this.padding,
  });

  @override
  State<PKAddPassButton> createState() => _PKAddPassButtonState();
}

class _PKAddPassButtonState extends State<PKAddPassButton> {
  bool _isLoading = false;
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    try {
      final isAvailable = await AppleWallet.isPassKitAvailable;
      final canAdd = await AppleWallet.canAddPasses;

      if (mounted) {
        setState(() {
          _isAvailable = isAvailable && canAdd;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAvailable = false;
        });
      }
    }
  }

  Future<void> _handlePress() async {
    if (_isLoading || !_isAvailable) return;

    widget.onPressed?.call();

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AppleWallet.addPaymentPass(
        request: widget.paymentPassRequest,
      );

      if (mounted) {
        widget.onSuccess?.call(result);
      }
    } on PlatformException catch (e) {
      if (mounted) {
        final exception = AppleWalletException(
          e.message ?? 'Failed to add payment pass',
          code: e.code,
          details: e.details,
        );
        widget.onError?.call(exception);
      }
    } catch (e) {
      if (mounted) {
        final exception = AppleWalletException(e.toString());
        widget.onError?.call(exception);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAvailable) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin,
      padding: widget.padding,
      child: SizedBox(
        width: widget.width ?? 140,
        height: widget.height ?? 44.0,
        child: UiKitView(
          viewType: 'PKAddPassButton',
          creationParams: {
            'style': _getStyleValue(),
            'width': widget.width ?? 140,
            'height': widget.height ?? 44.0,
          },
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: (int id) {
            // Set up method channel for this specific button instance
            final channel = MethodChannel('PKAddPassButton_$id');
            channel.setMethodCallHandler((call) async {
              if (call.method == 'onPressed') {
                await _handlePress();
              }
            });
          },
        ),
      ),
    );
  }

  int _getStyleValue() {
    switch (widget.style) {
      case PKAddPassButtonStyle.black:
        return 0; // PKAddPassButtonStyleBlack
      case PKAddPassButtonStyle.blackOutline:
        return 1; // PKAddPassButtonStyleBlackOutline
      case PKAddPassButtonStyle.white:
        return 2; // PKAddPassButtonStyleWhite
      case PKAddPassButtonStyle.whiteOutline:
        return 3; // PKAddPassButtonStyleWhiteOutline
    }
  }
}