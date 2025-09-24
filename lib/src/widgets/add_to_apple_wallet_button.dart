import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../apple_wallet.dart';
import '../models/models.dart';

enum AddToAppleWalletButtonStyle {
  black,
  blackOutline,
  white,
  whiteOutline,
}

class AddToAppleWalletButton extends StatefulWidget {
  final PaymentPassRequest paymentPassRequest;
  final AddToAppleWalletButtonStyle style;
  final double? width;
  final double? height;
  final VoidCallback? onPressed;
  final void Function(String result)? onSuccess;
  final void Function(AppleWalletException error)? onError;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const AddToAppleWalletButton({
    super.key,
    required this.paymentPassRequest,
    this.style = AddToAppleWalletButtonStyle.black,
    this.width,
    this.height,
    this.onPressed,
    this.onSuccess,
    this.onError,
    this.margin,
    this.padding,
  });

  @override
  State<AddToAppleWalletButton> createState() =>
      _AddToAppleWalletButtonState();
}

class _AddToAppleWalletButtonState extends State<AddToAppleWalletButton> {
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
        width: widget.width,
        height: widget.height ?? 44.0,
        child: Material(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(8.0),
          child: InkWell(
            onTap: _isLoading ? null : _handlePress,
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              decoration: _getDecoration(),
              child: Center(
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getTextColor(),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: _getTextColor(),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add to Apple Wallet',
                            style: TextStyle(
                              color: _getTextColor(),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (widget.style) {
      case AddToAppleWalletButtonStyle.black:
      case AddToAppleWalletButtonStyle.blackOutline:
        return Colors.black;
      case AddToAppleWalletButtonStyle.white:
      case AddToAppleWalletButtonStyle.whiteOutline:
        return Colors.white;
    }
  }

  Color _getTextColor() {
    switch (widget.style) {
      case AddToAppleWalletButtonStyle.black:
      case AddToAppleWalletButtonStyle.blackOutline:
        return Colors.white;
      case AddToAppleWalletButtonStyle.white:
      case AddToAppleWalletButtonStyle.whiteOutline:
        return Colors.black;
    }
  }

  BoxDecoration _getDecoration() {
    final isOutline = widget.style == AddToAppleWalletButtonStyle.blackOutline ||
        widget.style == AddToAppleWalletButtonStyle.whiteOutline;

    if (isOutline) {
      return BoxDecoration(
        border: Border.all(
          color: _getTextColor(),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8.0),
      );
    }

    return const BoxDecoration();
  }
}